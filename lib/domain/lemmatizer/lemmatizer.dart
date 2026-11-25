import 'dart:math' as math;

import 'irregular_words.dart';

/// A single interpretation of a surface form.
class LemmaHypothesis {
  const LemmaHypothesis({
    required this.lemma,
    required this.confidence,
    required this.method,
  });

  final String lemma;
  final double confidence;
  final String method;

  @override
  bool operator ==(Object other) =>
      other is LemmaHypothesis &&
      other.lemma == lemma &&
      other.method == method;

  @override
  int get hashCode => Object.hash(lemma, method);
}

class LemmatizationResult {
  const LemmatizationResult({
    required this.lemma,
    required this.confidence,
    required this.method,
    required this.surface,
  });

  final String lemma;
  final double confidence;
  final String method;
  final String surface;
}

/// Dictionary-backed, rule-driven English lemmatizer.
///
/// The lexicon is a set of base lemmas. Candidates produced by morphology rules
/// are only accepted when they exist in the lexicon, which prevents damaging
/// over-stripping (for example "business" -> "busines"). No POS tagging is used.
class Lemmatizer {
  Lemmatizer({required this.lexicon, this.irregulars = irregularLemmas});

  final Set<String> lexicon;
  final Map<String, List<String>> irregulars;

  bool isLexical(String word) => lexicon.contains(word.toLowerCase());

  LemmatizationResult lemmatize(String surface) {
    final normalized = _normalize(surface);
    if (normalized.isEmpty) {
      return LemmatizationResult(
        lemma: normalized,
        confidence: 0,
        method: 'empty',
        surface: normalized,
      );
    }
    final irregular = irregulars[normalized];
    if (irregular != null && irregular.isNotEmpty) {
      return LemmatizationResult(
        lemma: irregular.first,
        confidence: 0.98,
        method: 'irregular',
        surface: normalized,
      );
    }
    if (suffixProtectedWords.contains(normalized)) {
      return LemmatizationResult(
        lemma: normalized,
        confidence: 0.95,
        method: 'lexical',
        surface: normalized,
      );
    }
    if (normalized.contains("'")) {
      if (normalized.endsWith("'s") && normalized.length > 3) {
        final base = normalized.substring(0, normalized.length - 2);
        final inner = lemmatize(base);
        return LemmatizationResult(
          lemma: inner.lemma,
          confidence: math.min(inner.confidence, 0.85),
          method: 'possessive',
          surface: normalized,
        );
      }
      return LemmatizationResult(
        lemma: normalized,
        confidence: 0.9,
        method: 'contraction',
        surface: normalized,
      );
    }

    final hypotheses = _hypotheses(normalized);
    if (hypotheses.isNotEmpty) {
      final best = hypotheses.first;
      return LemmatizationResult(
        lemma: best.lemma,
        confidence: best.confidence,
        method: best.method,
        surface: normalized,
      );
    }

    return LemmatizationResult(
      lemma: normalized,
      confidence: lexicon.contains(normalized) ? 0.95 : 0.55,
      method: lexicon.contains(normalized) ? 'lexical' : 'unknown',
      surface: normalized,
    );
  }

  /// All credible lemmas for a surface form, used by the ambiguity UI. The
  /// surface itself is included when it is an independent dictionary word.
  List<LemmaHypothesis> candidatesFor(String surface) {
    final normalized = _normalize(surface);
    final result = <LemmaHypothesis>[];
    void add(String lemma, double confidence, String method) {
      if (lemma.isEmpty) return;
      if (result.any((item) => item.lemma == lemma)) return;
      result.add(
        LemmaHypothesis(lemma: lemma, confidence: confidence, method: method),
      );
    }

    final primary = lemmatize(normalized);
    add(primary.lemma, primary.confidence, primary.method);
    for (final hypothesis in _hypotheses(normalized)) {
      add(hypothesis.lemma, hypothesis.confidence, hypothesis.method);
    }
    final irregular = irregulars[normalized];
    if (irregular != null) {
      for (final lemma in irregular) {
        add(lemma, 0.9, 'irregular');
      }
    }
    if (lexicon.contains(normalized) && normalized != primary.lemma) {
      add(normalized, 0.72, 'surface');
    }
    result.sort((a, b) => b.confidence.compareTo(a.confidence));
    return result;
  }

  List<LemmaHypothesis> _hypotheses(String word) {
    if (word.length < 3) return const [];
    final byLemma = <String, LemmaHypothesis>{};
    void offer(String candidate, double confidence, String method) {
      if (candidate == word || candidate.length < 2) return;
      if (!lexicon.contains(candidate)) return;
      final existing = byLemma[candidate];
      if (existing == null || confidence > existing.confidence) {
        byLemma[candidate] = LemmaHypothesis(
          lemma: candidate,
          confidence: confidence,
          method: method,
        );
      }
    }

    // -ly adverbs and adverbs in -ily.
    if (word.length > 4 && word.endsWith('ily')) {
      offer('${word.substring(0, word.length - 3)}y', 0.8, 'adverb');
    } else if (word.length > 4 && word.endsWith('ly')) {
      final stem = word.substring(0, word.length - 2);
      final reductions = _hypotheses(stem);
      if (reductions.isNotEmpty) {
        offer(reductions.first.lemma, 0.79, 'adverb');
      } else {
        offer(stem, 0.78, 'adverb');
      }
    }

    // Comparative and superlative. Avoid reducing lexical nouns such as
    // "corner" or "flower"; those are not inflectional comparatives.
    if (!lexicon.contains(word)) {
      if (word.length > 4 && word.endsWith('ier')) {
        offer('${word.substring(0, word.length - 3)}y', 0.87, 'comparative');
      } else if (word.length > 4 && word.endsWith('iest')) {
        offer('${word.substring(0, word.length - 4)}y', 0.88, 'superlative');
      } else if (word.length > 4 && word.endsWith('er')) {
        final stem = word.substring(0, word.length - 2);
        if (lexicon.contains(stem)) {
          offer(stem, 0.8, 'comparative');
        } else if (stem.length > 2 && _isDoubledConsonant(stem)) {
          offer(stem.substring(0, stem.length - 1), 0.89, 'comparative');
        }
        if (word.endsWith('r')) {
          offer(word.substring(0, word.length - 1), 0.86, 'comparative');
        }
      } else if (word.length > 5 && word.endsWith('est')) {
        final stem = word.substring(0, word.length - 3);
        if (lexicon.contains(stem)) {
          offer(stem, 0.8, 'superlative');
        } else if (stem.length > 2 && _isDoubledConsonant(stem)) {
          offer(stem.substring(0, stem.length - 1), 0.89, 'superlative');
        }
        if (word.endsWith('t')) {
          offer(word.substring(0, word.length - 2), 0.86, 'superlative');
        }
      }
    }

    // Present participle / gerund.
    if (word.length >= 5 && word.endsWith('ing')) {
      final stem = word.substring(0, word.length - 3);
      if (word.endsWith('ying')) {
        offer('${stem.substring(0, stem.length - 1)}ie', 0.93, 'participle');
      }
      if (lexicon.contains(stem)) {
        offer(stem, 0.9, 'participle');
      } else if (_hasDoubleFinal(stem)) {
        offer(stem.substring(0, stem.length - 1), 0.94, 'participle');
      } else {
        offer(stem, 0.87, 'participle');
        if (_shouldRestoreSilentE(stem) || stem.endsWith('u')) {
          offer('${stem}e', 0.92, 'participle');
        }
      }
    }

    // Simple past / past participle in -ed.
    if (word.length >= 4 && word.endsWith('ied')) {
      offer('${word.substring(0, word.length - 3)}y', 0.91, 'past');
    } else if (word.length >= 4 && word.endsWith('ed')) {
      final withoutD = word.substring(0, word.length - 1);
      offer(withoutD, 0.94, 'past'); // loved -> love
      final stem = word.substring(0, word.length - 2);
      if (lexicon.contains(stem)) {
        offer(stem, 0.91, 'past');
      } else if (_hasDoubleFinal(stem)) {
        offer(stem.substring(0, stem.length - 1), 0.93, 'past');
      } else {
        offer(stem, 0.89, 'past');
      }
    }

    // Plural / third person singular.
    if (word.length > 3 && word.endsWith('ies')) {
      offer('${word.substring(0, word.length - 3)}y', 0.93, 'plural');
    }
    if (word.length > 4 && word.endsWith('ves')) {
      final stem = word.substring(0, word.length - 3);
      offer('${stem}f', 0.88, 'plural');
      offer('${stem}fe', 0.87, 'plural');
    }
    if (word.length > 4 &&
        (word.endsWith('ses') ||
            word.endsWith('xes') ||
            word.endsWith('zes') ||
            word.endsWith('ches') ||
            word.endsWith('shes') ||
            word.endsWith('oes'))) {
      offer(word.substring(0, word.length - 2), 0.91, 'plural');
      offer(word.substring(0, word.length - 1), 0.83, 'plural');
    } else if (word.length > 3 &&
        word.endsWith('s') &&
        !word.endsWith('ss') &&
        !word.endsWith('us') &&
        !word.endsWith('is')) {
      offer(word.substring(0, word.length - 1), 0.9, 'plural');
    }

    final values = byLemma.values.toList();
    values.sort((a, b) {
      final score = b.confidence.compareTo(a.confidence);
      if (score != 0) return score;
      // When confidence ties, prefer the more specific (longer) lemma, which
      // distinguishes uses -> use from uses -> us.
      return b.lemma.length.compareTo(a.lemma.length);
    });
    return values;
  }

  static bool _hasDoubleFinal(String value) {
    if (value.length < 2) return false;
    final last = value.codeUnitAt(value.length - 1);
    final previous = value.codeUnitAt(value.length - 2);
    if (last != previous) return false;
    const vowels = {97, 101, 105, 111, 117};
    return !vowels.contains(last);
  }

  static bool _isDoubledConsonant(String value) {
    if (value.length < 2) return false;
    final last = value.codeUnitAt(value.length - 1);
    final previous = value.codeUnitAt(value.length - 2);
    if (last != previous) return false;
    const vowels = {97, 101, 105, 111, 117};
    if (vowels.contains(last)) return false;
    // Keep lexical doubles such as ll, ss, ff, zz.
    if (last == 108 || last == 115 || last == 102 || last == 122) {
      return false;
    }
    return true;
  }

  static bool _shouldRestoreSilentE(String stem) {
    if (stem.length < 2) return false;
    final last = stem.codeUnitAt(stem.length - 1);
    final previous = stem.codeUnitAt(stem.length - 2);
    const vowels = {97, 101, 105, 111, 117};
    final lastIsConsonant = !vowels.contains(last) && last >= 97 && last <= 122;
    return lastIsConsonant && vowels.contains(previous);
  }

  static String _normalize(String value) =>
      value.toLowerCase().replaceAll('’', "'").trim();
}
