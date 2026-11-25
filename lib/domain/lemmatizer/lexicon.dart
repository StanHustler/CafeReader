import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';

class DictionarySense {
  const DictionarySense({
    required this.lemma,
    required this.partOfSpeech,
    required this.meaning,
  });

  final String lemma;
  final String partOfSpeech;
  final String meaning;
}

/// Loads the bundled lemma lexicon and the optional WordNet gloss database.
///
/// Definitions are intentionally loaded separately from lemmas: importing a
/// book only needs the compact lemma set, while the much larger gloss file is
/// only decompressed when a definition is actually shown.
class LemmaLexicon {
  LemmaLexicon({required this.lemmas, this.loadGlosses});

  final Set<String> lemmas;
  final Future<List<DictionarySense>> Function()? loadGlosses;

  static Future<LemmaLexicon> load({AssetBundle? bundle}) async {
    final assets = bundle ?? rootBundle;
    // Decode inline rather than through AssetBundle.loadString: for assets
    // over 50 KB that helper hands the UTF-8 work to `compute`, and the
    // helper isolate starts paused under some debuggers. Startup then waits
    // on the launch screen until the isolate is manually resumed.
    final data = await assets.load('assets/dictionary/lemmas.txt');
    final raw = utf8.decode(
      data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
    );
    final lemmas = raw
        .split('\n')
        .map((line) => line.trim().toLowerCase())
        .where((line) => line.isNotEmpty && !line.startsWith('#'))
        .toSet();
    return LemmaLexicon(
      lemmas: lemmas,
      loadGlosses: () async {
        final data = await assets.load('assets/dictionary/glosses.tsv.gz');
        final decoded = utf8.decode(gzip.decode(data.buffer.asUint8List()));
        final senses = <DictionarySense>[];
        for (final line in const LineSplitter().convert(decoded)) {
          final first = line.indexOf('\t');
          if (first < 0) continue;
          final second = line.indexOf('\t', first + 1);
          if (second < 0) continue;
          senses.add(
            DictionarySense(
              lemma: line.substring(0, first),
              partOfSpeech: line.substring(first + 1, second),
              meaning: line.substring(second + 1),
            ),
          );
        }
        return senses;
      },
    );
  }

  /// Convenience constructor for tests and non-asset builds.
  factory LemmaLexicon.fromWords(Iterable<String> words) =>
      LemmaLexicon(lemmas: words.map((word) => word.toLowerCase()).toSet());
}
