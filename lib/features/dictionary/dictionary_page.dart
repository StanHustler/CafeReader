import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/design/app_theme.dart';
import '../../core/design/page_layout.dart';
import '../../core/design/page_pager.dart';
import '../../data/repository/dictionary_repository.dart';
import 'dictionary_icon.dart';
import 'dictionary_manager_sheet.dart';

/// The Dictionary destination.
///
/// A persistent search box sits above a paged list. Each enabled dictionary
/// contributes one combined result row: meanings are merged and parts of
/// speech are not split into separate entries.
class DictionaryPage extends ConsumerStatefulWidget {
  const DictionaryPage({super.key});

  @override
  ConsumerState<DictionaryPage> createState() => _DictionaryPageState();
}

class _DictionaryPageState extends ConsumerState<DictionaryPage> {
  static const double _rowExtent = 104;
  static const double _pagerRoom = 64;

  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  Timer? _debounce;
  String _query = '';
  bool _searching = false;
  String? _searchError;
  List<_DictionaryResult> _results = const [];
  int _page = 0;
  int _generation = 0;

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  void _onQueryChanged(String value) {
    _debounce?.cancel();
    // Invalidate any in-flight lookup for the previous spelling.
    _generation++;
    final query = value.trim();
    if (query.isEmpty) {
      setState(() {
        _query = '';
        _results = const [];
        _searching = false;
        _searchError = null;
        _page = 0;
      });
      return;
    }
    setState(() {
      _query = query;
      _page = 0;
    });
    _debounce = Timer(const Duration(milliseconds: 300), () => _search(query));
  }

  void _clearQuery() {
    _searchController.clear();
    _onQueryChanged('');
    _searchFocus.requestFocus();
  }

  Future<void> _openAdd() async {
    await showAddDictionarySheet(context);
    if (!mounted) return;
    if (_query.isNotEmpty) {
      await _search(_query);
    }
  }

  Future<void> _openManager() async {
    await showDictionaryManager(context);
    if (!mounted) return;
    if (_query.isNotEmpty) {
      await _search(_query);
    }
  }

  Future<void> _search(String raw) async {
    final word = raw.trim().toLowerCase();
    if (word.isEmpty) return;
    final generation = ++_generation;
    setState(() {
      _searching = true;
      _searchError = null;
    });
    try {
      final repository = ref.read(dictionaryRepositoryProvider);
      final app = ref.read(appServicesProvider);
      final sources = await repository.watchDictionaries().first;
      final local = await repository.localLookups(word);
      final results = <_DictionaryResult>[];
      for (final source in sources) {
        if (!source.enabled) continue;
        switch (source.kind) {
          case DictionaryKind.builtin:
            final senses = await app.builtinDefinitionsFor(word);
            final meanings = _merge(senses.map((sense) => sense.meaning));
            if (meanings.isNotEmpty) {
              results.add(
                _DictionaryResult(source: source, meanings: meanings),
              );
            }
          case DictionaryKind.local:
            final entries = local[source.id] ?? const [];
            final meanings = _merge(entries.map((entry) => entry.meaning));
            if (meanings.isNotEmpty) {
              results.add(
                _DictionaryResult(source: source, meanings: meanings),
              );
            }
          case DictionaryKind.online:
            break;
        }
      }
      final onlineSources = [
        for (final source in sources)
          if (source.enabled && source.kind == DictionaryKind.online) source,
      ];
      final online = await Future.wait([
        for (final source in onlineSources)
          () async {
            try {
              final entries = await repository.fetchOnline(source, word);
              final meanings = _merge(entries.map((entry) => entry.meaning));
              if (meanings.isEmpty) return null;
              return _DictionaryResult(source: source, meanings: meanings);
            } catch (error) {
              return _DictionaryResult(
                source: source,
                meanings: const [],
                error: '$error',
              );
            }
          }(),
      ]);
      results.addAll(online.whereType<_DictionaryResult>());
      if (!mounted || generation != _generation) return;
      setState(() {
        _searching = false;
        _results = results;
        _page = 0;
      });
    } catch (error) {
      if (!mounted || generation != _generation) return;
      setState(() {
        _searching = false;
        _searchError = '$error';
      });
    }
  }

  static List<String> _merge(Iterable<String> values) {
    final seen = <String>{};
    final out = <String>[];
    for (final raw in values) {
      final value = raw.trim();
      if (value.isEmpty || !seen.add(value.toLowerCase())) continue;
      out.add(value);
      if (out.length >= 8) break;
    }
    return out;
  }

  @override
  Widget build(BuildContext context) {
    final palette = CafePalette.of(context);
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 700;
            final column = PageColumn.fit(constraints.maxWidth);
            final horizontal = column.contentInset;
            return Padding(
              padding: EdgeInsets.fromLTRB(
                horizontal,
                PageGeometry.top,
                horizontal,
                0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Dictionary',
                          style: Theme.of(context).textTheme.displayMedium
                              ?.copyWith(
                                fontSize: compact ? 30 : 36,
                                letterSpacing: -0.8,
                                color: palette.ink,
                              ),
                        ),
                      ),
                      BubbleBar(
                        children: [
                          BubbleIconButton(
                            icon: Icons.add_rounded,
                            tooltip: 'Add dictionary',
                            onTap: _openAdd,
                          ),
                          BubbleIconButton(
                            icon: Icons.tune_rounded,
                            tooltip: 'Manage dictionaries',
                            onTap: _openManager,
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  BubbleSearchField(
                    controller: _searchController,
                    focusNode: _searchFocus,
                    hintText: 'Look up a word',
                    query: _query,
                    onChanged: _onQueryChanged,
                    onClear: _clearQuery,
                  ),
                  const SizedBox(height: 14),
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, inner) {
                        final rows = math.max(
                          1,
                          ((inner.maxHeight - _pagerRoom) / _rowExtent).floor(),
                        );
                        final pageCount = _results.isEmpty
                            ? 1
                            : ((_results.length + rows - 1) ~/ rows);
                        final pageIndex = _page.clamp(0, pageCount - 1);
                        final pageResults = _results
                            .skip(pageIndex * rows)
                            .take(rows)
                            .toList(growable: false);

                        final Widget body;
                        if (_searching) {
                          body = const Center(
                            child: CircularProgressIndicator(),
                          );
                        } else if (_query.isEmpty) {
                          body = const _DictionaryMessage(
                            icon: Icons.translate,
                            title: 'Look up a word',
                            body:
                                'Type a word above to see one combined result '
                                'from every enabled dictionary.',
                          );
                        } else if (_searchError != null) {
                          body = _DictionaryMessage(
                            icon: Icons.error_outline,
                            title: 'Could not search',
                            body: _searchError!,
                          );
                        } else if (_results.isEmpty) {
                          body = _DictionaryMessage(
                            icon: Icons.search_off,
                            title: 'No entry for “$_query”',
                            body:
                                'No enabled dictionary has a translation for '
                                'this word. Check the spelling or add another '
                                'source from the + button.',
                          );
                        } else {
                          body = Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              for (
                                var index = 0;
                                index < pageResults.length;
                                index++
                              )
                                SizedBox(
                                  height: _rowExtent,
                                  child: Column(
                                    children: [
                                      Expanded(
                                        child: Align(
                                          alignment: Alignment.topCenter,
                                          child: ConstrainedBox(
                                            constraints: const BoxConstraints(
                                              maxWidth:
                                                  PageGeometry.innerMaxWidth,
                                            ),
                                            child: _DictionaryResultRow(
                                              result: pageResults[index],
                                            ),
                                          ),
                                        ),
                                      ),
                                      if (index < pageResults.length - 1)
                                        Divider(
                                          height: 1,
                                          thickness: 1,
                                          color: palette.line,
                                        ),
                                    ],
                                  ),
                                ),
                            ],
                          );
                        }

                        return PageFlipOverlay(
                          pageIndex: pageIndex,
                          pageCount: pageCount,
                          onPrevious: pageIndex > 0
                              ? () => setState(() => _page = pageIndex - 1)
                              : null,
                          onNext: pageIndex < pageCount - 1
                              ? () => setState(() => _page = pageIndex + 1)
                              : null,
                          right: 0,
                          child: body,
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _DictionaryResult {
  const _DictionaryResult({
    required this.source,
    required this.meanings,
    this.error,
  });

  final DictionarySource source;
  final List<String> meanings;
  final String? error;
}

class _DictionaryResultRow extends StatelessWidget {
  const _DictionaryResultRow({required this.result});

  final _DictionaryResult result;

  @override
  Widget build(BuildContext context) {
    final palette = CafePalette.of(context);
    final error = result.error;
    final source = result.source;
    final meaning = error ?? result.meanings.join(' · ');
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 14, 12, 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DictionaryIcon(kind: source.kind),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        source.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: 'Literata',
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.1,
                          color: palette.ink,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      source.kind.label,
                      style: TextStyle(fontSize: 10.5, color: palette.inkMuted),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  meaning,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12.5,
                    height: 1.35,
                    color: error == null ? palette.inkMuted : palette.danger,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DictionaryMessage extends StatelessWidget {
  const _DictionaryMessage({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final palette = CafePalette.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 380),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 34, color: palette.inkMuted),
              const SizedBox(height: 16),
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                body,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium
                    ?.copyWith(color: palette.inkMuted, height: 1.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
