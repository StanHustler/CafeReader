import 'package:flutter/material.dart';

import '../../core/design/app_theme.dart';
import '../../core/design/subpage.dart';

/// Shared frame for every settings sub-page.
///
/// Settings pages are ordinary secondary pages, so the layout lives in the
/// app-wide [SubpageScaffold]. Keeping this wrapper means settings pages read
/// consistently even if their internals change.
class SettingsScaffold extends StatelessWidget {
  const SettingsScaffold({super.key, required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SubpageScaffold(title: title, child: child);
  }
}

/// A labelled card container shared by every settings page.
class SettingsSection extends StatelessWidget {
  const SettingsSection({
    super.key,
    required this.title,
    required this.children,
    this.description,
    this.trailing,
  });

  final String title;
  final String? description;
  final Widget? trailing;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final palette = CafePalette.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 26),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  title.toUpperCase(),
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    letterSpacing: 1.1,
                    fontWeight: FontWeight.w700,
                    fontSize: 10,
                    color: palette.inkMuted,
                  ),
                ),
              ),
              ?trailing,
            ],
          ),
          if (description != null) ...[
            const SizedBox(height: 6),
            Text(
              description!,
              style: Theme.of(context).textTheme.bodySmall
                  ?.copyWith(color: palette.inkMuted, height: 1.45),
            ),
          ],
          const SizedBox(height: 10),
          Material(
            color: palette.surface,
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: BorderSide(color: palette.line),
            ),
            child: Column(
              children: [
                for (var i = 0; i < children.length; i++) ...[
                  if (i > 0) Divider(height: 1, color: palette.line),
                  children[i],
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// A soft, tinted square that anchors the leading icon of a settings row.
class SettingsIconBubble extends StatelessWidget {
  const SettingsIconBubble({
    super.key,
    required this.icon,
    this.color,
    this.size = 30,
  });

  final IconData icon;
  final Color? color;
  final double size;

  @override
  Widget build(BuildContext context) {
    final palette = CafePalette.of(context);
    final tint = color ?? palette.accent;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        // Every settings icon bubble uses the same theme token.
        color: palette.accentSoft,
        borderRadius: BorderRadius.circular(size * 0.32),
      ),
      alignment: Alignment.center,
      child: Icon(icon, size: size * 0.54, color: tint),
    );
  }
}

/// A tappable row that opens another settings page.
class SettingsNavTile extends StatelessWidget {
  const SettingsNavTile({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
    this.subtitle,
    this.trailing,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final palette = CafePalette.of(context);
    return InkWell(
      onTap: onTap,
      hoverColor: palette.surfaceMuted,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            SettingsIconBubble(icon: icon),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w500,
                      color: palette.ink,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11.5,
                        color: palette.inkMuted,
                        height: 1.3,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            trailing ??
                Icon(Icons.chevron_right, color: palette.inkMuted, size: 19),
          ],
        ),
      ),
    );
  }
}

class SettingsValueTile extends StatelessWidget {
  const SettingsValueTile({
    super.key,
    required this.title,
    required this.value,
    this.icon,
    this.subtitle,
    this.onTap,
    this.leading,
    this.trailing,
  });

  final String title;
  final String value;
  final IconData? icon;
  final String? subtitle;
  final VoidCallback? onTap;
  final Widget? leading;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final palette = CafePalette.of(context);
    final effectiveLeading =
        leading ?? (icon == null ? null : SettingsIconBubble(icon: icon!));
    return InkWell(
      onTap: onTap,
      hoverColor: palette.surfaceMuted,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        child: Row(
          children: [
            if (effectiveLeading != null) ...[
              effectiveLeading,
              const SizedBox(width: 13),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w500,
                      color: palette.ink,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 3),
                    Text(
                      subtitle!,
                      style: Theme.of(context).textTheme.bodySmall
                          ?.copyWith(color: palette.inkMuted),
                    ),
                  ],
                ],
              ),
            ),
            ?trailing,
            if (trailing == null && onTap != null)
              Icon(Icons.chevron_right, color: palette.inkMuted, size: 19),
            if (trailing == null && onTap == null && value.isNotEmpty) ...[
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: palette.surfaceMuted,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: 11.5,
                    color: palette.inkMuted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class SettingsSwitchRow extends StatelessWidget {
  const SettingsSwitchRow({
    super.key,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    this.icon,
  });

  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool>? onChanged;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final palette = CafePalette.of(context);
    return InkWell(
      onTap: onChanged == null ? null : () => onChanged!(!value),
      hoverColor: palette.surfaceMuted,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            if (icon != null) ...[
              SettingsIconBubble(icon: icon!),
              const SizedBox(width: 13),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w500,
                      color: palette.ink,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall
                        ?.copyWith(color: palette.inkMuted, height: 1.35),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Switch(value: value, onChanged: onChanged),
          ],
        ),
      ),
    );
  }
}

class SettingsSliderRow extends StatelessWidget {
  const SettingsSliderRow({
    super.key,
    required this.title,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.display,
    required this.onChanged,
    this.onChangeEnd,
    this.subtitle,
  });

  final String title;
  final String? subtitle;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final String display;
  final ValueChanged<double> onChanged;
  final ValueChanged<double>? onChangeEnd;

  @override
  Widget build(BuildContext context) {
    final palette = CafePalette.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w500,
                        color: palette.ink,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: TextStyle(
                          fontSize: 11.5,
                          color: palette.inkMuted,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                constraints: const BoxConstraints(minWidth: 44),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: palette.accentSoft,
                  borderRadius: BorderRadius.circular(6),
                ),
                alignment: Alignment.center,
                child: Text(
                  display,
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: palette.accent,
                  ),
                ),
              ),
            ],
          ),
          Slider(
            value: value.clamp(min, max),
            min: min,
            max: max,
            divisions: divisions,
            onChanged: onChanged,
            onChangeEnd: onChangeEnd,
          ),
        ],
      ),
    );
  }
}

/// A non-interactive explanatory row used inside section cards.
class SettingsInfoTile extends StatelessWidget {
  const SettingsInfoTile({
    super.key,
    required this.title,
    required this.body,
    this.icon,
  });

  final String title;
  final String body;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final palette = CafePalette.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            SettingsIconBubble(icon: icon!, color: palette.inkMuted, size: 26),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: palette.ink,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  body,
                  style: Theme.of(context).textTheme.bodySmall
                      ?.copyWith(color: palette.inkMuted, height: 1.45),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// A prominent callout card used at the top of a settings page.
class SettingsHero extends StatelessWidget {
  const SettingsHero({
    super.key,
    required this.title,
    required this.body,
    this.icon = Icons.info_outline,
  });

  final String title;
  final String body;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final palette = CafePalette.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: palette.line),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SettingsIconBubble(icon: icon, size: 36),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: palette.ink,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  body,
                  style: Theme.of(context).textTheme.bodySmall
                      ?.copyWith(color: palette.inkMuted, height: 1.55),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// A tappable action row for backup, import and other data operations.
class SettingsActionTile extends StatelessWidget {
  const SettingsActionTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.destructive = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final palette = CafePalette.of(context);
    final enabled = onTap != null;
    final emphasis = destructive ? palette.danger : palette.accent;
    return InkWell(
      onTap: onTap,
      hoverColor: palette.surfaceMuted,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        child: Row(
          children: [
            SettingsIconBubble(
              icon: icon,
              color: enabled ? emphasis : palette.line,
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w500,
                      color: !enabled
                          ? palette.inkMuted
                          : (destructive ? palette.danger : palette.ink),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall
                        ?.copyWith(color: palette.inkMuted, height: 1.4),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.chevron_right, color: palette.inkMuted, size: 19),
          ],
        ),
      ),
    );
  }
}
