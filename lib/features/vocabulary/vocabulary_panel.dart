import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../app/providers.dart';
import '../../core/database/app_database.dart';
import '../../core/design/app_theme.dart';
import '../../core/design/common_widgets.dart';
import '../../data/repository/vocabulary_repository.dart';
import '../../domain/fsrs/fsrs_scheduler.dart';
import '../../domain/lemmatizer/lexicon.dart';

Future<void> showVocabularyPanel(
  BuildContext context,
  WidgetRef ref, {
  required SurfaceMatch match,
  String? bookId,
  String? occurrenceId,
  PendingOccurrence? pendingOccurrence,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (context) => FractionallySizedBox(
      heightFactor: 0.9,
      child: _VocabularySheet(
        match: match,
        bookId: bookId,
        occurrenceId: occurrenceId,
        pendingOccurrence: pendingOccurrence,
      ),
    ),
  );
}

class _VocabularySheet extends ConsumerStatefulWidget {
  const _VocabularySheet({
    required this.match,
    this.bookId,
    this.occurrenceId,
    this.pendingOccurrence,
  });

  final SurfaceMatch match;
  final String? bookId;
  final String? occurrenceId;
  final PendingOccurrence? pendingOccurrence;

  @override
  ConsumerState<_VocabularySheet> createState() => _VocabularySheetState();
}

class _VocabularySheetState extends ConsumerState<_VocabularySheet> {
  bool _busy = false;
  int? _countInBook;
  String? _recordedOccurrenceId;
  String? _vocabularyId;

  String? get _occurrenceId => _recordedOccurrenceId ?? widget.occurrenceId;

  @override
  void initState() {
    super.initState();
    _vocabularyId = widget.match.vocabularyId;
    if (_vocabularyId != null) {
      _seedDefinitions();
      _loadBookCount();
    }
  }

  Future<void> _loadBookCount() async {
    final vocabularyId = _vocabularyId;
    if (vocabularyId == null || widget.bookId == null) return;
    final count = await ref
        .read(vocabularyRepositoryProvider)
        .countInBook(vocabularyId, widget.bookId!);
    if (mounted) setState(() => _countInBook = count);
  }

  Future<void> _seedDefinitions() async {
    final vocabularyId = _vocabularyId;
    if (vocabularyId == null) return;
    final app = ref.read(appServicesProvider);
    final repo = ref.read(vocabularyRepositoryProvider);
    final vocabulary = await repo.getVocabulary(vocabularyId);
    if (vocabulary == null) return;
    final existing = await repo.getDefinitions(vocabularyId);
    if (existing.isNotEmpty) return;
    final senses = await app.definitionsFor(vocabulary.lemma);
    if (senses.isEmpty) return;
    final recheck = await repo.getDefinitions(vocabularyId);
    if (recheck.isNotEmpty) return;
    for (final sense in senses.take(2)) {
      await repo.addDefinition(
        vocabularyId: vocabularyId,
        meaning: sense.meaning,
      );
    }
  }

  /// Persists the word the first time it enters Learning or Known. Until then
  /// it is implicitly New and nothing is written.
  Future<String?> _ensureVocabulary() async {
    final existing = _vocabularyId;
    if (existing != null) return existing;
    final repository = ref.read(vocabularyRepositoryProvider);
    final id = await repository.ensureVocabulary(widget.match);
    if (!mounted) return id;
    setState(() => _vocabularyId = id);
    await _seedDefinitions();
    await _loadBookCount();
    return id;
  }

  Future<void> _setState(VocabularyState state) async {
    if (_busy) return;
    if (state == VocabularyState.newWord) return;
    setState(() => _busy = true);
    try {
      final app = ref.read(appServicesProvider);
      final vocabularyId = await _ensureVocabulary();
      if (vocabularyId == null) return;
      switch (state) {
        case VocabularyState.learning:
          await app.review.addToLearning(vocabularyId);
          final pending = widget.pendingOccurrence;
          final bookId = widget.bookId;
          if (pending != null && bookId != null) {
            final occurrenceId = await ref
                .read(vocabularyRepositoryProvider)
                .recordOccurrence(
                  bookId: bookId,
                  vocabularyId: vocabularyId,
                  pending: pending,
                );
            _recordedOccurrenceId = occurrenceId;
            await _loadBookCount();
          }
        case VocabularyState.known:
          await app.vocabulary.setState(
            vocabularyId,
            VocabularyState.known,
          );
        case VocabularyState.newWord:
          break;
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Moved to ${state.label}.')));
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not update word: $error')),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _addDefinition() async {
    final meaningController = TextEditingController();
    final exampleController = TextEditingController();
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add a definition'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: meaningController,
              autofocus: true,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Meaning',
                hintText: 'What does this sense mean to you?',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: exampleController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Example (optional)',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (meaningController.text.trim().isEmpty) return;
              Navigator.pop(context, true);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
    if (result == true) {
      final vocabularyId = await _ensureVocabulary();
      if (vocabularyId != null) {
        await ref
            .read(vocabularyRepositoryProvider)
            .addDefinition(
              vocabularyId: vocabularyId,
              meaning: meaningController.text,
              example: exampleController.text.isEmpty
                  ? null
                  : exampleController.text,
            );
      }
    }
    meaningController.dispose();
    exampleController.dispose();
  }

  Future<void> _fixIdentity(VocabularyData vocabulary) async {
    if (_occurrenceId == null) return;
    final changed = await showDialog<bool>(
      context: context,
      builder: (context) => _FixIdentityDialog(
        vocabulary: vocabulary,
        surfaceForm: widget.match.surfaceForm,
        occurrenceId: _occurrenceId!,
      ),
    );
    if (changed == true && mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Word identity updated.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = CafePalette.of(context);
    final vocabularyId = _vocabularyId;
    final vocab = vocabularyId == null
        ? null
        : ref.watch(vocabularyProvider(vocabularyId)).valueOrNull;
    final state = vocabularyId == null
        ? VocabularyState.newWord
        : ref.watch(vocabularyStateProvider(vocabularyId)).valueOrNull ??
              VocabularyState.newWord;
    final definitions = vocabularyId == null
        ? const <Definition>[]
        : ref.watch(definitionsProvider(vocabularyId)).valueOrNull ??
              const <Definition>[];
    final forms = vocabularyId == null
        ? const <WordForm>[]
        : ref.watch(vocabularyFormsProvider(vocabularyId)).valueOrNull ??
              const <WordForm>[];
    final contexts = vocabularyId == null
        ? const <VocabularyContext>[]
        : ref.watch(vocabularyContextsProvider(vocabularyId)).valueOrNull ??
              const <VocabularyContext>[];
    final card = vocabularyId == null
        ? null
        : ref.watch(fsrsCardProvider(vocabularyId)).valueOrNull;
    final history = vocabularyId == null
        ? const <ReviewLog>[]
        : ref.watch(reviewHistoryProvider(vocabularyId)).valueOrNull ??
              const <ReviewLog>[];
    final lemma = vocab?.lemma ?? widget.match.lemma;
    final senseLabel = vocab?.senseLabel ?? widget.match.senseLabel;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 12, 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            widget.match.surfaceForm,
                            style: Theme.of(context).textTheme.headlineMedium
                                ?.copyWith(fontFamily: 'Literata'),
                          ),
                        ),
                        if (vocabularyId != null &&
                            state != VocabularyState.newWord) ...[
                          const SizedBox(width: 10),
                          StatusChip(state: state),
                        ],
                      ],
                    ),
                    if (lemma != widget.match.surfaceForm.toLowerCase()) ...[
                      const SizedBox(height: 3),
                      Text(
                        'Lemma · $lemma'
                        '${senseLabel == null ? '' : ' · $senseLabel'}',
                        style: Theme.of(context).textTheme.bodySmall
                            ?.copyWith(color: palette.inkMuted),
                      ),
                    ],
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Close',
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 40),
            children: [
              SegmentedButton<VocabularyState>(
                key: const ValueKey('vocabulary-status'),
                emptySelectionAllowed: true,
                segments: const [
                  ButtonSegment(
                    value: VocabularyState.learning,
                    label: Text('Learning'),
                    icon: Icon(Icons.auto_stories_outlined, size: 14),
                  ),
                  ButtonSegment(
                    value: VocabularyState.known,
                    label: Text('Known'),
                    icon: Icon(Icons.check_circle_outline, size: 14),
                  ),
                ],
                selected: state == VocabularyState.learning ||
                        state == VocabularyState.known
                    ? {state}
                    : const <VocabularyState>{},
                onSelectionChanged: _busy
                    ? null
                    : (value) => _setState(value.first),
              ),
              const SizedBox(height: 12),
              Text(
                _vocabularyId == null
                    ? 'This word is not saved yet. A word that is neither '
                          'Learning nor Known stays out of your deck; choose a '
                          'state to keep it.'
                    : 'This state is shared across every book. Learning words '
                          'enter the FSRS review queue and keep the sentence '
                          'they were added from.',
                style: Theme.of(context).textTheme.bodySmall
                    ?.copyWith(color: palette.inkMuted),
              ),
              const SizedBox(height: 28),
              SectionHeader(
                title: 'Meaning',
                action: TextButton.icon(
                  onPressed: _addDefinition,
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Add'),
                ),
              ),
              if (definitions.isEmpty)
                _SoftBox(
                  child: Row(
                    children: [
                      Icon(
                        Icons.menu_book_outlined,
                        size: 18,
                        color: palette.inkMuted,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'No definition yet. Add your own or import a dictionary.',
                          style: TextStyle(color: palette.inkMuted),
                        ),
                      ),
                    ],
                  ),
                )
              else
                ...definitions.map(
                  (definition) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(16, 14, 8, 14),
                      decoration: BoxDecoration(
                        color: palette.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: palette.line),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  definition.meaning,
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(height: 1.5),
                                ),
                                if (definition.example != null &&
                                    definition.example!.isNotEmpty) ...[
                                  const SizedBox(height: 6),
                                  Text(
                                    '“${definition.example}”',
                                    style: TextStyle(
                                      fontFamily: 'Literata',
                                      fontStyle: FontStyle.italic,
                                      color: palette.inkMuted,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          IconButton(
                            tooltip: 'Delete definition',
                            visualDensity: VisualDensity.compact,
                            onPressed: () async {
                              final confirmed = await confirmAction(
                                context,
                                title: 'Delete this definition?',
                                message: definition.meaning,
                                confirmLabel: 'Delete',
                                destructive: true,
                              );
                              if (confirmed) {
                                await ref
                                    .read(vocabularyRepositoryProvider)
                                    .deleteDefinition(definition.id);
                              }
                            },
                            icon: Icon(
                              Icons.close,
                              size: 15,
                              color: palette.inkMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 20),
              SectionHeader(
                title: 'In your books',
                subtitle: _countInBook == null
                    ? null
                    : '$_countInBook ${_countInBook == 1 ? 'occurrence' : 'occurrences'} in this book',
              ),
              if (contexts.isEmpty)
                Text(
                  'No saved sentences yet. Add this word to Learning from the '
                  'reader to keep the sentence you found it in.',
                  style: TextStyle(color: palette.inkMuted),
                )
              else
                ...contexts
                    .take(6)
                    .map(
                      (context) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _SoftBox(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '“${context.context}”',
                                style: const TextStyle(
                                  fontFamily: 'Literata',
                                  fontSize: 14,
                                  height: 1.5,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                '${context.bookTitle} · ${context.chapterTitle}',
                                style: TextStyle(
                                  fontSize: 10.5,
                                  color: palette.inkMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
              if (forms.length > 1) ...[
                const SizedBox(height: 20),
                SectionHeader(title: 'Word forms'),
                Wrap(
                  spacing: 7,
                  runSpacing: 7,
                  children: [
                    for (final form in forms)
                      Chip(
                        label: Text(form.surfaceForm),
                        visualDensity: VisualDensity.compact,
                      ),
                  ],
                ),
              ],
              if (state == VocabularyState.learning) ...[
                const SizedBox(height: 24),
                SectionHeader(
                  title: 'Review schedule',
                  subtitle: 'FSRS keeps this word in Learning only.',
                ),
                _FsrsSummary(card: card, history: history),
              ],
              if (_occurrenceId != null) ...[
                const SizedBox(height: 26),
                OutlinedButton.icon(
                  onPressed: vocab == null ? null : () => _fixIdentity(vocab),
                  icon: const Icon(Icons.call_split, size: 17),
                  label: const Text('Fix word identity'),
                ),
                const SizedBox(height: 6),
                Text(
                  'Is this a different sense, such as “saw” (a tool) instead of '
                  '“see”? You can correct just this occurrence, this book, or '
                  'the global form association.',
                  style: Theme.of(context).textTheme.bodySmall
                      ?.copyWith(color: palette.inkMuted),
                ),
              ],
              const SizedBox(height: 20),
            ],
          ),
        ),
      ],
    );
  }
}

class _SoftBox extends StatelessWidget {
  const _SoftBox({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final palette = CafePalette.of(context);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: palette.line),
      ),
      child: child,
    );
  }
}

class _FsrsSummary extends StatelessWidget {
  const _FsrsSummary({required this.card, required this.history});
  final FsrsCard? card;
  final List<ReviewLog> history;

  @override
  Widget build(BuildContext context) {
    final palette = CafePalette.of(context);
    if (card == null) {
      return Text(
        'No review card yet.',
        style: TextStyle(color: palette.inkMuted),
      );
    }
    final format = DateFormat.yMMMd().add_jm();
    return _SoftBox(
      child: Column(
        children: [
          _InfoRow(label: 'Next review', value: format.format(card!.due)),
          _InfoRow(
            label: 'Last review',
            value: card!.lastReview == null
                ? 'Not reviewed yet'
                : format.format(card!.lastReview!),
          ),
          _InfoRow(label: 'Repetitions', value: '${card!.reps}'),
          _InfoRow(label: 'Lapses', value: '${card!.lapses}'),
          _InfoRow(
            label: 'Stability / difficulty',
            value:
                '${card!.stability.toStringAsFixed(2)} d · '
                '${card!.difficulty.toStringAsFixed(2)}',
          ),
          if (history.isNotEmpty) ...[
            Divider(color: palette.line, height: 24),
            _InfoRow(
              label: 'Last rating',
              value: ReviewRating.fromValue(history.first.rating).label,
            ),
          ],
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final palette = CafePalette.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(fontSize: 12, color: palette.inkMuted),
            ),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _FixIdentityDialog extends ConsumerStatefulWidget {
  const _FixIdentityDialog({
    required this.vocabulary,
    required this.surfaceForm,
    required this.occurrenceId,
  });

  final VocabularyData vocabulary;
  final String surfaceForm;
  final String occurrenceId;

  @override
  ConsumerState<_FixIdentityDialog> createState() => _FixIdentityDialogState();
}

class _FixIdentityDialogState extends ConsumerState<_FixIdentityDialog> {
  late Future<List<_IdentityCandidate>> _candidatesFuture;
  _IdentityCandidate? _selected;
  CorrectionScope _scope = CorrectionScope.occurrence;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _candidatesFuture = _loadCandidates();
  }

  Future<List<_IdentityCandidate>> _loadCandidates() async {
    final repo = ref.read(vocabularyRepositoryProvider);
    final app = ref.read(appServicesProvider);
    final hypotheses = repo.lemmatizerCandidates(widget.surfaceForm);
    final lemmas = <String>[];
    for (final hypothesis in hypotheses) {
      if (!lemmas.contains(hypothesis.lemma)) lemmas.add(hypothesis.lemma);
    }
    final surface = widget.surfaceForm.toLowerCase();
    if (!lemmas.contains(surface)) lemmas.add(surface);
    final result = <_IdentityCandidate>[];
    for (final lemma in lemmas) {
      final existing = await repo.findVocabularyByLemma(lemma);
      final senses = await app.definitionsFor(lemma);
      DictionarySense? first;
      if (senses.isNotEmpty) {
        first = senses.firstWhere(
          (sense) => sense.partOfSpeech == 'noun',
          orElse: () => senses.first,
        );
      }
      result.add(
        _IdentityCandidate(
          lemma: lemma,
          meaning: first?.meaning,
          partOfSpeech: first?.partOfSpeech,
          existing: existing,
          isSurface: lemma == surface,
        ),
      );
    }
    return result;
  }

  Future<void> _apply() async {
    final candidate = _selected;
    if (candidate == null || _saving) return;
    setState(() => _saving = true);
    try {
      final repo = ref.read(vocabularyRepositoryProvider);
      var targetId = candidate.existing?.id;
      targetId ??= await repo.createVocabulary(
        lemma: candidate.lemma,
        definition: candidate.meaning,
        surfaceForm: widget.surfaceForm,
        addForm: false,
      );
      await repo.correctOccurrence(
        occurrenceId: widget.occurrenceId,
        newVocabularyId: targetId,
        scope: _scope,
      );
      if (mounted) Navigator.pop(context, true);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not update word: $error')),
        );
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = CafePalette.of(context);
    return AlertDialog(
      title: const Text('Which word is this?'),
      content: SizedBox(
        width: 480,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '“${widget.surfaceForm}” can belong to more than one vocabulary '
                'entry. Pick the intended meaning and how widely to apply it.',
                style: TextStyle(color: palette.inkMuted, fontSize: 13),
              ),
              const SizedBox(height: 14),
              FutureBuilder<List<_IdentityCandidate>>(
                future: _candidatesFuture,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Padding(
                      padding: EdgeInsets.all(24),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  final candidates = snapshot.data!;
                  if (candidates.isNotEmpty) {
                    _selected ??= candidates.firstWhere(
                      (candidate) =>
                          candidate.existing?.id == widget.vocabulary.id,
                      orElse: () => candidates.first,
                    );
                  }
                  return RadioGroup<_IdentityCandidate>(
                    groupValue: _selected,
                    onChanged: (value) => setState(() => _selected = value),
                    child: Column(
                      children: [
                        for (final candidate in candidates)
                          RadioListTile<_IdentityCandidate>(
                            value: candidate,
                            contentPadding: EdgeInsets.zero,
                            dense: true,
                            title: Text(
                              candidate.lemma +
                                  (candidate.existing?.senseLabel == null ||
                                          candidate
                                              .existing!
                                              .senseLabel!
                                              .isEmpty
                                      ? ''
                                      : ' · ${candidate.existing!.senseLabel}'),
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (candidate.meaning != null)
                                  Text(
                                    candidate.meaning!,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                const SizedBox(height: 2),
                                Text(
                                  [
                                    if (candidate.partOfSpeech != null)
                                      candidate.partOfSpeech!,
                                    if (candidate.isSurface) 'surface form',
                                    if (candidate.existing != null)
                                      'existing entry'
                                    else
                                      'new entry',
                                  ].join(' · '),
                                  style: TextStyle(
                                    fontSize: 10.5,
                                    color: palette.inkMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 14),
              Text(
                'APPLY TO',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.w700,
                  color: palette.inkMuted,
                ),
              ),
              const SizedBox(height: 8),
              SegmentedButton<CorrectionScope>(
                showSelectedIcon: false,
                segments: const [
                  ButtonSegment(
                    value: CorrectionScope.occurrence,
                    label: Text('This spot'),
                  ),
                  ButtonSegment(
                    value: CorrectionScope.book,
                    label: Text('This book'),
                  ),
                  ButtonSegment(
                    value: CorrectionScope.globalForm,
                    label: Text('Everywhere'),
                  ),
                ],
                selected: {_scope},
                onSelectionChanged: (value) =>
                    setState(() => _scope = value.first),
              ),
              const SizedBox(height: 8),
              Text(switch (_scope) {
                CorrectionScope.occurrence => 'Only this occurrence changes. Other appearances and the global word form stay untouched.',
                CorrectionScope.book => 'Every appearance of this spelling in this book changes. Other books are untouched.',
                CorrectionScope.globalForm => 'The default association for this spelling changes everywhere. Individual manual corrections are preserved.',
              }, style: TextStyle(fontSize: 11.5, color: palette.inkMuted)),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _saving || _selected == null ? null : _apply,
          child: _saving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Apply'),
        ),
      ],
    );
  }
}

class _IdentityCandidate {
  const _IdentityCandidate({
    required this.lemma,
    required this.meaning,
    required this.partOfSpeech,
    required this.existing,
    required this.isSurface,
  });

  final String lemma;
  final String? meaning;
  final String? partOfSpeech;
  final VocabularyData? existing;
  final bool isSurface;
}
