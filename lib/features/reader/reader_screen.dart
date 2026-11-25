import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/database/app_database.dart';
import '../../core/design/app_theme.dart';
import '../../core/design/common_widgets.dart';
import '../../core/design/word_mark.dart';
import '../../core/platform/window_chrome.dart';
import '../../core/reader/layout_signature.dart';
import '../../core/reader/page_content.dart';
import '../../core/reader/pagination_engine.dart';
import '../../data/repository/library_repository.dart';
import '../../data/repository/settings_repository.dart';
import '../../data/repository/vocabulary_repository.dart';
import '../../domain/lemmatizer/tokenizer.dart';
import '../vocabulary/vocabulary_panel.dart';
import 'reader_quick_settings.dart';

class ReaderScreen extends ConsumerStatefulWidget {
  const ReaderScreen({super.key, required this.bookId, this.chapterId});

  final String bookId;
  final String? chapterId;

  @override
  ConsumerState<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends ConsumerState<ReaderScreen>
    with WidgetsBindingObserver {
  Book? _book;
  List<Chapter> _chapters = const [];
  int _chapterIndex = 0;
  Chapter? _chapter;
  List<PageContent> _pages = const [];
  int _pageIndex = 0;
  List<ChapterOccurrence> _occurrences = const [];
  String? _layoutKey;
  String? _requestedLayoutKey;
  bool _paginating = false;
  bool _turning = false;
  bool _closing = false;
  bool _initializing = true;
  Object? _error;
  _StartTarget? _startTarget;
  _WordTap? _focusedWord;
  int _paginationToken = 0;
  Timer? _paginationDebounce;

  static const PaginationEngine _paginationEngine = PaginationEngine();
  static const MethodChannel _volumeChannel = MethodChannel(
    'cafereader/volume_keys',
  );
  bool _volumeKeysEnabled = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _volumeChannel.setMethodCallHandler((call) async {
      if (call.method == 'volumeUp') {
        await _previousPage();
      } else if (call.method == 'volumeDown') {
        await _nextPage();
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final settings = ref.read(readerSettingsProvider).valueOrNull;
      _syncVolumeKeys(settings?.volumeKeysTurnPages ?? false);
    });
    _initialize();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _paginationDebounce?.cancel();
    _setVolumeKeysEnabled(false);
    _volumeChannel.setMethodCallHandler(null);
    super.dispose();
  }

  void _syncVolumeKeys(bool enabled) {
    if (_volumeKeysEnabled == enabled) return;
    _volumeKeysEnabled = enabled;
    _setVolumeKeysEnabled(enabled);
  }

  Future<void> _setVolumeKeysEnabled(bool enabled) async {
    try {
      await _volumeChannel.invokeMethod<void>('setEnabled', enabled);
    } catch (_) {
      // Not Android, or the native channel is unavailable.
    }
  }

  Future<T> _withVolumeKeysPaused<T>(Future<T> Function() action) async {
    final restore = _volumeKeysEnabled;
    if (restore) await _setVolumeKeysEnabled(false);
    try {
      return await action();
    } finally {
      if (restore) await _setVolumeKeysEnabled(true);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _saveCurrentProgress();
    }
  }

  Future<void> _initialize() async {
    try {
      final library = ref.read(libraryRepositoryProvider);
      final book = await library.getBook(widget.bookId);
      final chapters = await library.getChapters(widget.bookId);
      if (book == null || chapters.isEmpty) {
        throw StateError('This book has no readable chapters.');
      }
      var index = 0;
      if (widget.chapterId != null) {
        final found = chapters.indexWhere(
          (chapter) => chapter.id == widget.chapterId,
        );
        if (found >= 0) index = found;
      } else {
        final latest = await library.getLatestProgress(widget.bookId);
        if (latest != null) {
          final found = chapters.indexWhere(
            (chapter) => chapter.id == latest.chapterId,
          );
          if (found >= 0) index = found;
        }
      }
      if (!mounted) return;
      setState(() {
        _book = book;
        _chapters = chapters;
        _chapterIndex = index;
        _initializing = false;
      });
      await _switchChapter(index, useSavedProgress: true, saveCurrent: false);
    } catch (error) {
      if (mounted) {
        setState(() {
          _error = error;
          _initializing = false;
        });
      }
    }
  }

  Future<void> _switchChapter(
    int index, {
    required bool useSavedProgress,
    bool startAtEnd = false,
    bool saveCurrent = true,
  }) async {
    if (index < 0 || index >= _chapters.length) return;
    if (saveCurrent) {
      await _saveCurrentProgress();
    }
    final chapter = _chapters[index];
    ReadingAnchor? progress;
    if (useSavedProgress) {
      progress = await ref
          .read(libraryRepositoryProvider)
          .getProgressForChapter(widget.bookId, chapter.id);
    }
    if (!mounted) return;
    setState(() {
      _chapterIndex = index;
      _chapter = chapter;
      _occurrences = const [];
      _pages = const [];
      _pageIndex = 0;
      _layoutKey = null;
      _requestedLayoutKey = null;
      _paginating = false;
      _startTarget = _StartTarget(
        paragraph: progress?.anchorParagraph,
        offset: progress?.anchorOffset,
        cachedPageIndex: progress?.cachedPageIndex,
        startAtEnd: startAtEnd,
      );
    });
    unawaited(_loadChapterMarks(chapter));
    // Force the layout builder to ask for pagination again.
    if (mounted) setState(() {});
  }

  void _ensurePagination({
    required LayoutSignature signature,
    required double width,
    required double height,
    required TextScaler textScaler,
    required TextStyle textStyle,
    required ReaderSettings settings,
  }) {
    final chapter = _chapter;
    if (chapter == null || _closing) return;
    final key = '${chapter.id}|${signature.key}';
    if (_requestedLayoutKey == key) return;
    _requestedLayoutKey = key;

    void run() {
      if (!mounted || _closing) return;
      _paginateChapter(
        signature: signature,
        key: key,
        width: width,
        height: height,
        textScaler: textScaler,
        textStyle: textStyle,
        settings: settings,
      );
    }

    // The first layout paginates right away. Later layout changes (font
    // settings and especially live window resizing) are debounced so one
    // expensive pagination runs after the window settles instead of one per
    // frame.
    if (_layoutKey == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => run());
      return;
    }
    _paginationDebounce?.cancel();
    _paginationDebounce = Timer(const Duration(milliseconds: 250), () {
      WidgetsBinding.instance.addPostFrameCallback((_) => run());
    });
  }

  Future<void> _paginateChapter({
    required LayoutSignature signature,
    required String key,
    required double width,
    required double height,
    required TextScaler textScaler,
    required TextStyle textStyle,
    required ReaderSettings settings,
  }) async {
    final chapter = _chapter;
    if (chapter == null || _closing) return;
    final token = ++_paginationToken;
    _StartTarget? target = _startTarget;
    if (target == null &&
        _pages.isNotEmpty &&
        _layoutKey != null &&
        _pageIndex < _pages.length) {
      final current = _pages[_pageIndex];
      target = _StartTarget(
        paragraph: current.startParagraph,
        offset: current.startOffset,
        cachedPageIndex: _pageIndex,
      );
    }
    setState(() => _paginating = true);
    try {
      final reader = ref.read(readerRepositoryProvider);
      var pages = await reader.loadPagination(
        chapterId: chapter.id,
        content: chapter.content,
        layoutSignature: signature.key,
      );
      if (pages == null || pages.isEmpty) {
        pages = _paginationEngine.paginate(
          content: chapter.content,
          textStyle: textStyle,
          width: width,
          height: height,
          paragraphSpacing: settings.paragraphSpacing,
          textScaler: textScaler,
        );
        // Do not persist pages from a layout that has already been superseded
        // by another resize; only the final layout is worth caching.
        if (!mounted ||
            token != _paginationToken ||
            _requestedLayoutKey != key ||
            _closing) {
          return;
        }
        await reader.savePagination(
          chapterId: chapter.id,
          layoutSignature: signature.key,
          pages: pages,
        );
      }
      if (!mounted ||
          token != _paginationToken ||
          _requestedLayoutKey != key ||
          _closing) {
        return;
      }
      int pageIndex;
      if (target?.startAtEnd == true) {
        pageIndex = pages.length - 1;
      } else if (target?.paragraph != null) {
        pageIndex = _paginationEngine.pageForAnchor(
          pages,
          target!.paragraph!,
          target.offset ?? 0,
        );
      } else if (target?.cachedPageIndex != null) {
        pageIndex = target!.cachedPageIndex!.clamp(
          0,
          math.max(0, pages.length - 1),
        );
      } else {
        pageIndex = 0;
      }
      setState(() {
        _pages = pages!;
        _layoutKey = key;
        _pageIndex = pageIndex;
        _paginating = false;
        _startTarget = null;
        _error = null;
      });
      // Save pagination metadata without triggering automatic Known.
      unawaited(_saveCurrentProgress());
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error;
        _paginating = false;
      });
    }
  }

  PageContent? get _currentPage =>
      _pageIndex >= 0 && _pageIndex < _pages.length ? _pages[_pageIndex] : null;

  Future<void> _nextPage() async {
    if (_turning || _paginating || _closing) return;
    final page = _currentPage;
    final chapter = _chapter;
    if (page == null || chapter == null) return;
    if (_pageIndex >= _pages.length - 1 &&
        _chapterIndex >= _chapters.length - 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You have reached the end of the book.')),
      );
      return;
    }
    setState(() => _turning = true);
    try {
      if (_pageIndex < _pages.length - 1) {
        final target = _pages[_pageIndex + 1];
        await ref
            .read(readerRepositoryProvider)
            .commitPageAdvance(
              bookId: widget.bookId,
              chapterId: chapter.id,
              targetParagraph: target.startParagraph,
              targetOffset: target.startOffset,
              targetPageIndex: target.index,
              targetPageCount: _pages.length,
              layoutSignature: _layoutKey ?? '',
            );
        if (!mounted || _closing) return;
        setState(() => _pageIndex += 1);
      } else {
        await ref
            .read(readerRepositoryProvider)
            .commitPageAdvance(
              bookId: widget.bookId,
              chapterId: chapter.id,
              targetParagraph: page.startParagraph,
              targetOffset: page.startOffset,
              targetPageIndex: _pageIndex,
              targetPageCount: _pages.length,
              layoutSignature: _layoutKey ?? '',
            );
        if (!mounted || _closing) return;
        await _switchChapter(
          _chapterIndex + 1,
          useSavedProgress: false,
          saveCurrent: false,
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not turn the page: $error')),
        );
      }
    } finally {
      if (mounted) setState(() => _turning = false);
    }
  }

  Future<void> _previousPage() async {
    if (_turning || _paginating || _closing) return;
    final page = _currentPage;
    final chapter = _chapter;
    if (page == null || chapter == null) return;
    setState(() => _turning = true);
    try {
      if (_pageIndex > 0) {
        final target = _pages[_pageIndex - 1];
        await ref
            .read(readerRepositoryProvider)
            .saveProgressOnly(
              bookId: widget.bookId,
              chapterId: chapter.id,
              anchorParagraph: target.startParagraph,
              anchorOffset: target.startOffset,
              pageIndex: target.index,
              pageCount: _pages.length,
              layoutSignature: _layoutKey ?? '',
            );
        if (!mounted || _closing) return;
        setState(() => _pageIndex -= 1);
      } else if (_chapterIndex > 0) {
        await _saveCurrentProgress();
        if (!mounted) return;
        await _switchChapter(
          _chapterIndex - 1,
          useSavedProgress: false,
          startAtEnd: true,
          saveCurrent: false,
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not turn the page: $error')),
        );
      }
    } finally {
      if (mounted) setState(() => _turning = false);
    }
  }

  Future<void> _saveCurrentProgress() async {
    final page = _currentPage;
    final chapter = _chapter;
    if (page == null || chapter == null || _layoutKey == null) return;
    try {
      await ref
          .read(readerRepositoryProvider)
          .saveProgressOnly(
            bookId: widget.bookId,
            chapterId: chapter.id,
            anchorParagraph: page.startParagraph,
            anchorOffset: page.startOffset,
            pageIndex: _pageIndex,
            pageCount: _pages.length,
            layoutSignature: _layoutKey!,
          );
    } catch (_) {
      // Progress saving is best-effort on close/background. The reading state
      // already committed by explicit page turns is durable.
    }
  }

  Future<void> _close() async {
    if (_closing) return;
    _closing = true;
    await _saveCurrentProgress();
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _loadChapterMarks(Chapter chapter) async {
    try {
      final marks = await ref
          .read(vocabularyRepositoryProvider)
          .getChapterWordMarks(chapter);
      if (!mounted || _chapter?.id != chapter.id) return;
      setState(() => _occurrences = marks);
    } catch (_) {
      // Underlines are helpful metadata; reading must not fail without them.
    }
  }

  Future<void> _openWord(BuildContext context, _WordTap tap) async {
    final chapter = _chapter;
    if (chapter == null) return;
    final repository = ref.read(vocabularyRepositoryProvider);
    final match = await repository.matchSurface(tap.surfaceForm);
    if (!mounted) return;
    String? occurrenceId;
    for (final occurrence in _occurrences) {
      if (occurrence.id.isNotEmpty &&
          occurrence.paragraphIndex == tap.paragraphIndex &&
          occurrence.startOffset == tap.startOffset &&
          occurrence.endOffset == tap.endOffset) {
        occurrenceId = occurrence.id;
        break;
      }
    }
    setState(() => _focusedWord = tap);
    try {
      await _withVolumeKeysPaused(
        () => showVocabularyPanel(
          context,
          ref,
          match: match,
          bookId: widget.bookId,
          occurrenceId: occurrenceId,
          pendingOccurrence: PendingOccurrence(
            chapterId: chapter.id,
            paragraphIndex: tap.paragraphIndex,
            startOffset: tap.startOffset,
            endOffset: tap.endOffset,
            surfaceForm: tap.surfaceForm,
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _focusedWord = null);
    }
    if (!mounted) return;
    await _loadChapterMarks(chapter);
  }

  Future<void> _showChapters(BuildContext context) async {
    if (_chapters.isEmpty) return;
    final selected = await _withVolumeKeysPaused(
      () => showModalBottomSheet<int>(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        builder: (context) {
          final palette = CafePalette.of(context);
          return FractionallySizedBox(
            heightFactor: 0.72,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 4, 24, 14),
                  child: Text(
                    'Chapters',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: _chapters.length,
                    itemBuilder: (context, index) {
                      final current = index == _chapterIndex;
                      return ListTile(
                        selected: current,
                        selectedTileColor: palette.accentSoft,
                        leading: SizedBox(
                          width: 28,
                          child: Text(
                            '${index + 1}',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Literata',
                              fontWeight: FontWeight.w700,
                              color: current
                                  ? palette.accent
                                  : palette.inkMuted,
                            ),
                          ),
                        ),
                        title: Text(
                          _chapters[index].title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: current
                            ? Icon(
                                Icons.bookmark,
                                color: palette.accent,
                                size: 18,
                              )
                            : null,
                        onTap: () => Navigator.pop(context, index),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
    if (selected == null || !mounted || selected == _chapterIndex) return;
    await _saveCurrentProgress();
    if (!mounted) return;
    await _switchChapter(selected, useSavedProgress: true, saveCurrent: false);
  }

  Future<void> _showQuickSettings(BuildContext context) async {
    await _withVolumeKeysPaused(
      () => showModalBottomSheet<void>(
        context: context,
        useSafeArea: true,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        showDragHandle: false,
        builder: (_) => const ReaderQuickSettings(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<ReaderSettings>>(readerSettingsProvider, (_, next) {
      _syncVolumeKeys(next.valueOrNull?.volumeKeysTurnPages ?? false);
    });
    final settings =
        ref.watch(readerSettingsProvider).valueOrNull ?? const ReaderSettings();
    _syncVolumeKeys(settings.volumeKeysTurnPages);
    // The reading page follows the app appearance, including e-ink mode.
    final appearance =
        ref.watch(appAppearanceProvider).valueOrNull ?? const AppAppearance();
    final eink = appearance.mode == AppAppearanceMode.eink;
    final platformBrightness = MediaQuery.platformBrightnessOf(context);
    final useDark = switch (appearance.mode) {
      AppAppearanceMode.dark => true,
      AppAppearanceMode.auto => platformBrightness == Brightness.dark,
      _ => false,
    };
    final readerTheme = CafeTheme.build(
      useDark ? 'dark' : 'light',
      einkMode: eink,
    );
    final palette = CafeTheme.colorsFor(useDark ? 'dark' : 'light', eink);
    final marks =
        ref.watch(wordMarkSettingsProvider).valueOrNull ??
        WordMarkSettings.defaults;
    final markMode = eink
        ? WordMarkMode.eink
        : (useDark ? WordMarkMode.night : WordMarkMode.day);
    final appearances = <VocabularyState, WordMarkAppearance>{
      VocabularyState.newWord: marks.appearance(
        markMode,
        WordMarkTarget.newWord,
      ),
      VocabularyState.learning: marks.appearance(
        markMode,
        WordMarkTarget.learning,
      ),
      VocabularyState.known: marks.appearance(markMode, WordMarkTarget.known),
    };
    if (_initializing) {
      return Theme(
        data: readerTheme,
        child: Scaffold(
          backgroundColor: palette.background,
          body: const Center(child: CircularProgressIndicator()),
        ),
      );
    }
    if (_error != null && _book == null) {
      return Theme(
        data: readerTheme,
        child: Scaffold(
          backgroundColor: palette.background,
          body: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    8,
                    desktopTitleBarInset + 4,
                    8,
                    4,
                  ),
                  child: SizedBox(
                    height: 44,
                    child: Row(
                      children: [
                        IconButton(
                          tooltip: 'Back',
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.arrow_back, size: 20),
                        ),
                        const SizedBox(width: 2),
                        Text(
                          'Reader',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                        ),
                        const Spacer(),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: EmptyState(
                    icon: Icons.menu_book_outlined,
                    title: 'Could not open this book',
                    message: '$_error',
                    action: FilledButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Back to library'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
    final chapter = _chapter;
    final title = chapter?.title ?? _book?.title ?? 'Reader';
    return Theme(
      data: readerTheme,
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) _close();
        },
        child: Scaffold(
          backgroundColor: palette.background,
          body: SafeArea(
            child: Focus(
              autofocus: true,
              onKeyEvent: (node, event) {
                if (event is! KeyDownEvent) return KeyEventResult.ignored;
                if (event.logicalKey == LogicalKeyboardKey.arrowLeft ||
                    event.logicalKey == LogicalKeyboardKey.pageUp) {
                  _previousPage();
                  return KeyEventResult.handled;
                }
                if (event.logicalKey == LogicalKeyboardKey.arrowRight ||
                    event.logicalKey == LogicalKeyboardKey.pageDown ||
                    event.logicalKey == LogicalKeyboardKey.space) {
                  _nextPage();
                  return KeyEventResult.handled;
                }
                return KeyEventResult.ignored;
              },
              child: Column(
                children: [
                  SizedBox(height: desktopTitleBarInset),
                  _ReaderTopBar(
                    title: title,
                    bookTitle: _book?.title ?? '',
                    chapterIndex: _chapterIndex,
                    chapterCount: _chapters.length,
                    onBack: _close,
                    onChapters: _showChapters,
                    onSettings: _showQuickSettings,
                  ),
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final sideWidth = (constraints.maxWidth * 0.12).clamp(
                          46.0,
                          90.0,
                        );
                        final centerWidth =
                            constraints.maxWidth - sideWidth * 2;
                        final maxTextWidth = math.min(centerWidth, 840.0);
                        final contentWidth = math.max(
                          80.0,
                          maxTextWidth - settings.horizontalPadding * 2,
                        );
                        final contentHeight = math.max(
                          80.0,
                          constraints.maxHeight - settings.verticalPadding * 2,
                        );
                        final textScaler = MediaQuery.textScalerOf(context);
                        final textStyle = _readingStyle(settings, palette);
                        final signature = LayoutSignature(
                          fontFamily: settings.fontFamily,
                          fontSize: settings.fontSize,
                          fontWeight: settings.fontWeight,
                          lineHeight: settings.lineHeight,
                          paragraphSpacing: settings.paragraphSpacing,
                          contentWidth: contentWidth,
                          contentHeight: contentHeight,
                          orientation: LayoutSignature.orientationFor(context),
                          textScaleFactor: textScaler.scale(1.0),
                        );
                        if (_chapter != null) {
                          _ensurePagination(
                            signature: signature,
                            width: contentWidth,
                            height: contentHeight - 2,
                            textScaler: textScaler,
                            textStyle: textStyle,
                            settings: settings,
                          );
                        }
                        final ready =
                            _layoutKey == '${_chapter?.id}|${signature.key}' &&
                            !_paginating;
                        return Row(
                          children: [
                            SizedBox(
                              width: sideWidth,
                              child: _PageTurnZone(
                                direction: -1,
                                enabled: _pageIndex > 0 || _chapterIndex > 0,
                                onTap: _previousPage,
                              ),
                            ),
                            Expanded(
                              child: Center(
                                child: ConstrainedBox(
                                  constraints: BoxConstraints(
                                    maxWidth: maxTextWidth,
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: settings.horizontalPadding,
                                      vertical: settings.verticalPadding,
                                    ),
                                    child: ClipRect(
                                      child: OverflowBox(
                                        alignment: Alignment.topLeft,
                                        minHeight: 0,
                                        maxHeight: double.infinity,
                                        child: ready
                                            ? _ReadingPage(
                                                page: _currentPage!,
                                                occurrences: _occurrences,
                                                textStyle: textStyle,
                                                textScaler: textScaler,
                                                paragraphSpacing:
                                                    settings.paragraphSpacing,
                                                appearances: appearances,
                                                focusedWord: _focusedWord,
                                                onWord: (tap) =>
                                                    _openWord(context, tap),
                                              )
                                            : _Paginating(
                                                eink: eink,
                                                error: _error,
                                              ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: sideWidth,
                              child: _PageTurnZone(
                                direction: 1,
                                enabled:
                                    _pageIndex < _pages.length - 1 ||
                                    _chapterIndex < _chapters.length - 1,
                                onTap: _nextPage,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  _ReaderFooter(
                    chapterTitle: title,
                    pageIndex: _pageIndex,
                    pageCount: _pages.length,
                    onChapters: _showChapters,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  TextStyle _readingStyle(ReaderSettings settings, CafeColors palette) {
    final family = settings.fontFamily.trim();
    return TextStyle(
      fontFamily: family.isEmpty || family.toLowerCase() == 'system'
          ? null
          : family,
      fontSize: settings.fontSize,
      fontWeight: _weight(settings.fontWeight),
      height: settings.lineHeight,
      color: palette.ink,
      letterSpacing: 0.05,
    );
  }

  static FontWeight _weight(int value) {
    final index = ((value / 100).round() - 1).clamp(0, 8);
    return FontWeight.values[index];
  }
}

class _PageTurnZone extends StatelessWidget {
  const _PageTurnZone({
    required this.direction,
    required this.enabled,
    required this.onTap,
  });

  final int direction;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = CafePalette.of(context);
    return MouseRegion(
      cursor: enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: GestureDetector(
        key: ValueKey(direction < 0 ? 'page-turn-left' : 'page-turn-right'),
        behavior: HitTestBehavior.opaque,
        onTap: enabled ? onTap : null,
        child: SizedBox.expand(
          child: Center(
            child: Icon(
              direction < 0
                  ? Icons.keyboard_arrow_left_rounded
                  : Icons.keyboard_arrow_right_rounded,
              size: 28,
              color: enabled
                  ? palette.inkMuted.withValues(alpha: 0.28)
                  : Colors.transparent,
            ),
          ),
        ),
      ),
    );
  }
}

class _ReaderTopBar extends StatelessWidget {
  const _ReaderTopBar({
    required this.title,
    required this.bookTitle,
    required this.chapterIndex,
    required this.chapterCount,
    required this.onBack,
    required this.onChapters,
    required this.onSettings,
  });

  final String title;
  final String bookTitle;
  final int chapterIndex;
  final int chapterCount;
  final VoidCallback onBack;
  final ValueChanged<BuildContext> onChapters;
  final ValueChanged<BuildContext> onSettings;

  @override
  Widget build(BuildContext context) {
    final palette = CafePalette.of(context);
    return Container(
      height: 54,
      padding: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: palette.line)),
      ),
      child: Row(
        children: [
          IconButton(
            tooltip: 'Back to library',
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back),
          ),
          Expanded(
            child: InkWell(
              onTap: () => onChapters(context),
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: palette.ink,
                      ),
                    ),
                    Text(
                      bookTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 10, color: palette.inkMuted),
                    ),
                  ],
                ),
              ),
            ),
          ),
          IconButton(
            tooltip: 'Table of contents',
            onPressed: () => onChapters(context),
            icon: const Icon(Icons.format_list_bulleted, size: 20),
          ),
          InkWell(
            onTap: () => onSettings(context),
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: Text(
                'Aa',
                style: TextStyle(
                  fontFamily: 'Literata',
                  fontWeight: FontWeight.w700,
                  color: palette.ink,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReaderFooter extends StatelessWidget {
  const _ReaderFooter({
    required this.chapterTitle,
    required this.pageIndex,
    required this.pageCount,
    required this.onChapters,
  });

  final String chapterTitle;
  final int pageIndex;
  final int pageCount;
  final ValueChanged<BuildContext> onChapters;

  @override
  Widget build(BuildContext context) {
    final palette = CafePalette.of(context);
    return Container(
      height: 38,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: palette.line)),
      ),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: () => onChapters(context),
              child: Text(
                chapterTitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 10.5, color: palette.inkMuted),
              ),
            ),
          ),
          Text(
            pageCount == 0 ? '—' : '${pageIndex + 1} / $pageCount',
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
              color: palette.inkMuted,
            ),
          ),
          const SizedBox(width: 14),
          Text(
            pageCount == 0
                ? ''
                : '${((pageIndex + 1) / pageCount * 100).round()}%',
            style: TextStyle(fontSize: 10.5, color: palette.inkMuted),
          ),
        ],
      ),
    );
  }
}

class _Paginating extends StatelessWidget {
  const _Paginating({required this.eink, this.error});
  final bool eink;
  final Object? error;

  @override
  Widget build(BuildContext context) {
    final palette = CafePalette.of(context);
    if (error != null) {
      return Center(
        child: Text(
          'Could not lay out this chapter.\n$error',
          textAlign: TextAlign.center,
          style: TextStyle(color: palette.danger, fontSize: 12),
        ),
      );
    }
    return Center(
      child: eink
          ? Text(
              'Laying out pages…',
              style: TextStyle(color: palette.inkMuted, fontSize: 12),
            )
          : const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
    );
  }
}

class _WordTap {
  const _WordTap({
    required this.surfaceForm,
    required this.paragraphIndex,
    required this.startOffset,
    required this.endOffset,
  });

  final String surfaceForm;
  final int paragraphIndex;
  final int startOffset;
  final int endOffset;
}

class _ReadingPage extends StatelessWidget {
  const _ReadingPage({
    required this.page,
    required this.occurrences,
    required this.textStyle,
    required this.textScaler,
    required this.paragraphSpacing,
    required this.appearances,
    required this.focusedWord,
    required this.onWord,
  });

  final PageContent page;
  final List<ChapterOccurrence> occurrences;
  final TextStyle textStyle;
  final TextScaler textScaler;
  final double paragraphSpacing;
  final Map<VocabularyState, WordMarkAppearance> appearances;
  final _WordTap? focusedWord;
  final ValueChanged<_WordTap> onWord;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var index = 0; index < page.fragments.length; index++)
          Padding(
            padding: EdgeInsets.only(top: index == 0 ? 0 : paragraphSpacing),
            child: _TappableParagraph(
              fragment: page.fragments[index],
              occurrences: occurrences,
              textStyle: textStyle,
              textScaler: textScaler,
              appearances: appearances,
              focusedWord: focusedWord,
              onWord: onWord,
            ),
          ),
      ],
    );
  }
}

class _TappableParagraph extends StatefulWidget {
  const _TappableParagraph({
    required this.fragment,
    required this.occurrences,
    required this.textStyle,
    required this.textScaler,
    required this.appearances,
    required this.focusedWord,
    required this.onWord,
  });

  final PageFragment fragment;
  final List<ChapterOccurrence> occurrences;
  final TextStyle textStyle;
  final TextScaler textScaler;
  final Map<VocabularyState, WordMarkAppearance> appearances;
  final _WordTap? focusedWord;
  final ValueChanged<_WordTap> onWord;

  @override
  State<_TappableParagraph> createState() => _TappableParagraphState();
}

class _TappableParagraphState extends State<_TappableParagraph> {
  int? _hoverStart;
  int? _hoverEnd;
  VocabularyState? _hoverState;

  PageFragment get _fragment => widget.fragment;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return MouseRegion(
          cursor: SystemMouseCursors.text,
          onHover: (event) => _handleHover(event, constraints.maxWidth),
          onExit: (_) => _clearHover(),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapUp: (details) {
              final painter = TextPainter(
                text: TextSpan(text: _fragment.text, style: widget.textStyle),
                textDirection: TextDirection.ltr,
                textScaler: widget.textScaler,
              )..layout(maxWidth: constraints.maxWidth);
              final position = painter.getPositionForOffset(
                details.localPosition,
              );
              painter.dispose();
              final local = position.offset;
              for (final token in const Tokenizer().tokenize(_fragment.text)) {
                if (local < token.start || local >= token.end) continue;
                widget.onWord(
                  _WordTap(
                    surfaceForm: token.surface,
                    paragraphIndex: _fragment.paragraphIndex,
                    startOffset: _fragment.startOffset + token.start,
                    endOffset: _fragment.startOffset + token.end,
                  ),
                );
                return;
              }
            },
            child: MarkedParagraph(
              text: _fragment.text,
              style: widget.textStyle,
              ranges: _buildMarkRanges(),
              focusRanges: _buildFocusRanges(),
              textScaler: widget.textScaler,
              richTextKey: const ValueKey('reader-paragraph'),
            ),
          ),
        );
      },
    );
  }

  /// New, Learning and Known words each use their own style and colour.
  List<WordMarkRange> _buildMarkRanges() {
    final ranges = <WordMarkRange>[];
    for (final occurrence in widget.occurrences) {
      if (occurrence.paragraphIndex != _fragment.paragraphIndex) continue;
      final appearance = widget.appearances[occurrence.state];
      if (appearance == null || appearance.style == WordMarkStyle.none) {
        continue;
      }
      final range = _localRange(occurrence.startOffset, occurrence.endOffset);
      if (range == null) continue;
      ranges.add(
        WordMarkRange(range.$1, range.$2, appearance.style, appearance.color),
      );
    }
    return ranges;
  }

  List<WordFocusRange> _buildFocusRanges() {
    final tapped = widget.focusedWord;
    if (tapped != null && tapped.paragraphIndex == _fragment.paragraphIndex) {
      final range = _localRange(tapped.startOffset, tapped.endOffset);
      if (range != null) {
        final color = _focusColorFor(tapped.startOffset, tapped.endOffset);
        if (color != null) {
          return [WordFocusRange(range.$1, range.$2, color)];
        }
      }
    }
    final state = _hoverState;
    if (_hoverStart != null && _hoverEnd != null && state != null) {
      final color = widget.appearances[state]?.focusColor;
      if (color != null) {
        return [WordFocusRange(_hoverStart!, _hoverEnd!, color)];
      }
    }
    return const [];
  }

  Color? _focusColorFor(int startOffset, int endOffset) {
    for (final occurrence in widget.occurrences) {
      if (occurrence.paragraphIndex != _fragment.paragraphIndex) continue;
      if (occurrence.startOffset == startOffset &&
          occurrence.endOffset == endOffset) {
        return widget.appearances[occurrence.state]?.focusColor;
      }
    }
    return widget.appearances[VocabularyState.newWord]?.focusColor;
  }

  void _handleHover(PointerHoverEvent event, double maxWidth) {
    if (maxWidth <= 0) return;
    final painter = TextPainter(
      text: TextSpan(text: _fragment.text, style: widget.textStyle),
      textDirection: TextDirection.ltr,
      textScaler: widget.textScaler,
    )..layout(maxWidth: maxWidth);
    final offset = painter.getPositionForOffset(event.localPosition).offset;
    painter.dispose();

    ChapterOccurrence? hit;
    for (final occurrence in widget.occurrences) {
      if (occurrence.paragraphIndex != _fragment.paragraphIndex) continue;
      final range = _localRange(occurrence.startOffset, occurrence.endOffset);
      if (range == null) continue;
      if (offset >= range.$1 && offset < range.$2) {
        hit = occurrence;
        break;
      }
    }
    final hovered = hit;
    if (hovered == null) {
      _clearHover();
      return;
    }
    final range = _localRange(hovered.startOffset, hovered.endOffset)!;
    if (_hoverStart == range.$1 &&
        _hoverEnd == range.$2 &&
        _hoverState == hovered.state) {
      return;
    }
    setState(() {
      _hoverStart = range.$1;
      _hoverEnd = range.$2;
      _hoverState = hovered.state;
    });
  }

  void _clearHover() {
    if (_hoverStart == null && _hoverEnd == null && _hoverState == null) {
      return;
    }
    setState(() {
      _hoverStart = null;
      _hoverEnd = null;
      _hoverState = null;
    });
  }

  /// Maps a chapter-relative range onto this fragment's text, clamping words
  /// that straddle a page break.
  (int, int)? _localRange(int start, int end) {
    if (end <= _fragment.startOffset || start >= _fragment.endOffset) {
      return null;
    }
    final localStart =
        math.max(start, _fragment.startOffset) - _fragment.startOffset;
    final localEnd = math.min(end, _fragment.endOffset) - _fragment.startOffset;
    if (localEnd <= localStart) return null;
    return (localStart, localEnd);
  }
}

class _StartTarget {
  const _StartTarget({
    this.paragraph,
    this.offset,
    this.cachedPageIndex,
    this.startAtEnd = false,
  });

  final int? paragraph;
  final int? offset;
  final int? cachedPageIndex;
  final bool startAtEnd;
}
