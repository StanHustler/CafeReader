import 'dart:math' as math;

enum ReviewRating {
  again(1, 'Again'),
  hard(2, 'Hard'),
  good(3, 'Good'),
  easy(4, 'Easy');

  const ReviewRating(this.value, this.label);
  final int value;
  final String label;

  static ReviewRating fromValue(int value) => switch (value) {
    1 => again,
    2 => hard,
    3 => good,
    4 => easy,
    _ => good,
  };
}

enum FsrsState {
  newCard('new'),
  learning('learning'),
  review('review'),
  relearning('relearning');

  const FsrsState(this.value);
  final String value;

  static FsrsState fromValue(String value) => FsrsState.values.firstWhere(
    (state) => state.value == value,
    orElse: () => FsrsState.newCard,
  );
}

class FsrsScheduling {
  const FsrsScheduling({
    required this.state,
    required this.due,
    required this.stability,
    required this.difficulty,
    required this.elapsedDays,
    required this.scheduledDays,
    required this.reps,
    required this.lapses,
    required this.lastReview,
    required this.intervalDays,
  });

  final FsrsState state;
  final DateTime due;
  final double stability;
  final double difficulty;
  final int elapsedDays;
  final int scheduledDays;
  final int reps;
  final int lapses;
  final DateTime lastReview;
  final int intervalDays;
}

/// A self-contained FSRS-5 scheduler.
///
/// It only computes memory scheduling. User-visible vocabulary states remain
/// owned by the vocabulary repository; this scheduler never promotes a card to
/// Known.
class FsrsScheduler {
  const FsrsScheduler({
    this.weights = defaultWeights,
    this.desiredRetention = 0.9,
  });

  final List<double> weights;
  final double desiredRetention;

  static const List<double> defaultWeights = [
    0.40255,
    1.18385,
    3.173,
    15.69105,
    7.1949,
    0.5345,
    1.4604,
    0.0046,
    1.54575,
    0.1192,
    1.01925,
    1.9395,
    0.11,
    0.29605,
    2.2698,
    0.2315,
    2.9898,
    0.51655,
    0.6621,
  ];

  static const double _decay = -0.5;
  static const double _factor = 19 / 81;

  FsrsScheduling schedule({
    required ReviewRating rating,
    required FsrsState state,
    required double stability,
    required double difficulty,
    required int reps,
    required int lapses,
    DateTime? lastReview,
    DateTime? now,
  }) {
    final current = now ?? DateTime.now();
    final elapsedDays = lastReview == null
        ? 0
        : math.max(0, current.difference(lastReview).inDays);
    if (state == FsrsState.newCard || reps == 0 || stability <= 0) {
      final s = weights[rating.value - 1];
      final d = _initialDifficulty(rating);
      final interval = _initialInterval(rating, s);
      final due = interval < 1
          ? current.add(const Duration(minutes: 10))
          : current.add(Duration(days: interval.round()));
      final nextState = switch (rating) {
        ReviewRating.again || ReviewRating.hard => FsrsState.learning,
        _ => FsrsState.review,
      };
      return FsrsScheduling(
        state: nextState,
        due: due,
        stability: s,
        difficulty: d,
        elapsedDays: elapsedDays,
        scheduledDays: interval,
        reps: 1,
        lapses: lapses + (rating == ReviewRating.again ? 1 : 0),
        lastReview: current,
        intervalDays: interval,
      );
    }

    final retrievability = _retrievability(elapsedDays, stability);
    final updatedDifficulty = _nextDifficulty(difficulty, rating);
    late double updatedStability;
    late FsrsState nextState;
    late int interval;
    if (rating == ReviewRating.again) {
      final forgotten =
          weights[11] *
          math.pow(updatedDifficulty, -weights[12]) *
          (math.pow(stability + 1, weights[13]) - 1) *
          math.exp(weights[14] * (1 - retrievability));
      updatedStability = math.min(forgotten.toDouble(), stability);
      updatedStability = math.max(updatedStability, 0.01);
      nextState = FsrsState.relearning;
      interval = 0;
    } else {
      final hardPenalty = rating == ReviewRating.hard ? weights[15] : 1.0;
      final easyBonus = rating == ReviewRating.easy ? weights[16] : 1.0;
      final growth =
          math.exp(weights[8]) *
          (11 - updatedDifficulty) *
          math.pow(stability, -weights[9]) *
          (math.exp(weights[10] * (1 - retrievability)) - 1) *
          hardPenalty *
          easyBonus;
      updatedStability = math.max(0.01, stability * (1 + growth));
      nextState = FsrsState.review;
      interval = _intervalForStability(updatedStability);
    }

    final due = interval < 1
        ? current.add(const Duration(minutes: 10))
        : current.add(Duration(days: interval));
    return FsrsScheduling(
      state: nextState,
      due: due,
      stability: updatedStability,
      difficulty: updatedDifficulty,
      elapsedDays: elapsedDays,
      scheduledDays: interval,
      reps: reps + 1,
      lapses: lapses + (rating == ReviewRating.again ? 1 : 0),
      lastReview: current,
      intervalDays: interval,
    );
  }

  double _initialDifficulty(ReviewRating rating) {
    final d = weights[4] - math.exp(weights[5] * (rating.value - 1)) + 1;
    return d.clamp(1.0, 10.0).toDouble();
  }

  double _nextDifficulty(double difficulty, ReviewRating rating) {
    final delta = -weights[6] * (rating.value - 3);
    final next = difficulty + delta;
    final meanReversion =
        weights[7] * _initialDifficulty(ReviewRating.easy) +
        (1 - weights[7]) * next;
    return meanReversion.clamp(1.0, 10.0).toDouble();
  }

  double _retrievability(int elapsedDays, double stability) {
    if (stability <= 0) return 0;
    return math.pow(1 + _factor * elapsedDays / stability, _decay).toDouble();
  }

  int _intervalForStability(double stability) {
    final retention = desiredRetention.clamp(0.70, 0.99);
    final interval =
        stability / _factor * (math.pow(retention, 1 / _decay) - 1);
    return math.max(1, interval.round());
  }

  int _initialInterval(ReviewRating rating, double stability) {
    if (rating == ReviewRating.again) return 0;
    if (rating == ReviewRating.hard) return 1;
    return _intervalForStability(stability);
  }
}
