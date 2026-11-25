import 'package:flutter/material.dart';

import '../../core/design/app_theme.dart';
import '../../data/repository/dictionary_repository.dart';

/// The icon used for a dictionary source.
///
/// The bundled WordNet source uses the supplied WordNet mark. Imported and
/// online sources fall back to a kind-specific glyph until a custom icon is
/// provided.
class DictionaryIcon extends StatelessWidget {
  const DictionaryIcon({super.key, required this.kind, this.size = 38});

  final DictionaryKind kind;
  final double size;

  @override
  Widget build(BuildContext context) {
    final palette = CafePalette.of(context);
    final builtin = kind == DictionaryKind.builtin;
    return Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(builtin ? size * 0.08 : 0),
      decoration: BoxDecoration(
        color: builtin ? Colors.white : palette.surfaceMuted,
        borderRadius: BorderRadius.circular(size * 0.28),
        border: Border.all(color: palette.line),
      ),
      alignment: Alignment.center,
      child: builtin
          ? Image.asset(
              'assets/dictionary/wordnet.png',
              fit: BoxFit.contain,
              filterQuality: FilterQuality.high,
            )
          : Icon(_iconFor(kind), size: size * 0.5, color: palette.inkMuted),
    );
  }

  static IconData _iconFor(DictionaryKind kind) => switch (kind) {
    DictionaryKind.builtin => Icons.auto_stories_outlined,
    DictionaryKind.local => Icons.menu_book_outlined,
    DictionaryKind.online => Icons.cloud_outlined,
  };
}
