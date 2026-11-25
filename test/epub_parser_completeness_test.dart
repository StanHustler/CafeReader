import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:cafereader/domain/epub/book_parser.dart';
import 'package:cafereader/domain/epub/parsed_book.dart';
import 'package:flutter_test/flutter_test.dart';

const _container = '''
<?xml version="1.0"?>
<container version="1.0"
  xmlns="urn:oasis:names:tc:opendocument:xmlns:container">
  <rootfiles>
    <rootfile full-path="OEBPS/content.opf"
      media-type="application/oebps-package+xml"/>
  </rootfiles>
</container>
''';

String _opf({
  required String manifest,
  required String spine,
  String? toc,
  String metadata =
      '<dc:title>Body Test</dc:title><dc:language>en</dc:language>',
}) =>
    '''
<?xml version="1.0" encoding="utf-8"?>
<package xmlns="http://www.idpf.org/2007/opf" version="3.0">
  <metadata xmlns:dc="http://purl.org/dc/elements/1.1/">$metadata</metadata>
  <manifest>$manifest</manifest>
  <spine${toc == null ? '' : ' toc="$toc"'}>$spine</spine>
</package>
''';

Uint8List _zip(Map<String, String> entries) {
  final archive = Archive()
    ..addFile(ArchiveFile.string('mimetype', 'application/epub+zip'))
    ..addFile(ArchiveFile.string('META-INF/container.xml', _container));
  for (final entry in entries.entries) {
    archive.addFile(ArchiveFile.string('OEBPS/${entry.key}', entry.value));
  }
  return Uint8List.fromList(ZipEncoder().encode(archive));
}

String _allText(ParsedBook book) =>
    book.chapters.map((chapter) => chapter.content).join('\n\n');

void main() {
  test('keeps spine documents that the table of contents does not mention', () {
    final book = EpubParser().parse(
      _zip({
        'content.opf': _opf(
          manifest: '''
    <item id="nav" href="nav.xhtml" media-type="application/xhtml+xml" properties="nav"/>
    <item id="part" href="part.xhtml" media-type="application/xhtml+xml"/>
    <item id="ch1" href="ch1.xhtml" media-type="application/xhtml+xml"/>
    <item id="ch2" href="ch2.xhtml" media-type="application/xhtml+xml"/>''',
          spine:
              '<itemref idref="part"/><itemref idref="ch1"/><itemref idref="ch2"/>',
        ),
        'nav.xhtml': '''
<html xmlns="http://www.w3.org/1999/xhtml"
      xmlns:epub="http://www.idpf.org/2007/ops"><body>
<nav epub:type="toc"><ol>
<li><a href="part.xhtml#p1">Part One</a></li>
<li><a href="part.xhtml#p2">Part Two</a></li>
</ol></nav></body></html>''',
        'part.xhtml': '''
<html><body>
<section id="p1"><h1>Part One</h1>
<p>Part opening paragraph.</p></section>
<section id="p2"><h1>Part Two</h1>
<p>Part closing paragraph.</p></section></body></html>''',
        'ch1.xhtml': '''
<html><body><h1>Chapter One</h1><p>First chapter body.</p></body></html>''',
        'ch2.xhtml': '''
<html><body><h1>Chapter Two</h1><p>Second chapter body.</p></body></html>''',
      }),
    );
    final text = _allText(book);
    expect(text, contains('Part opening paragraph.'));
    expect(text, contains('Part closing paragraph.'));
    expect(text, contains('First chapter body.'));
    expect(text, contains('Second chapter body.'));
  });

  test('does not lose a chapter when its TOC anchor is missing', () {
    final book = EpubParser().parse(
      _zip({
        'content.opf': _opf(
          manifest: '''
    <item id="nav" href="nav.xhtml" media-type="application/xhtml+xml" properties="nav"/>
    <item id="ch1" href="ch1.xhtml" media-type="application/xhtml+xml"/>
    <item id="ch2" href="ch2.xhtml" media-type="application/xhtml+xml"/>''',
          spine: '<itemref idref="ch1"/><itemref idref="ch2"/>',
        ),
        'nav.xhtml': '''
<html xmlns="http://www.w3.org/1999/xhtml"
      xmlns:epub="http://www.idpf.org/2007/ops"><body>
<nav epub:type="toc"><ol>
<li><a href="ch1.xhtml#missing">Chapter One</a></li>
<li><a href="ch2.xhtml">Chapter Two</a></li>
</ol></nav></body></html>''',
        'ch1.xhtml': '''
<html><body><h1>Chapter One</h1><p>First chapter body.</p></body></html>''',
        'ch2.xhtml': '''
<html><body><h1>Chapter Two</h1><p>Second chapter body.</p></body></html>''',
      }),
    );
    final text = _allText(book);
    expect(text, contains('First chapter body.'));
    expect(text, contains('Second chapter body.'));
  });

  test('keeps text that appears before the first TOC anchor', () {
    final book = EpubParser().parse(
      _zip({
        'content.opf': _opf(
          manifest: '''
    <item id="nav" href="nav.xhtml" media-type="application/xhtml+xml" properties="nav"/>
    <item id="body" href="book.xhtml" media-type="application/xhtml+xml"/>''',
          spine: '<itemref idref="body"/>',
        ),
        'nav.xhtml': '''
<html xmlns="http://www.w3.org/1999/xhtml"
      xmlns:epub="http://www.idpf.org/2007/ops"><body>
<nav epub:type="toc"><ol>
<li><a href="book.xhtml#a">Chapter A</a></li>
<li><a href="book.xhtml#b">Chapter B</a></li>
</ol></nav></body></html>''',
        'book.xhtml': '''
<html><body>
<h1>Prologue</h1>
<p>The opening prologue text that belongs to no chapter anchor in the
table of contents, and therefore used to be thrown away entirely by the
chapter splitter.</p>
<section id="a"><h2>Chapter A</h2><p>Alpha body.</p></section>
<section id="b"><h2>Chapter B</h2><p>Beta body.</p></section>
</body></html>''',
      }),
    );
    final text = _allText(book);
    expect(text, contains('The opening prologue text'));
    expect(text, contains('Alpha body.'));
    expect(text, contains('Beta body.'));
  });

  test('accepts OEB-style spine media types', () {
    final book = EpubParser().parse(
      _zip({
        'content.opf': _opf(
          manifest: '''
    <item id="ch1" href="ch1.html" media-type="text/x-oeb1-document"/>''',
          spine: '<itemref idref="ch1"/>',
        ),
        'ch1.html': '''
<html><body><h1>Chapter One</h1><p>First chapter body.</p></body></html>''',
      }),
    );
    expect(_allText(book), contains('First chapter body.'));
  });

  test('falls back to the NCX when the nav document has no TOC entries', () {
    final book = EpubParser().parse(
      _zip({
        'content.opf': _opf(
          manifest: '''
    <item id="nav" href="nav.xhtml" media-type="application/xhtml+xml" properties="nav"/>
    <item id="ncx" href="toc.ncx" media-type="application/x-dtbncx+xml"/>
    <item id="ch1" href="ch1.xhtml" media-type="application/xhtml+xml"/>
    <item id="ch2" href="ch2.xhtml" media-type="application/xhtml+xml"/>''',
          spine: '<itemref idref="ch1"/><itemref idref="ch2"/>',
          toc: 'ncx',
        ),
        'nav.xhtml': '''
<html><body><nav epub:type="toc"><ol></ol></nav></body></html>''',
        'toc.ncx': '''
<?xml version="1.0" encoding="utf-8"?>
<ncx xmlns="http://www.daisy.org/z3986/2005/ncx/" version="2005-1">
  <navMap>
    <navPoint id="n1"><navLabel><text>The First</text></navLabel>
      <content src="ch1.xhtml"/></navPoint>
    <navPoint id="n2"><navLabel><text>The Second</text></navLabel>
      <content src="ch2.xhtml"/></navPoint>
  </navMap>
</ncx>''',
        'ch1.xhtml': '''
<html><body><h1>Chapter One</h1><p>First chapter body.</p></body></html>''',
        'ch2.xhtml': '''
<html><body><h1>Chapter Two</h1><p>Second chapter body.</p></body></html>''',
      }),
    );
    expect(book.chapters.map((chapter) => chapter.title), [
      'The First',
      'The Second',
    ]);
    expect(_allText(book), contains('Second chapter body.'));
  });

  test('self-closing script tags in XHTML do not swallow the body', () {
    final book = EpubParser().parse(
      _zip({
        'content.opf': _opf(
          manifest: '''
    <item id="ch1" href="ch1.xhtml" media-type="application/xhtml+xml"/>''',
          spine: '<itemref idref="ch1"/>',
        ),
        'ch1.xhtml': '''
<?xml version="1.0" encoding="utf-8"?>
<html xmlns="http://www.w3.org/1999/xhtml">
<head><title>One</title><script src="book.js" /></head>
<body><h1>Chapter One</h1><p>First chapter body.</p></body>
</html>''',
      }),
    );
    expect(_allText(book), contains('First chapter body.'));
  });

  test('recognises a TOC nav labelled with role instead of epub:type', () {
    final book = EpubParser().parse(
      _zip({
        'content.opf': _opf(
          manifest: '''
    <item id="nav" href="nav.xhtml" media-type="application/xhtml+xml" properties="nav"/>
    <item id="ch1" href="ch1.xhtml" media-type="application/xhtml+xml"/>
    <item id="ch2" href="ch2.xhtml" media-type="application/xhtml+xml"/>''',
          spine: '<itemref idref="ch1"/><itemref idref="ch2"/>',
        ),
        'nav.xhtml': '''
<html><body>
<nav role="doc-toc"><ol>
<li><a href="ch1.xhtml">Chapter One</a></li>
<li><a href="ch2.xhtml">Chapter Two</a></li>
</ol></nav>
<nav role="doc-landmarks"><ol><li><a href="ch1.xhtml">Start</a></li></ol></nav>
</body></html>''',
        'ch1.xhtml': '''
<html><body><h1>Chapter One</h1><p>First chapter body.</p></body></html>''',
        'ch2.xhtml': '''
<html><body><h1>Chapter Two</h1><p>Second chapter body.</p></body></html>''',
      }),
    );
    expect(book.chapters.first.title, 'Chapter One');
    expect(_allText(book), contains('First chapter body.'));
    expect(_allText(book), contains('Second chapter body.'));
  });
}
