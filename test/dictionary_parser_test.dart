import 'dart:convert';

import 'package:cafereader/data/local/dictionary_file_parser.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses a headed CSV dictionary', () {
    final parsed = DictionaryFileParser.parse(
      'lemma,meaning,pos\nCat,feline,n.\ncat,a small animal,n.\n',
      fileName: 'animals.csv',
    );

    expect(parsed.name, 'animals');
    expect(parsed.entries, hasLength(2));
    expect(parsed.entries.first.lemma, 'cat');
    expect(parsed.entries.first.partOfSpeech, 'n.');
  });

  test('parses headerless TSV with word and meaning', () {
    final parsed = DictionaryFileParser.parse(
      'cat\t猫\nrun\t跑\n',
      fileName: 'zh.tsv',
    );

    expect(parsed.entries, hasLength(2));
    expect(parsed.entries[0].lemma, 'cat');
    expect(parsed.entries[0].meaning, '猫');
    expect(parsed.entries[1].lemma, 'run');
  });

  test('parses a JSON dictionary with metadata and several meanings', () {
    final parsed = DictionaryFileParser.parse(
      jsonEncode({
        'name': 'My dictionary',
        'entries': {
          'cat': ['猫', '猫科动物'],
          'run': {'meaning': '跑', 'pos': 'v', 'example': 'run fast'},
        },
      }),
      fileName: 'custom.json',
    );

    expect(parsed.name, 'My dictionary');
    expect(parsed.entries, hasLength(3));
    expect(parsed.entries.where((entry) => entry.lemma == 'cat'), hasLength(2));
    final run = parsed.entries.firstWhere((entry) => entry.lemma == 'run');
    expect(run.partOfSpeech, 'v');
    expect(run.example, 'run fast');
  });

  test('parses a JSON list of entry objects', () {
    final parsed = DictionaryFileParser.parse(
      jsonEncode([
        {'word': 'cat', 'definition': 'feline', 'pos': 'n'},
        {'word': 'run', 'translation': 'move quickly'},
      ]),
      fileName: 'list.json',
    );

    expect(parsed.name, 'list');
    expect(parsed.entries, hasLength(2));
  });

  test('rejects an empty dictionary', () {
    expect(
      () => DictionaryFileParser.parse('', fileName: 'empty.csv'),
      throwsA(isA<FormatException>()),
    );
  });
}
