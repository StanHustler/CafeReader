import 'package:cafereader/domain/lemmatizer/lemmatizer.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Lemmatizer lemmatizer;

  setUp(() {
    lemmatizer = Lemmatizer(
      lexicon: {
        'cat',
        'run',
        'make',
        'use',
        'hope',
        'stop',
        'study',
        'child',
        'go',
        'see',
        'saw',
        'good',
        'surprise',
        'quick',
        'happy',
        'class',
        'box',
        'watch',
        'travel',
        'cancel',
        'need',
        'add',
        'sing',
        'singe',
        'corner',
        'flower',
        'big',
        'call',
        'fall',
        'well',
        'leaf',
        'life',
        'analysis',
      },
    );
  });

  test('handles regular and irregular English inflections', () {
    final cases = {
      'cats': 'cat',
      'running': 'run',
      'ran': 'run',
      'went': 'go',
      'children': 'child',
      'studies': 'study',
      'making': 'make',
      'hoped': 'hope',
      'stopped': 'stop',
      'using': 'use',
      'used': 'use',
      'classes': 'class',
      'boxes': 'box',
      'watches': 'watch',
      'travelled': 'travel',
      'cancelled': 'cancel',
      'added': 'add',
      'needed': 'need',
      'singing': 'sing',
      'called': 'call',
      'fell': 'fall',
      'leaves': 'leaf',
      'lives': 'life',
      'analyses': 'analysis',
      'bases': 'base',
      'better': 'good',
      'quickly': 'quick',
      'happily': 'happy',
      'surprisingly': 'surprise',
    };
    for (final entry in cases.entries) {
      expect(
        lemmatizer.lemmatize(entry.key).lemma,
        entry.value,
        reason: '${entry.key} should reduce to ${entry.value}',
      );
    }
  });

  test('does not over-strip lexical nouns', () {
    expect(lemmatizer.lemmatize('corner').lemma, 'corner');
    expect(lemmatizer.lemmatize('flower').lemma, 'flower');
    expect(lemmatizer.lemmatize('news').lemma, 'news');
  });

  test('offers ambiguity candidates for saw', () {
    final candidates = lemmatizer.candidatesFor('saw');
    final lemmas = candidates.map((candidate) => candidate.lemma).toSet();
    expect(lemmas, containsAll(['see', 'saw']));
    expect(candidates.first.lemma, 'see');
  });

  test('unknown words stay themselves with low confidence', () {
    final result = lemmatizer.lemmatize('qzxunknown');
    expect(result.lemma, 'qzxunknown');
    expect(result.confidence, lessThan(0.7));
  });
}
