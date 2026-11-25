import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as html_parser;
import 'package:path/path.dart' as p;
import 'package:xml/xml.dart';

import 'parsed_book.dart';

class BookParseException implements Exception {
  BookParseException(this.message);
  final String message;
  @override
  String toString() => message;
}

class EpubParser {
  static const int _maxEntries = 20000;
  static const int _maxDecompressedBytes = 500 * 1024 * 1024;

  /// Text before the first TOC anchor in a document (book titles, part
  /// headings, ...) is only kept as its own chapter when it is this long.
  static const int _minPreambleChars = 120;

  /// Spine documents the TOC does not mention are treated as front matter
  /// when their file name looks like it and they are short.
  static const int _minUntrackedChars = 1000;

  static final RegExp _frontMatterPattern = RegExp(
    r'(^|[/_.-])(cover|titlepage|title[_-]?page|halftitle|half[_-]?title|title|'
    r'copyright|colophon|imprint|toc|contents|nav|backcover|back[_-]?cover|adcard)'
    r'([/_.-]|$)',
    caseSensitive: false,
  );

  static const Set<String> _skippedTags = {
    'script',
    'style',
    'head',
    'nav',
    'svg',
    'audio',
    'video',
    'iframe',
    'noscript',
  };

  static const Set<String> _blockTags = {
    'address',
    'article',
    'aside',
    'blockquote',
    'caption',
    'dd',
    'div',
    'dl',
    'dt',
    'figcaption',
    'figure',
    'footer',
    'h1',
    'h2',
    'h3',
    'h4',
    'h5',
    'h6',
    'header',
    'hr',
    'li',
    'main',
    'ol',
    'p',
    'pre',
    'section',
    'table',
    'tbody',
    'td',
    'tfoot',
    'th',
    'thead',
    'tr',
    'ul',
  };

  ParsedBook parse(Uint8List bytes, {String fallbackTitle = 'Untitled'}) {
    final Archive archive;
    try {
      archive = ZipDecoder().decodeBytes(bytes, verify: true);
    } catch (error) {
      throw BookParseException('This file is not a valid EPUB archive.');
    }
    if (archive.files.length > _maxEntries) {
      throw BookParseException('EPUB contains too many files.');
    }
    var total = 0;
    for (final file in archive.files) {
      total += file.size;
      if (total > _maxDecompressedBytes) {
        throw BookParseException('EPUB is too large to import safely.');
      }
    }
    final files = <String, ArchiveFile>{};
    for (final file in archive.files) {
      if (!file.isFile) continue;
      files[_normalizeEntry(file.name)] = file;
    }
    final container = _findEntry(files, 'META-INF/container.xml');
    if (container == null) {
      throw BookParseException('EPUB is missing META-INF/container.xml.');
    }
    final containerXml = _parseXml(container, 'container.xml');
    final rootfile = containerXml.descendantElements
        .where((e) => e.name.local == 'rootfile')
        .firstOrNull;
    final opfPathRaw = rootfile?.getAttribute('full-path');
    if (opfPathRaw == null || opfPathRaw.isEmpty) {
      throw BookParseException('EPUB has no package document.');
    }
    final opfPath = _normalizeEntry(Uri.decodeComponent(opfPathRaw));
    final opfFile = _findEntry(files, opfPath);
    if (opfFile == null) {
      throw BookParseException('EPUB package document is missing.');
    }
    final opf = _parseXml(opfFile, opfPath);
    final opfDir = p.posix.dirname(opfPath);

    final metadata = opf.descendantElements
        .where((element) => element.name.local == 'metadata')
        .firstOrNull;
    String? metaText(String local) {
      if (metadata == null) return null;
      return metadata.descendantElements
          .where((element) => element.name.local == local)
          .map((element) => element.innerText.trim())
          .where((value) => value.isNotEmpty)
          .firstOrNull;
    }

    final title = metaText('title') ?? fallbackTitle;
    final creators = metadata == null
        ? <String>[]
        : metadata.descendantElements
              .where((element) => element.name.local == 'creator')
              .map((element) => element.innerText.trim())
              .where((value) => value.isNotEmpty)
              .toList();
    final description = metaText('description');
    final language = metaText('language') ?? 'en';

    final manifestItems = <String, _ManifestItem>{};
    final manifest = opf.descendantElements
        .where((element) => element.name.local == 'manifest')
        .firstOrNull;
    if (manifest != null) {
      for (final item in manifest.childElements.where(
        (element) => element.name.local == 'item',
      )) {
        final id = item.getAttribute('id');
        final href = item.getAttribute('href');
        if (id == null || href == null) continue;
        manifestItems[id] = _ManifestItem(
          id: id,
          href: _resolve(opfDir, href),
          mediaType: item.getAttribute('media-type') ?? '',
          properties: item.getAttribute('properties')?.split(' ') ?? const [],
        );
      }
    }

    final spineElement = opf.descendantElements
        .where((element) => element.name.local == 'spine')
        .firstOrNull;
    if (spineElement == null) {
      throw BookParseException('EPUB has no spine.');
    }
    final tocEntries = _parseToc(
      files: files,
      manifestItems: manifestItems,
      spineTocId: spineElement.getAttribute('toc'),
    );

    final cover = _findCover(files, manifestItems);
    final spineItems = <_ManifestItem>[];
    for (final itemRef in spineElement.childElements.where(
      (element) => element.name.local == 'itemref',
    )) {
      final idref = itemRef.getAttribute('idref');
      if (idref == null) continue;
      final item = manifestItems[idref];
      if (item == null) continue;
      if (!_isDocumentItem(item)) continue;
      spineItems.add(item);
    }
    if (spineItems.isEmpty) {
      throw BookParseException('EPUB spine contains no readable chapters.');
    }

    // Every spine document is read exactly once, in reading order. Chapter
    // boundaries come from the table of contents when it points into the
    // document; documents (or portions of them) the TOC does not mention are
    // still kept, so incomplete TOCs can no longer drop body text.
    final tocByPath = <String, List<_TocEntry>>{};
    for (final entry in tocEntries) {
      tocByPath
          .putIfAbsent(entry.path.toLowerCase(), () => [])
          .add(entry);
    }
    final spinePaths = {for (final item in spineItems) item.href.toLowerCase()};
    final hasToc = tocByPath.keys.any(spinePaths.contains);

    dom.Element? bodyFor(String path) {
      final file = _findEntry(files, path);
      if (file == null) return null;
      try {
        final source = utf8.decode(file.content, allowMalformed: true);
        final document = _parseHtml(source);
        return document.body ?? document.documentElement;
      } catch (_) {
        return null;
      }
    }

    int textLength(_ExtractedText extracted) => extracted.paragraphs.fold(
      0,
      (sum, paragraph) => sum + paragraph.length,
    );

    final chapters = <ParsedChapter>[];

    void addChapter(String? title, _ExtractedText extracted) {
      final heading = extracted.heading;
      final paragraphs = [...extracted.paragraphs];
      if (paragraphs.isNotEmpty &&
          ((heading != null && _sameTitle(paragraphs.first, heading)) ||
              (title != null && _sameTitle(paragraphs.first, title)))) {
        paragraphs.removeAt(0);
      }
      if (paragraphs.isEmpty) return;
      final chapterTitle =
          _cleanTitle(title) ?? 'Chapter ${chapters.length + 1}';
      chapters.add(
        ParsedChapter(title: chapterTitle, content: paragraphs.join('\n\n')),
      );
    }

    for (final item in spineItems) {
      final pathKey = item.href.toLowerCase();
      final body = bodyFor(item.href);
      if (body == null) continue;
      final entries = tocByPath[pathKey] ?? const <_TocEntry>[];
      final anchorOrder = _collectAnchorOrder(body);

      // Only anchors that really exist in this document can split it. Broken
      // TOC links (and links into skipped markup) must not swallow a chapter.
      final resolved = <_TocEntry>[];
      final usedOrdinals = <int>{};
      for (final entry in entries) {
        final fragment = entry.fragment;
        if (fragment == null) continue;
        final ordinal = anchorOrder[fragment];
        if (ordinal == null) continue;
        // Two TOC entries on the same element (id and name) delimit nothing;
        // keep the first so the text is not emitted twice.
        if (!usedOrdinals.add(ordinal)) continue;
        resolved.add(entry);
      }
      resolved.sort(
        (left, right) =>
            anchorOrder[left.fragment]!.compareTo(anchorOrder[right.fragment]!),
      );

      if (resolved.isEmpty) {
        // No usable anchors in this document: keep the whole file.
        final extracted = _extractText(body);
        if (extracted.paragraphs.isEmpty) continue;
        if (hasToc &&
            _frontMatterPattern.hasMatch(item.href) &&
            textLength(extracted) < _minUntrackedChars) {
          continue;
        }
        addChapter(_containerTitle(entries) ?? extracted.heading, extracted);
        continue;
      }

      // Text that sits before the first chapter anchor of this file (book
      // titles, headings or a prologue kept in the same file).
      final preamble = _extractText(
        body,
        endAnchor: resolved.first.fragment,
      );
      if (textLength(preamble) >= _minPreambleChars) {
        addChapter(_containerTitle(entries) ?? preamble.heading, preamble);
      }

      for (var index = 0; index < resolved.length; index++) {
        final entry = resolved[index];
        final extracted = _extractText(
          body,
          startAnchor: entry.fragment,
          endAnchor: index + 1 < resolved.length
              ? resolved[index + 1].fragment
              : null,
        );
        addChapter(entry.title, extracted);
      }
    }
    if (chapters.isEmpty) {
      throw BookParseException('No readable text was found in this EPUB.');
    }

    return ParsedBook(
      title: title,
      author: creators.isEmpty ? null : creators.join(', '),
      description: description == null ? null : _plainText(description),
      language: language.split('-').first.toLowerCase(),
      chapters: chapters,
      coverBytes: cover?.bytes,
      coverExtension: cover?.extension,
    );
  }

  /// XHTML allows `<script/>` and `<style/>`, but the HTML parser treats those
  /// elements as raw text and would swallow the rest of the document (body
  /// text included). Expand them to their empty, explicitly closed form first.
  static final RegExp _selfClosingRawText = RegExp(
    r'<(script|style|title|textarea|noscript|iframe)\b([^<>]*?)/>',
    caseSensitive: false,
  );

  static dom.Document _parseHtml(String source) => html_parser.parse(
    source.replaceAllMapped(
      _selfClosingRawText,
      (match) => '<${match[1]}${match[2]}></${match[1]}>',
    ),
  );

  XmlDocument _parseXml(ArchiveFile file, String name) {
    try {
      return XmlDocument.parse(utf8.decode(file.content, allowMalformed: true));
    } catch (_) {
      throw BookParseException('EPUB metadata is malformed ($name).');
    }
  }

  /// Whether a manifest item is a readable document. EPUB 2 producers often
  /// leave media-type empty or use OEB-specific types, so the file extension
  /// is checked as well.
  static bool _isDocumentItem(_ManifestItem item) {
    final type = item.mediaType.toLowerCase();
    if (type.contains('svg') || type == 'application/x-dtbncx+xml') {
      return false;
    }
    if (type == 'application/xhtml+xml' ||
        type == 'application/x-dtbook+xml' ||
        type == 'text/x-oeb1-document' ||
        type == 'text/html' ||
        type == 'text/xml') {
      return true;
    }
    if (type.isNotEmpty) {
      return type.contains('html') || type.contains('xml');
    }
    final lower = item.href.toLowerCase();
    return lower.endsWith('.xhtml') ||
        lower.endsWith('.html') ||
        lower.endsWith('.htm') ||
        lower.endsWith('.xml');
  }

  /// Records the document order of every id/name anchor, skipping markup that
  /// [_extractText] ignores. Anchors on the body itself cannot delimit a
  /// chapter boundary.
  static Map<String, int> _collectAnchorOrder(dom.Element root) {
    final order = <String, int>{};
    var index = 0;

    void walk(dom.Node node) {
      if (node is! dom.Element) return;
      final tag = node.localName?.toLowerCase() ?? '';
      if (_skippedTags.contains(tag)) return;
      index++;
      if (tag != 'body' && tag != 'html') {
        final id = node.id;
        if (id.isNotEmpty) order.putIfAbsent(id, () => index);
        final name = node.attributes['name'];
        if (name != null && name.isNotEmpty) {
          order.putIfAbsent(name, () => index);
        }
      }
      for (final child in node.nodes) {
        walk(child);
      }
    }

    walk(root);
    return order;
  }

  /// Title of a TOC entry that covers the whole document (no fragment), used
  /// for content that precedes the first anchor.
  static String? _containerTitle(List<_TocEntry> entries) {
    for (final entry in entries) {
      if (entry.fragment == null) return entry.title;
    }
    return null;
  }

  List<_TocEntry> _parseToc({
    required Map<String, ArchiveFile> files,
    required Map<String, _ManifestItem> manifestItems,
    required String? spineTocId,
  }) {
    // Try the documents the package points at first, then any nav-like file.
    // Whichever yields entries wins, so a broken or empty nav document cannot
    // hide a perfectly good NCX (and the other way round).
    final candidates = <_ManifestItem>[];
    void addCandidate(_ManifestItem? item) {
      if (item != null && !candidates.contains(item)) candidates.add(item);
    }

    addCandidate(spineTocId == null ? null : manifestItems[spineTocId]);
    addCandidate(
      manifestItems.values
          .where((item) => item.properties.contains('nav'))
          .firstOrNull,
    );
    addCandidate(
      manifestItems.values
          .where(
            (item) =>
                item.mediaType.contains('dtbncx') ||
                item.href.toLowerCase().endsWith('.ncx'),
          )
          .firstOrNull,
    );
    addCandidate(
      manifestItems.values
          .where(
            (item) =>
                _isDocumentItem(item) &&
                RegExp(
                  r'(^|/)(nav|toc|contents)\.x?html?$',
                  caseSensitive: false,
                ).hasMatch(item.href),
          )
          .firstOrNull,
    );

    for (final item in candidates) {
      final entries = _parseTocDocument(files, item);
      if (entries.isNotEmpty) return entries;
    }
    return const [];
  }

  List<_TocEntry> _parseTocDocument(
    Map<String, ArchiveFile> files,
    _ManifestItem item,
  ) {
    final entries = <_TocEntry>[];
    final seen = <String>{};
    final navFile = _findEntry(files, item.href);
    if (navFile == null) return entries;
    final navSource = utf8.decode(navFile.content, allowMalformed: true);
    final navDir = p.posix.dirname(item.href);

    void add(String? href, String label) {
      if (href == null || href.isEmpty) return;
      if (href.contains('://') || href.startsWith('mailto:')) return;
      final title = label.replaceAll(RegExp(r'\s+'), ' ').trim();
      if (title.isEmpty) return;
      final target = _splitHref(navDir, href, selfPath: item.href);
      if (target == null) return;
      final key = '${target.path}#${target.fragment ?? ''}';
      if (!seen.add(key)) return;
      entries.add(
        _TocEntry(title: title, path: target.path, fragment: target.fragment),
      );
    }

    try {
      final isNcx =
          item.mediaType.contains('dtbncx') ||
          item.href.toLowerCase().endsWith('.ncx');
      if (isNcx) {
        final doc = XmlDocument.parse(navSource);
        for (final point in doc.descendantElements.where(
          (element) => element.name.local == 'navPoint',
        )) {
          final label = point.descendantElements
              .where((element) => element.name.local == 'navLabel')
              .expand((element) => element.descendantElements)
              .where((element) => element.name.local == 'text')
              .map((element) => element.innerText.trim())
              .where((value) => value.isNotEmpty)
              .firstOrNull;
          final src = point.descendantElements
              .where((element) => element.name.local == 'content')
              .map((element) => element.getAttribute('src'))
              .whereType<String>()
              .firstOrNull;
          if (label != null) add(src, label);
        }
      } else {
        final document = _parseHtml(navSource);
        final nav = _selectTocNav(document);
        if (nav != null) {
          for (final link in nav.querySelectorAll('a[href]')) {
            add(link.attributes['href'], link.text);
          }
        }
      }
    } catch (_) {
      // A broken TOC must not prevent reading the book.
    }
    return entries;
  }

  /// Picks the navigation list that actually describes the table of contents:
  /// `epub:type="toc"`, then `role="doc-toc"`, then the richest list of links.
  static dom.Element? _selectTocNav(dom.Document document) {
    final navs = document.querySelectorAll('nav');
    dom.Element? richest;
    var richestLinks = 0;
    for (final nav in navs) {
      final type = nav.attributes['epub:type']?.toLowerCase() ?? '';
      if (type.split(RegExp(r'\s+')).contains('toc')) return nav;
    }
    for (final nav in navs) {
      final role = nav.attributes['role']?.toLowerCase() ?? '';
      if (role.split(RegExp(r'\s+')).contains('doc-toc')) return nav;
    }
    for (final nav in navs) {
      final links = nav.querySelectorAll('a[href]').length;
      if (links > richestLinks) {
        richestLinks = links;
        richest = nav;
      }
    }
    return richest ?? document.body;
  }

  _CoverResult? _findCover(
    Map<String, ArchiveFile> files,
    Map<String, _ManifestItem> items,
  ) {
    _ManifestItem? item = items.values
        .where((candidate) => candidate.properties.contains('cover-image'))
        .firstOrNull;
    item ??= items.values
        .where(
          (candidate) =>
              candidate.href.toLowerCase().contains('cover') &&
              candidate.mediaType.startsWith('image/'),
        )
        .firstOrNull;
    if (item == null) return null;
    final file = _findEntry(files, item.href);
    if (file == null) return null;
    final ext = switch (item.mediaType) {
      'image/png' => 'png',
      'image/gif' => 'gif',
      'image/svg+xml' => 'svg',
      'image/webp' => 'webp',
      _ => 'jpg',
    };
    return _CoverResult(bytes: file.content, extension: ext);
  }

  _ExtractedText _extractText(
    dom.Element? root, {
    String? startAnchor,
    String? endAnchor,
  }) {
    final paragraphs = <String>[];
    if (root == null) {
      return const _ExtractedText(paragraphs: []);
    }
    final buffer = StringBuffer();
    String? heading;
    var active = startAnchor == null;
    var finished = false;

    void flush() {
      final value = buffer
          .toString()
          .replaceAll(RegExp(r'[\t\r\n\f ]+'), ' ')
          .trim();
      buffer.clear();
      if (value.isNotEmpty) paragraphs.add(value);
    }

    bool matchesAnchor(dom.Element element, String anchor) =>
        element.id == anchor || element.attributes['name'] == anchor;

    void walk(dom.Node node) {
      if (finished) return;
      if (node is dom.Text) {
        if (active) buffer.write(node.data);
        return;
      }
      if (node is! dom.Element) return;
      final tag = node.localName?.toLowerCase() ?? '';
      if (_skippedTags.contains(tag)) return;
      if (!active) {
        if (startAnchor == null || !matchesAnchor(node, startAnchor)) {
          // Keep looking for the chapter anchor inside this subtree.
          for (final child in node.nodes) {
            walk(child);
          }
          return;
        }
        active = true;
      } else if (endAnchor != null && matchesAnchor(node, endAnchor)) {
        flush();
        finished = true;
        return;
      }
      if (tag == 'br') {
        buffer.write(' ');
        return;
      }
      if (tag == 'img' || tag == 'image') {
        final alt = node.attributes['alt'];
        if (alt != null && alt.trim().isNotEmpty) {
          buffer.write(' ${alt.trim()} ');
        }
        return;
      }
      if (heading == null && (tag == 'h1' || tag == 'h2' || tag == 'h3')) {
        final value = node.text.replaceAll(RegExp(r'\s+'), ' ').trim();
        if (value.isNotEmpty) heading = value;
      }
      final isBlock = _blockTags.contains(tag);
      if (isBlock) flush();
      for (final child in node.nodes) {
        walk(child);
      }
      if (isBlock) flush();
    }

    walk(root);
    flush();
    final headingText = heading;
    return _ExtractedText(
      paragraphs: paragraphs,
      heading: headingText != null && headingText.length <= 140
          ? headingText
          : null,
    );
  }

  static ({String path, String? fragment})? _splitHref(
    String baseDir,
    String href, {
    String? selfPath,
  }) {
    final hashIndex = href.indexOf('#');
    final rawPath = hashIndex >= 0 ? href.substring(0, hashIndex) : href;
    final rawFragment = hashIndex >= 0 ? href.substring(hashIndex + 1) : null;
    String? fragment;
    if (rawFragment != null && rawFragment.isNotEmpty) {
      try {
        fragment = Uri.decodeComponent(rawFragment).trim();
      } catch (_) {
        fragment = rawFragment.trim();
      }
      if (fragment.isEmpty) fragment = null;
    }
    if (rawPath.trim().isEmpty) {
      // Fragment-only links ("#chapter1") point into the nav document itself.
      if (fragment == null || selfPath == null) return null;
      return (path: _normalizeEntry(selfPath), fragment: fragment);
    }
    return (path: _resolve(baseDir, rawPath), fragment: fragment);
  }

  static String _normalizeEntry(String path) => p.posix
      .normalize(path.replaceAll('\\', '/'))
      .replaceFirst(RegExp(r'^/+'), '');

  static ArchiveFile? _findEntry(Map<String, ArchiveFile> files, String path) {
    String decoded;
    try {
      decoded = Uri.decodeComponent(path);
    } catch (_) {
      decoded = path;
    }
    final normalized = _normalizeEntry(decoded);
    final direct = files[normalized];
    if (direct != null) return direct;
    final lower = normalized.toLowerCase();
    for (final entry in files.entries) {
      if (entry.key.toLowerCase() == lower) return entry.value;
    }
    return null;
  }

  static String _resolve(String baseDir, String href) {
    final clean = href.split('#').first;
    String decoded;
    try {
      decoded = Uri.decodeComponent(clean);
    } catch (_) {
      decoded = clean;
    }
    if (decoded.startsWith('/')) {
      return _normalizeEntry(decoded);
    }
    return _normalizeEntry(p.posix.join(baseDir, decoded));
  }

  static String _plainText(String htmlSource) {
    final fragment = html_parser.parseFragment(htmlSource);
    return (fragment.text ?? '').replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  static bool _sameTitle(String left, String right) =>
      left.trim().toLowerCase() == right.trim().toLowerCase();

  static String? _cleanTitle(String? value) {
    if (value == null) return null;
    final cleaned = value.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (cleaned.isEmpty || cleaned.length > 160) return null;
    return cleaned;
  }
}

class _TocEntry {
  const _TocEntry({required this.title, required this.path, this.fragment});

  final String title;
  final String path;
  final String? fragment;
}

class _ExtractedText {
  const _ExtractedText({required this.paragraphs, this.heading});
  final List<String> paragraphs;
  final String? heading;
}

class _ManifestItem {
  const _ManifestItem({
    required this.id,
    required this.href,
    required this.mediaType,
    required this.properties,
  });

  final String id;
  final String href;
  final String mediaType;
  final List<String> properties;
}

class _CoverResult {
  const _CoverResult({required this.bytes, required this.extension});
  final Uint8List bytes;
  final String extension;
}
