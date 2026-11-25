import 'package:cafereader/core/database/app_database.dart';
import 'package:cafereader/data/repository/settings_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('stored appearance values map to the four modes', () {
    expect(AppAppearanceMode.fromStorage('light'), AppAppearanceMode.light);
    expect(AppAppearanceMode.fromStorage('dark'), AppAppearanceMode.dark);
    expect(AppAppearanceMode.fromStorage('auto'), AppAppearanceMode.auto);
    expect(AppAppearanceMode.fromStorage('eink'), AppAppearanceMode.eink);
    expect(AppAppearanceMode.fromStorage(null), AppAppearanceMode.light);
    expect(AppAppearanceMode.fromStorage('unknown'), AppAppearanceMode.light);
  });

  test('settings repository reads app_theme as an appearance mode', () async {
    final db = AppDatabase.memory();
    addTearDown(db.close);
    final repository = SettingsRepository(db, 'test-device');

    expect(
      repository.appAppearanceFromMap({'app_theme': 'auto'}).mode,
      AppAppearanceMode.auto,
    );
    expect(
      repository.appAppearanceFromMap({'app_theme': 'eink'}).mode,
      AppAppearanceMode.eink,
    );
    expect(
      repository.appAppearanceFromMap(const {}).mode,
      AppAppearanceMode.light,
    );
  });
}
