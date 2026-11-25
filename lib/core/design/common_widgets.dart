import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;

import '../../app/providers.dart';
import '../../core/database/app_database.dart';
import '../../data/repository/library_repository.dart';
import '../../data/repository/vocabulary_repository.dart';
import 'app_theme.dart';

class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.action,
  });

  final String title;
  final String? subtitle;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = CafePalette.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.textTheme.titleLarge),
                if (subtitle != null) ...[
                  const SizedBox(height: 3),
                  Text(
                    subtitle!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: palette.inkMuted,
                    ),
                  ),
                ],
              ],
            ),
          ),
          ?action,
        ],
      ),
    );
  }
}

class BookCover extends StatelessWidget {
  const BookCover({
    super.key,
    required this.book,
    this.width = 96,
    this.height = 144,
    this.borderRadius = 10,
    this.border,
  });

  final Book book;
  final double width;
  final double height;
  final double borderRadius;
  final BoxBorder? border;

  @override
  Widget build(BuildContext context) {
    return CoverArt(
      title: book.title,
      coverPath: book.coverPath,
      width: width,
      height: height,
      borderRadius: borderRadius,
      border: border,
    );
  }
}

/// Cover artwork keyed by a title and a stored cover path rather than a whole
/// [Book]. Group cards use it for their four thumbnails; [BookCover] is the
/// book-shaped wrapper.
///
/// A null [width] or [height] lets the artwork fill its parent.
class CoverArt extends ConsumerWidget {
  const CoverArt({
    super.key,
    required this.title,
    required this.coverPath,
    this.width,
    this.height,
    this.borderRadius = 10,
    this.border,
  });

  final String title;
  final String? coverPath;
  final double? width;
  final double? height;
  final double borderRadius;
  final BoxBorder? border;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = CafePalette.of(context);
    final storage = ref.watch(appServicesProvider).storage;
    final raw = coverPath;
    File? file;
    if (raw != null && raw.isNotEmpty) {
      final resolved = p.isAbsolute(raw) ? raw : storage.resolveStoredPath(raw);
      if (File(resolved).existsSync()) file = File(resolved);
    }
    final placeholder = Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: palette.surfaceMuted,
        borderRadius: BorderRadius.circular(borderRadius),
        border: border ?? Border.all(color: palette.line),
      ),
      alignment: Alignment.center,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final basis = width ?? constraints.maxWidth;
          return Text(
            title.isEmpty ? '?' : title.characters.first.toUpperCase(),
            style: TextStyle(
              fontFamily: 'Literata',
              fontSize: basis.isFinite ? basis * 0.3 : 20,
              fontWeight: FontWeight.w600,
              color: palette.inkMuted.withValues(alpha: 0.65),
            ),
          );
        },
      ),
    );
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: SizedBox(
        width: width,
        height: height,
        child: file == null
            ? placeholder
            : Image.file(
                file,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => placeholder,
              ),
      ),
    );
  }
}

class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required this.state, this.compact = false});

  final VocabularyState state;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final palette = CafePalette.of(context);
    final color = statusColor(palette, state);
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 7 : 10,
        vertical: compact ? 3 : 5,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.45)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(statusIcon(state), size: compact ? 11 : 13, color: color),
          const SizedBox(width: 5),
          Text(
            state.label,
            style: TextStyle(
              color: color,
              fontSize: compact ? 10.5 : 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}

Color statusColor(CafeColors palette, VocabularyState state) => switch (state) {
  VocabularyState.learning => palette.ink,
  VocabularyState.known => palette.ink,
  VocabularyState.newWord => palette.inkMuted,
};

IconData statusIcon(VocabularyState state) => switch (state) {
  VocabularyState.newWord => Icons.circle_outlined,
  VocabularyState.learning => Icons.auto_stories_outlined,
  VocabularyState.known => Icons.check_circle_outline,
};

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.message,
    this.action,
  });

  final IconData icon;
  final String title;

  /// Supporting sentence. Compact empty states (the deck) omit it.
  final String? message;

  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final palette = CafePalette.of(context);
    final theme = Theme.of(context);
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: palette.surfaceMuted,
                  shape: BoxShape.circle,
                  border: Border.all(color: palette.line),
                ),
                child: Icon(icon, color: palette.inkMuted, size: 28),
              ),
              const SizedBox(height: 18),
              Text(
                title,
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineSmall,
              ),
              if (message != null && message!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  message!,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: palette.inkMuted,
                  ),
                ),
              ],
              if (action != null) ...[const SizedBox(height: 20), action!],
            ],
          ),
        ),
      ),
    );
  }
}

class StatTile extends StatelessWidget {
  const StatTile({
    super.key,
    required this.label,
    required this.value,
    required this.state,
    this.onTap,
    this.caption,
  });

  final String label;
  final int value;
  final VocabularyState state;
  final VoidCallback? onTap;
  final String? caption;

  @override
  Widget build(BuildContext context) {
    final palette = CafePalette.of(context);
    final theme = Theme.of(context);
    final color = statusColor(palette, state);
    return Material(
      color: palette.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: palette.line),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(statusIcon(state), color: color, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    label.toUpperCase(),
                    style: theme.textTheme.labelSmall?.copyWith(
                      letterSpacing: 1.2,
                      fontWeight: FontWeight.w700,
                      color: color,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                formatCount(value),
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontFamily: 'Literata',
                  fontWeight: FontWeight.w700,
                  color: palette.ink,
                ),
              ),
              if (caption != null) ...[
                const SizedBox(height: 4),
                Text(
                  caption!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: palette.inkMuted,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class StatusBar extends StatelessWidget {
  const StatusBar({super.key, required this.stats, this.height = 6});

  final ChapterVocabularyStats stats;
  final double height;

  @override
  Widget build(BuildContext context) {
    final palette = CafePalette.of(context);
    if (stats.total == 0) {
      return Container(
        height: height,
        decoration: BoxDecoration(
          color: palette.surfaceMuted,
          borderRadius: BorderRadius.circular(999),
        ),
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: SizedBox(
        height: height,
        child: Row(
          children: [
            if (stats.known > 0)
              Expanded(
                flex: stats.known,
                child: ColoredBox(color: palette.ink),
              ),
            if (stats.learning > 0)
              Expanded(
                flex: stats.learning,
                child: ColoredBox(color: palette.ink),
              ),
          ],
        ),
      ),
    );
  }
}

class StatusLegend extends StatelessWidget {
  const StatusLegend({super.key, this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final palette = CafePalette.of(context);
    return Wrap(
      spacing: 12,
      runSpacing: 6,
      children: [
        _LegendDot(color: palette.ink, label: 'Known'),
        _LegendDot(color: palette.ink, label: 'Learning'),
      ],
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: CafePalette.of(context).inkMuted,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

String formatCount(int value) {
  if (value >= 1000000) {
    return '${(value / 1000000).toStringAsFixed(1)}m';
  }
  if (value >= 10000) {
    return '${(value / 1000).toStringAsFixed(1)}k';
  }
  return '$value';
}

String formatRelativeTime(DateTime? time) {
  if (time == null) return 'Not read yet';
  final difference = DateTime.now().difference(time);
  if (difference.inMinutes < 1) return 'Just now';
  if (difference.inHours < 1) return '${difference.inMinutes}m ago';
  if (difference.inDays < 1) return '${difference.inHours}h ago';
  if (difference.inDays < 7) return '${difference.inDays}d ago';
  if (difference.inDays < 30) return '${difference.inDays ~/ 7}w ago';
  return '${time.year}-${time.month.toString().padLeft(2, '0')}-'
      '${time.day.toString().padLeft(2, '0')}';
}

Future<bool> confirmAction(
  BuildContext context, {
  required String title,
  required String message,
  String confirmLabel = 'Continue',
  bool destructive = false,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          style: destructive
              ? FilledButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.error,
                )
              : null,
          onPressed: () => Navigator.pop(context, true),
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
  return result ?? false;
}
