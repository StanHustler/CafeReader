# SQLite amalgamation

- Version: SQLite 3.46.1
- Source: https://www.sqlite.org/2024/sqlite-amalgamation-3460100.zip
- Files used: `sqlite3.c`, `sqlite3.h`

SQLite is in the public domain:
https://www.sqlite.org/copyright.html

The project builds this amalgamation through Dart/Flutter native asset hooks
instead of downloading a precompiled DLL from GitHub at build time. See the
`hooks` section in `pubspec.yaml`.
