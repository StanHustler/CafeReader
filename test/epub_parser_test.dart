import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:cafereader/domain/epub/book_parser.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses EPUB metadata, cover, navigation and chapter text', () {
    final bytes = _buildEpub();
    final book = EpubParser().parse(bytes, fallbackTitle: 'Fallback');
    expect(book.title, 'A Quiet Book');
    expect(book.author, 'Ada Reader');
    expect(book.description, 'A small description.');
    expect(book.language, 'en');
    expect(book.coverExtension, 'png');
    expect(book.coverBytes, isNotEmpty);
    expect(book.chapters, hasLength(2));
    expect(book.chapters[0].title, 'A Beginning');
    expect(book.chapters[1].title, 'A Middle');
    expect(
      book.chapters[0].content,
      contains('The planet is surprisingly beautiful.'),
    );
    expect(book.chapters[0].content, contains('Second paragraph.'));
    expect(book.chapters[0].content, isNot(contains('script')));
  });

  test('rejects non-EPUB bytes cleanly', () {
    expect(
      () => EpubParser().parse(Uint8List.fromList(utf8.encode('not a zip'))),
      throwsA(isA<BookParseException>()),
    );
  });

  test('splits chapters by the table of contents, not by spine files', () {
    final book = EpubParser().parse(_buildTocSplitEpub());
    expect(book.chapters, hasLength(2));
    expect(book.chapters[0].title, 'First Part');
    expect(book.chapters[1].title, 'Second Part');
    expect(book.chapters[0].content, contains('Alpha body.'));
    expect(book.chapters[0].content, isNot(contains('Beta body.')));
    expect(book.chapters[0].content, isNot(contains('The Big Book')));
    expect(book.chapters[1].content, contains('Beta body.'));
  });

  test('falls back to spine order when the EPUB has no table of contents', () {
    final book = EpubParser().parse(_buildNoTocEpub());
    expect(book.chapters, hasLength(2));
    expect(book.chapters[0].title, 'First Part');
    expect(book.chapters[1].title, 'Second Part');
    expect(book.chapters[0].content, contains('Alpha body.'));
    expect(book.chapters[1].content, contains('Beta body.'));
  });
}

Uint8List _buildTocSplitEpub() {
  const container = '''
<?xml version="1.0"?>
<container version="1.0"
  xmlns="urn:oasis:names:tc:opendocument:xmlns:container">
  <rootfiles>
    <rootfile full-path="OEBPS/content.opf"
      media-type="application/oebps-package+xml"/>
  </rootfiles>
</container>
''';
  const opf = '''
<?xml version="1.0" encoding="utf-8"?>
<package xmlns="http://www.idpf.org/2007/opf" version="3.0">
  <metadata xmlns:dc="http://purl.org/dc/elements/1.1/">
    <dc:title>The Big Book</dc:title>
    <dc:language>en</dc:language>
  </metadata>
  <manifest>
    <item id="nav" href="nav.xhtml" media-type="application/xhtml+xml" properties="nav"/>
    <item id="titlepage" href="titlepage.xhtml" media-type="application/xhtml+xml"/>
    <item id="body" href="book.xhtml" media-type="application/xhtml+xml"/>
  </manifest>
  <spine>
    <itemref idref="titlepage"/>
    <itemref idref="body"/>
  </spine>
</package>
''';
  const nav = '''
<?xml version="1.0" encoding="utf-8"?>
<html xmlns="http://www.w3.org/1999/xhtml"
      xmlns:epub="http://www.idpf.org/2007/ops">
<body><nav epub:type="toc"><ol>
  <li><a href="book.xhtml#part1">First Part</a></li>
  <li><a href="book.xhtml#part2">Second Part</a></li>
</ol></nav></body></html>
''';
  const titlepage = '''
<html xmlns="http://www.w3.org/1999/xhtml"><body>
<h1>The Big Book</h1><p>By Someone</p>
</body></html>
''';
  const book = '''
<html xmlns="http://www.w3.org/1999/xhtml"><body>
<h1>The Big Book</h1>
<section id="part1"><h2>First Part</h2><p>Alpha body.</p></section>
<section id="part2"><h2>Second Part</h2><p>Beta body.</p></section>
</body></html>
''';
  final archive = Archive()
    ..addFile(ArchiveFile.string('mimetype', 'application/epub+zip'))
    ..addFile(ArchiveFile.string('META-INF/container.xml', container))
    ..addFile(ArchiveFile.string('OEBPS/content.opf', opf))
    ..addFile(ArchiveFile.string('OEBPS/nav.xhtml', nav))
    ..addFile(ArchiveFile.string('OEBPS/titlepage.xhtml', titlepage))
    ..addFile(ArchiveFile.string('OEBPS/book.xhtml', book));
  return Uint8List.fromList(ZipEncoder().encode(archive));
}

Uint8List _buildNoTocEpub() {
  const container = '''
<?xml version="1.0"?>
<container version="1.0"
  xmlns="urn:oasis:names:tc:opendocument:xmlns:container">
  <rootfiles>
    <rootfile full-path="OEBPS/content.opf"
      media-type="application/oebps-package+xml"/>
  </rootfiles>
</container>
''';
  const opf = '''
<?xml version="1.0" encoding="utf-8"?>
<package xmlns="http://www.idpf.org/2007/opf" version="3.0">
  <metadata xmlns:dc="http://purl.org/dc/elements/1.1/">
    <dc:title>The Big Book</dc:title>
    <dc:language>en</dc:language>
  </metadata>
  <manifest>
    <item id="ch1" href="ch1.xhtml" media-type="application/xhtml+xml"/>
    <item id="ch2" href="ch2.xhtml" media-type="application/xhtml+xml"/>
  </manifest>
  <spine>
    <itemref idref="ch1"/>
    <itemref idref="ch2"/>
  </spine>
</package>
''';
  const ch1 = '''
<html xmlns="http://www.w3.org/1999/xhtml"><body>
<h1>First Part</h1><p>Alpha body.</p>
</body></html>
''';
  const ch2 = '''
<html xmlns="http://www.w3.org/1999/xhtml"><body>
<h1>Second Part</h1><p>Beta body.</p>
</body></html>
''';
  final archive = Archive()
    ..addFile(ArchiveFile.string('mimetype', 'application/epub+zip'))
    ..addFile(ArchiveFile.string('META-INF/container.xml', container))
    ..addFile(ArchiveFile.string('OEBPS/content.opf', opf))
    ..addFile(ArchiveFile.string('OEBPS/ch1.xhtml', ch1))
    ..addFile(ArchiveFile.string('OEBPS/ch2.xhtml', ch2));
  return Uint8List.fromList(ZipEncoder().encode(archive));
}

Uint8List _buildEpub() {
  const container = '''
<?xml version="1.0"?>
<container version="1.0"
  xmlns="urn:oasis:names:tc:opendocument:xmlns:container">
  <rootfiles>
    <rootfile full-path="OEBPS/content.opf"
      media-type="application/oebps-package+xml"/>
  </rootfiles>
</container>
''';
  const opf = '''
<?xml version="1.0" encoding="utf-8"?>
<package xmlns="http://www.idpf.org/2007/opf" version="3.0">
  <metadata xmlns:dc="http://purl.org/dc/elements/1.1/">
    <dc:title>A Quiet Book</dc:title>
    <dc:creator>Ada Reader</dc:creator>
    <dc:description>&lt;p&gt;A small description.&lt;/p&gt;</dc:description>
    <dc:language>en-US</dc:language>
  </metadata>
  <manifest>
    <item id="nav" href="nav.xhtml" media-type="application/xhtml+xml" properties="nav"/>
    <item id="ch1" href="ch1.xhtml" media-type="application/xhtml+xml"/>
    <item id="ch2" href="ch2.xhtml" media-type="application/xhtml+xml"/>
    <item id="cover" href="images/cover.png" media-type="image/png" properties="cover-image"/>
  </manifest>
  <spine>
    <itemref idref="ch1"/>
    <itemref idref="ch2"/>
  </spine>
</package>
''';
  const nav = '''
<?xml version="1.0" encoding="utf-8"?>
<html xmlns="http://www.w3.org/1999/xhtml"
      xmlns:epub="http://www.idpf.org/2007/ops">
<body><nav epub:type="toc"><ol>
  <li><a href="ch1.xhtml">A Beginning</a></li>
  <li><a href="ch2.xhtml">A Middle</a></li>
</ol></nav></body></html>
''';
  const ch1 = '''
<html xmlns="http://www.w3.org/1999/xhtml"><head>
<title>Chapter one</title><style>p { color: red; }</style>
<script>bad()</script></head><body>
<h1>A Beginning</h1>
<p>The planet is <em>surprisingly</em> beautiful.</p>
<p>Second paragraph.</p>
</body></html>
''';
  const ch2 = '''
<html xmlns="http://www.w3.org/1999/xhtml"><body>
<h1>A Middle</h1><p>Another chapter of quiet text.</p>
</body></html>
''';
  final archive = Archive()
    ..addFile(ArchiveFile.string('mimetype', 'application/epub+zip'))
    ..addFile(ArchiveFile.string('META-INF/container.xml', container))
    ..addFile(ArchiveFile.string('OEBPS/content.opf', opf))
    ..addFile(ArchiveFile.string('OEBPS/nav.xhtml', nav))
    ..addFile(ArchiveFile.string('OEBPS/ch1.xhtml', ch1))
    ..addFile(ArchiveFile.string('OEBPS/ch2.xhtml', ch2))
    ..addFile(
      ArchiveFile('OEBPS/images/cover.png', 4, [0x89, 0x50, 0x4E, 0x47]),
    );
  return Uint8List.fromList(ZipEncoder().encode(archive));
}
