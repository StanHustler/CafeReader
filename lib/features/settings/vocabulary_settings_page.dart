import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/design/app_theme.dart';
import '../../data/repository/settings_repository.dart';
import 'settings_widgets.dart';

class VocabularySettingsPage extends ConsumerWidget {
  const VocabularySettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings =
        ref.watch(readerSettingsProvider).valueOrNull ?? const ReaderSettings();
    final palette = CafePalette.of(context);
    final repo = ref.read(settingsRepositoryProvider);

    return SettingsScaffold(
      title: 'Vocabulary',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SettingsSection(
            title: 'Word recognition',
            children: [
              SettingsSwitchRow(
                icon: Icons.auto_stories_outlined,
                title: 'Dictionary lemmatization',
                subtitle:
                    'Associate cats → cat, ran → run, went → go. When off, every '
                    'spelling becomes its own vocabulary entry. Applies when a word '
                    'is first opened in the reader.',
                value: settings.lemmatizerEnabled,
                onChanged: (value) => repo.setBool('lemmatizer_enabled', value),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Lemmatization uses a bundled WordNet 3.0 lemma lexicon, '
                  'irregular-form tables, and suffix rules. It does not use POS '
                  'tagging. A word is never forced into a lemma when no dictionary '
                  'candidate can be verified.',
                  style: Theme.of(context).textTheme.bodySmall
                      ?.copyWith(color: palette.inkMuted, height: 1.5),
                ),
              ),
            ],
          ),
          SettingsSection(
            title: 'Ambiguity and corrections',
            children: const [
              SettingsInfoTile(
                icon: Icons.call_split,
                title: 'A spelling can have several senses',
                body:
                    '“saw” can belong to see or to saw, the tool. CafeReader '
                    'keeps each sense as an independent vocabulary entry with '
                    'its own state.',
              ),
              SettingsInfoTile(
                icon: Icons.pin_drop_outlined,
                title: 'Corrections have explicit scope',
                body:
                    'When fixing a word you choose: this occurrence, this '
                    'book, or the global form association. Global form changes '
                    'never rewrite individual manual corrections.',
              ),
              SettingsInfoTile(
                icon: Icons.touch_app_outlined,
                title: 'You are always the final authority',
                body:
                    'Open a word in the reader and choose Fix word identity to '
                    'see dictionary-backed candidate senses.',
              ),
            ],
          ),
          Text(
            'Changing lemmatization does not rewrite already-indexed books. '
            'Re-import a book if you want a fresh index with different settings.',
            style: Theme.of(context).textTheme.bodySmall
                ?.copyWith(color: palette.inkMuted),
          ),
        ],
      ),
    );
  }
}
