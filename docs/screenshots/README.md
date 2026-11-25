# Verification screenshots

These images are captured from the Windows integration test
(`integration_test/app_test.dart`) at a 1280×1000 logical viewport. The test
imports a TXT book into an isolated on-disk database, opens the fixed-page
reader, taps a word, advances a page to trigger automatic Known confirmation,
opens the Deck, adds a word to Learning, completes a review, and opens Settings.

Run it with:

```powershell
flutter test integration_test/app_test.dart -d windows
```

Screenshots are written by the test to the system temporary directory. The
copies here are for documentation.
