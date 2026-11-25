import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../data/repository/settings_repository.dart';
import 'settings_widgets.dart';

class FsrsSettingsPage extends ConsumerStatefulWidget {
  const FsrsSettingsPage({super.key});

  @override
  ConsumerState<FsrsSettingsPage> createState() => _FsrsSettingsPageState();
}

class _FsrsSettingsPageState extends ConsumerState<FsrsSettingsPage> {
  late FsrsSettings _settings;
  bool _loaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_loaded) {
      _settings =
          ref.read(fsrsSettingsProvider).valueOrNull ?? const FsrsSettings();
      _loaded = true;
    }
  }

  Future<void> _persist() async {
    final repo = ref.read(settingsRepositoryProvider);
    await repo.setInt('fsrs_daily_new_limit', _settings.dailyNewLimit);
    await repo.setInt('fsrs_daily_review_limit', _settings.dailyReviewLimit);
    await repo.setDouble('fsrs_desired_retention', _settings.desiredRetention);
  }

  void _update(FsrsSettings next) => setState(() => _settings = next);

  @override
  Widget build(BuildContext context) {
    return SettingsScaffold(
      title: 'FSRS review',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SettingsHero(
            icon: Icons.tune,
            title: 'A daily ceiling, never a quota',
            body:
                'The limits below govern how much of your Learning queue can '
                'be reviewed per day. New cards count against the new-word '
                'allowance; all reviews count against the review limit.',
          ),
          const SizedBox(height: 24),
          SettingsSection(
            title: 'Daily workload',
            children: [
              SettingsSliderRow(
                title: 'New word limit',
                subtitle: 'Learning cards that have never been reviewed.',
                value: _settings.dailyNewLimit.toDouble(),
                min: 0,
                max: 100,
                divisions: 100,
                display: '${_settings.dailyNewLimit}',
                onChanged: (value) => _update(
                  FsrsSettings(
                    dailyNewLimit: value.round(),
                    dailyReviewLimit: _settings.dailyReviewLimit,
                    desiredRetention: _settings.desiredRetention,
                  ),
                ),
                onChangeEnd: (_) => _persist(),
              ),
              SettingsSliderRow(
                title: 'Review limit',
                subtitle: 'Maximum cards scheduled in one session.',
                value: _settings.dailyReviewLimit.toDouble(),
                min: 10,
                max: 500,
                divisions: 49,
                display: '${_settings.dailyReviewLimit}',
                onChanged: (value) => _update(
                  FsrsSettings(
                    dailyNewLimit: _settings.dailyNewLimit,
                    dailyReviewLimit: (value / 10).round() * 10,
                    desiredRetention: _settings.desiredRetention,
                  ),
                ),
                onChangeEnd: (_) => _persist(),
              ),
            ],
          ),
          SettingsSection(
            title: 'Memory target',
            description:
                'Higher retention asks for shorter intervals and more reviews.',
            children: [
              SettingsSliderRow(
                title: 'Desired retention',
                value: _settings.desiredRetention,
                min: 0.70,
                max: 0.99,
                divisions: 29,
                display: '${(_settings.desiredRetention * 100).round()}%',
                onChanged: (value) => _update(
                  FsrsSettings(
                    dailyNewLimit: _settings.dailyNewLimit,
                    dailyReviewLimit: _settings.dailyReviewLimit,
                    desiredRetention: value,
                  ),
                ),
                onChangeEnd: (_) => _persist(),
              ),
            ],
          ),
          SettingsSection(
            title: 'How scheduling works',
            children: const [
              SettingsInfoTile(
                icon: Icons.schedule,
                title: 'Again / Hard / Good / Easy',
                body:
                    'Ratings update memory stability and difficulty using '
                    'FSRS-5. A lapsed word enters relearning; the next due '
                    'time is shown in the Deck.',
              ),
              SettingsInfoTile(
                icon: Icons.layers_outlined,
                title: 'Learning is a separate queue',
                body:
                    'Only words you explicitly add to Learning get FSRS cards. '
                    'Turning pages never promotes a Learning word to Known.',
              ),
              SettingsInfoTile(
                icon: Icons.history,
                title: 'Review history is preserved',
                body:
                    'Every rating is stored with the before/after state, '
                    'stability, interval, and due date so devices can merge '
                    'histories.',
              ),
            ],
          ),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton(
              onPressed: () {
                _persist();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('FSRS settings saved.')),
                );
              },
              child: const Text('Save changes'),
            ),
          ),
        ],
      ),
    );
  }
}
