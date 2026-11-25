import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/design/app_theme.dart';
import '../../core/design/common_widgets.dart';
import '../../core/design/subpage.dart';
import '../../data/repository/review_repository.dart';
import '../../data/repository/settings_repository.dart';
import '../../domain/fsrs/fsrs_scheduler.dart';

class ReviewSessionPage extends ConsumerStatefulWidget {
  const ReviewSessionPage({super.key});

  @override
  ConsumerState<ReviewSessionPage> createState() => _ReviewSessionPageState();
}

class _ReviewSessionPageState extends ConsumerState<ReviewSessionPage> {
  bool _loading = true;
  Object? _error;
  List<ReviewItem> _items = const [];
  int _index = 0;
  int _reviewed = 0;
  bool _revealed = false;
  bool _rating = false;
  bool _loadingDefinition = false;
  String? _definition;
  FsrsSettings _settings = const FsrsSettings();
  bool _limitsReached = false;

  @override
  void initState() {
    super.initState();
    _loadQueue();
  }

  Future<void> _loadQueue() async {
    try {
      final app = ref.read(appServicesProvider);
      final settingsMap = await app.settings.getAll();
      final settings = app.settings.fsrsSettingsFromMap(settingsMap);
      final due = await app.review.getDueItems(
        limit: math.max(1, settings.dailyNewLimit + settings.dailyReviewLimit),
      );
      final newReviewedToday = await app.review.newReviewedTodayCount();
      var newAllowance = math.max(0, settings.dailyNewLimit - newReviewedToday);
      final queue = <ReviewItem>[];
      for (final item in due) {
        if (queue.length >= settings.dailyReviewLimit) break;
        if (item.card.reps == 0) {
          if (newAllowance <= 0) continue;
          newAllowance--;
        }
        queue.add(item);
      }
      if (!mounted) return;
      setState(() {
        _items = queue;
        _settings = settings;
        _loading = false;
        _limitsReached = queue.isEmpty && due.isNotEmpty;
      });
    } catch (error) {
      if (mounted) {
        setState(() {
          _error = error;
          _loading = false;
        });
      }
    }
  }

  ReviewItem? get _current => _index < _items.length ? _items[_index] : null;

  Future<void> _reveal() async {
    final item = _current;
    if (item == null || _revealed || _loadingDefinition) return;
    setState(() {
      _revealed = true;
      _loadingDefinition = item.definition == null;
    });
    if (item.definition != null) {
      _definition = item.definition;
      setState(() => _loadingDefinition = false);
      return;
    }
    try {
      final app = ref.read(appServicesProvider);
      final senses = await app.definitionsFor(item.vocabulary.lemma);
      String? meaning;
      if (senses.isNotEmpty) {
        meaning = senses.first.meaning;
        await app.vocabulary.addDefinition(
          vocabularyId: item.vocabulary.id,
          meaning: meaning,
        );
      }
      if (!mounted) return;
      setState(() {
        _definition = meaning;
        _loadingDefinition = false;
      });
    } catch (error) {
      if (mounted) {
        setState(() {
          _loadingDefinition = false;
          _definition = null;
        });
      }
    }
  }

  Future<void> _addMeaning() async {
    final item = _current;
    if (item == null) return;
    final meaningController = TextEditingController();
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add a meaning'),
        content: TextField(
          controller: meaningController,
          autofocus: true,
          maxLines: 3,
          decoration: const InputDecoration(labelText: 'Meaning'),
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
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (result == true) {
      final meaning = meaningController.text.trim();
      await ref
          .read(vocabularyRepositoryProvider)
          .addDefinition(vocabularyId: item.vocabulary.id, meaning: meaning);
      if (mounted) setState(() => _definition = meaning);
    }
    meaningController.dispose();
  }

  Future<void> _rate(ReviewRating rating) async {
    final item = _current;
    if (item == null || !_revealed || _rating) return;
    setState(() => _rating = true);
    try {
      await ref
          .read(reviewRepositoryProvider)
          .review(
            vocabularyId: item.vocabulary.id,
            rating: rating,
            desiredRetention: _settings.desiredRetention,
          );
      if (!mounted) return;
      setState(() {
        _reviewed++;
        _index++;
        _revealed = false;
        _definition = null;
        _loadingDefinition = false;
        _rating = false;
      });
    } catch (error) {
      if (mounted) {
        setState(() => _rating = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not save review: $error')),
        );
      }
    }
  }

  KeyEventResult _handleKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent || _rating || _loading) {
      return KeyEventResult.ignored;
    }
    if (event.logicalKey == LogicalKeyboardKey.space) {
      if (!_revealed) _reveal();
      return KeyEventResult.handled;
    }
    if (_revealed) {
      final ratings = [
        LogicalKeyboardKey.digit1,
        LogicalKeyboardKey.digit2,
        LogicalKeyboardKey.digit3,
        LogicalKeyboardKey.digit4,
      ];
      final index = ratings.indexOf(event.logicalKey);
      if (index >= 0) {
        _rate(ReviewRating.values[index]);
        return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final palette = CafePalette.of(context);
    final total = _items.length;
    final complete =
        !_loading && _error == null && total > 0 && _index >= total;
    return PopScope(
      canPop: !_rating,
      child: SubpageScaffold(
        title: _loading ? 'Review' : 'Review · $_reviewed / $total',
        style: SubpageHeaderStyle.compact,
        scrollable: false,
        headerPadding: const EdgeInsets.fromLTRB(8, 4, 20, 4),
        backIcon: Icons.close,
        backTooltip: 'Close review',
        canGoBack: !_rating,
        onBack: () => Navigator.pop(context),
        actions: [
          if (total > 0 && !_loading)
            Text(
              'Limit ${_settings.dailyReviewLimit}',
              style: TextStyle(fontSize: 11, color: palette.inkMuted),
            ),
        ],
        child: Focus(
          autofocus: true,
          onKeyEvent: _handleKey,
          child: SafeArea(
            top: false,
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                ? EmptyState(
                    icon: Icons.error_outline,
                    title: 'Could not start review',
                    message: '$_error',
                    action: FilledButton(
                      onPressed: () {
                        setState(() {
                          _loading = true;
                          _error = null;
                        });
                        _loadQueue();
                      },
                      child: const Text('Try again'),
                    ),
                  )
                : total == 0
                ? EmptyState(
                    icon: _limitsReached
                        ? Icons.hourglass_empty
                        : Icons.check_circle_outline,
                    title: _limitsReached
                        ? 'Daily review limit reached'
                        : 'All caught up',
                    message: _limitsReached
                        ? 'You have reviewed your daily allowance. Come back tomorrow or adjust the limits in Settings.'
                        : 'No Learning words are due right now. New words enter this queue only when you add them to Learning.',
                    action: FilledButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Back to Deck'),
                    ),
                  )
                : complete
                ? _SessionComplete(
                    reviewed: _reviewed,
                    onDone: () => Navigator.pop(context),
                  )
                : _ReviewCard(
                    item: _current!,
                    position: _index + 1,
                    total: total,
                    revealed: _revealed,
                    definition: _definition,
                    loadingDefinition: _loadingDefinition,
                    rating: _rating,
                    onReveal: _reveal,
                    onAddMeaning: _addMeaning,
                    onRate: _rate,
                  ),
          ),
        ),
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({
    required this.item,
    required this.position,
    required this.total,
    required this.revealed,
    required this.definition,
    required this.loadingDefinition,
    required this.rating,
    required this.onReveal,
    required this.onAddMeaning,
    required this.onRate,
  });

  final ReviewItem item;
  final int position;
  final int total;
  final bool revealed;
  final String? definition;
  final bool loadingDefinition;
  final bool rating;
  final VoidCallback onReveal;
  final VoidCallback onAddMeaning;
  final ValueChanged<ReviewRating> onRate;

  @override
  Widget build(BuildContext context) {
    final palette = CafePalette.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 660),
          child: Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: (position - 1) / total,
                  minHeight: 4,
                  backgroundColor: palette.surfaceMuted,
                ),
              ),
              const SizedBox(height: 18),
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(24, 18, 24, 18),
                  decoration: BoxDecoration(
                    color: palette.surface,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: palette.line),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'LEARNING · FSRS',
                        style: TextStyle(
                          fontSize: 10,
                          letterSpacing: 1.5,
                          fontWeight: FontWeight.w700,
                          color: palette.inkMuted,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 520),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            item.vocabulary.lemma,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.displayMedium
                                ?.copyWith(
                                  fontFamily: 'Literata',
                                  fontSize: 40,
                                ),
                          ),
                        ),
                      ),
                      if (item.vocabulary.senseLabel != null &&
                          item.vocabulary.senseLabel!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          item.vocabulary.senseLabel!,
                          style: TextStyle(
                            fontSize: 12,
                            color: palette.inkMuted,
                          ),
                        ),
                      ],
                      const SizedBox(height: 8),
                      Text(
                        '${item.occurrenceCount} '
                        '${item.occurrenceCount == 1 ? 'mention' : 'mentions'} in '
                        '${item.bookCount} ${item.bookCount == 1 ? 'book' : 'books'}',
                        style: TextStyle(fontSize: 11, color: palette.inkMuted),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: revealed
                            ? _DefinitionArea(
                                definition: definition,
                                loading: loadingDefinition,
                                onAddMeaning: onAddMeaning,
                              )
                            : _RevealArea(onReveal: onReveal),
                      ),
                    ],
                  ),
                ),
              ),
              if (revealed) ...[
                const SizedBox(height: 14),
                _RatingArea(rating: rating, onRate: onRate, palette: palette),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _RevealArea extends StatelessWidget {
  const _RevealArea({required this.onReveal});

  final VoidCallback onReveal;

  @override
  Widget build(BuildContext context) {
    final palette = CafePalette.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Recall the meaning before revealing it.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: palette.inkMuted),
          ),
          const SizedBox(height: 14),
          FilledButton.icon(
            onPressed: onReveal,
            icon: const Icon(Icons.visibility_outlined, size: 18),
            label: const Text('Reveal meaning'),
          ),
          const SizedBox(height: 8),
          Text(
            'Press Space',
            style: TextStyle(
              fontSize: 10,
              color: palette.inkMuted.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}

class _DefinitionArea extends StatelessWidget {
  const _DefinitionArea({
    required this.definition,
    required this.loading,
    required this.onAddMeaning,
  });

  final String? definition;
  final bool loading;
  final VoidCallback onAddMeaning;

  @override
  Widget build(BuildContext context) {
    final palette = CafePalette.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: palette.surfaceMuted,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: palette.line),
      ),
      child: loading
          ? const Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          : definition == null
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'No definition is saved for this word.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: palette.inkMuted),
                  ),
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: onAddMeaning,
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('Add a meaning'),
                  ),
                ],
              ),
            )
          : LayoutBuilder(
              builder: (context, constraints) {
                const lineHeight = 15 * 1.55;
                final maxLines = math.max(
                  1,
                  (constraints.maxHeight / lineHeight).floor(),
                );
                return Center(
                  child: Text(
                    definition!,
                    maxLines: maxLines,
                    overflow: TextOverflow.fade,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 15, height: 1.55),
                  ),
                );
              },
            ),
    );
  }
}

class _RatingArea extends StatelessWidget {
  const _RatingArea({
    required this.rating,
    required this.onRate,
    required this.palette,
  });

  final bool rating;
  final ValueChanged<ReviewRating> onRate;
  final CafeColors palette;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'How well did you remember?',
          style: TextStyle(fontSize: 12, color: palette.inkMuted),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            for (var i = 0; i < ReviewRating.values.length; i++) ...[
              if (i > 0) const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  onPressed: rating
                      ? null
                      : () => onRate(ReviewRating.values[i]),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      vertical: 13,
                      horizontal: 4,
                    ),
                    side: BorderSide(
                      color: _ratingColor(
                        palette,
                        ReviewRating.values[i],
                      ).withValues(alpha: 0.5),
                    ),
                    foregroundColor: _ratingColor(
                      palette,
                      ReviewRating.values[i],
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        ReviewRating.values[i].label,
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${i + 1}',
                        style: TextStyle(fontSize: 9, color: palette.inkMuted),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 10),
        Text(
          'Again keeps the word in relearning; it never becomes Known automatically.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 10.5, color: palette.inkMuted),
        ),
      ],
    );
  }
}

Color _ratingColor(CafeColors palette, ReviewRating rating) {
  return switch (rating) {
    ReviewRating.again => palette.danger,
    ReviewRating.hard => palette.ink,
    ReviewRating.good => palette.accent,
    ReviewRating.easy => palette.ink,
  };
}

class _SessionComplete extends StatelessWidget {
  const _SessionComplete({required this.reviewed, required this.onDone});
  final int reviewed;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    final palette = CafePalette.of(context);
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 78,
                height: 78,
                decoration: BoxDecoration(
                  color: palette.accentSoft,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.local_cafe_outlined,
                  color: palette.accent,
                  size: 34,
                ),
              ),
              const SizedBox(height: 22),
              Text(
                'A good session.',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'You reviewed $reviewed '
                '${reviewed == 1 ? 'word' : 'words'}. The next intervals are saved.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium
                    ?.copyWith(color: palette.inkMuted),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: onDone,
                child: const Text('Back to Deck'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
