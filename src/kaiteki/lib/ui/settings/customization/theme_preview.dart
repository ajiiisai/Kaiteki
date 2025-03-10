import 'package:flutter/material.dart';

class ThemePreview extends StatelessWidget {
  final bool selected;
  final VoidCallback onTap;
  final Icon? icon;
  final String name;

  const ThemePreview({
    super.key,
    this.selected = false,
    required this.onTap,
    this.icon,
    required this.name,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final borderRadius = BorderRadius.circular(8.0);

    final selectedDecoration = BoxDecoration(
      border: Border.all(
        color: colorScheme.primary,
        width: 4.0,
      ),
      borderRadius: borderRadius,
    );

    return Tooltip(
      message: name,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: borderRadius),
        clipBehavior: Clip.antiAlias,
        elevation: 4,
        color: colorScheme.surface,
        child: InkWell(
          onTap: onTap,
          child: DecoratedBox(
            decoration: selected ? selectedDecoration : const BoxDecoration(),
            position: DecorationPosition.foreground,
            child: SizedBox(
              width: 8 * 12,
              height: 8 * 12,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: _buildContent(context),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    final theme = Theme.of(context);
    if (icon == null) {
      return Wrap(
        crossAxisAlignment: WrapCrossAlignment.end,
        spacing: 4.0,
        children: [
          _ColorCircle(color: theme.colorScheme.primary),
          _ColorCircle(color: theme.colorScheme.secondary),
          if (theme.useMaterial3)
            _ColorCircle(color: theme.colorScheme.tertiary),
        ],
      );
    } else {
      return Center(
        child: IconTheme(
          data: IconThemeData(color: theme.colorScheme.onSurface, size: 32),
          child: icon!,
        ),
      );
    }
  }
}

class _ColorCircle extends StatelessWidget {
  const _ColorCircle({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(24),
      ),
      child: const SizedBox.square(dimension: 16),
    );
  }
}
