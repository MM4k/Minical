import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/settings_controller.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/app_themes.dart';
import '../calendar/calendar_view_mode.dart';
import '../widgets/color_picker_dialog.dart';
import '../widgets/minical_logo.dart';
import 'categories_screen.dart';

/// Fixed panel on the right: the logo and calendar controls (current period,
/// month/week switch, "today") at the top, then a minimal list of app options.
class SidePanel extends StatelessWidget {
  const SidePanel({
    super.key,
    required this.periodLabel,
    required this.mode,
    required this.onModeChanged,
    required this.onToday,
    this.width = 288,
  });

  final String periodLabel;
  final CalendarViewMode mode;
  final ValueChanged<CalendarViewMode> onModeChanged;
  final VoidCallback onToday;
  final double width;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final controller = context.watch<SettingsController>();
    final settings = controller.settings;
    final theme = Theme.of(context);

    return Container(
      width: width,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(left: BorderSide(color: theme.dividerColor)),
      ),
      child: SafeArea(
        left: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
          children: [
            const MinicalLogo(size: 30),
            const SizedBox(height: 24),

            // ---- Calendar controls ----
            Row(
              children: [
                Expanded(
                  child: Text(
                    periodLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
                TextButton(
                  onPressed: onToday,
                  style: TextButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                  child: Text(l.today),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _MinimalToggle<CalendarViewMode>(
              options: const [CalendarViewMode.month, CalendarViewMode.week],
              labels: [l.viewMonth, l.viewWeek],
              selected: mode,
              onChanged: onModeChanged,
            ),

            const _SectionGap(),

            // ---- Options ----
            _Label(l.language),
            _MinimalToggle<String>(
              options: const ['en', 'pt'],
              labels: [l.english, l.portuguese],
              selected: settings.localeCode,
              onChanged: controller.setLocale,
            ),

            const _SectionGap(),
            _Label(l.themeMode),
            _MinimalToggle<String>(
              options: const ['system', 'light', 'dark'],
              labels: [l.themeSystem, l.themeLight, l.themeDark],
              selected: settings.themeModeName,
              onChanged: controller.setThemeMode,
            ),

            const _SectionGap(),
            _Label(l.themeColor),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                for (final id in AppThemes.presetOrder)
                  _ColorSwatch(
                    color: AppThemes.presets[id]!,
                    selected: settings.themeId == id,
                    onTap: () => controller.setThemeId(id),
                  ),
                _ColorSwatch(
                  color: Color(settings.customColor),
                  selected: settings.themeId == 'custom',
                  isCustom: true,
                  onTap: () async {
                    final picked = await showColorPickerDialog(
                        context, Color(settings.customColor));
                    if (picked != null) {
                      controller.setCustomColor(picked.toARGB32());
                    }
                  },
                ),
              ],
            ),

            const _SectionGap(),
            _Label(l.timeFormat),
            _MinimalToggle<bool>(
              options: const [true, false],
              labels: [l.hour24, l.hour12],
              selected: settings.use24hTime,
              onChanged: controller.setUse24hTime,
            ),

            const _SectionGap(),
            InkWell(
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const CategoriesScreen()),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(l.categories,
                          style: theme.textTheme.bodyLarge),
                    ),
                    Icon(Icons.chevron_right,
                        color: theme.colorScheme.onSurfaceVariant),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Small muted section label.
class _Label extends StatelessWidget {
  const _Label(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        text,
        style: theme.textTheme.labelMedium
            ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
      ),
    );
  }
}

class _SectionGap extends StatelessWidget {
  const _SectionGap();
  @override
  Widget build(BuildContext context) => const SizedBox(height: 22);
}

/// A flat, borderless segmented toggle — lighter than [SegmentedButton].
class _MinimalToggle<T> extends StatelessWidget {
  const _MinimalToggle({
    required this.options,
    required this.labels,
    required this.selected,
    required this.onChanged,
  });

  final List<T> options;
  final List<String> labels;
  final T selected;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          for (var i = 0; i < options.length; i++)
            Expanded(
              child: _ToggleSegment(
                label: labels[i],
                selected: options[i] == selected,
                onTap: () => onChanged(options[i]),
              ),
            ),
        ],
      ),
    );
  }
}

class _ToggleSegment extends StatelessWidget {
  const _ToggleSegment({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 7),
        decoration: BoxDecoration(
          color: selected ? scheme.surface : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 13,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
            color: selected ? scheme.onSurface : scheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

class _ColorSwatch extends StatelessWidget {
  const _ColorSwatch({
    required this.color,
    required this.selected,
    required this.onTap,
    this.isCustom = false,
  });

  final Color color;
  final bool selected;
  final VoidCallback onTap;
  final bool isCustom;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: selected ? scheme.onSurface : Colors.transparent,
            width: 3,
          ),
        ),
        child: isCustom
            ? Icon(Icons.colorize, size: 16, color: _contrastOn(color))
            : (selected
                ? Icon(Icons.check, size: 18, color: _contrastOn(color))
                : null),
      ),
    );
  }

  static Color _contrastOn(Color background) =>
      background.computeLuminance() > 0.5 ? Colors.black : Colors.white;
}
