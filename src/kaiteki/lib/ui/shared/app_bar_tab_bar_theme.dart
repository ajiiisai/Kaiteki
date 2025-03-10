import 'package:flutter/material.dart';
import 'package:kaiteki_material/kaiteki_material.dart';

/// A widget that overrides the [TabBarTheme] for use on backgrounds with surface
/// color.
class AppBarTabBarTheme extends StatelessWidget {
  final Widget child;

  const AppBarTabBarTheme({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (theme.useMaterial3) return child;

    final foregroundColor = theme.colorScheme.brightness == Brightness.dark
        ? theme.colorScheme.onSurface
        : theme.colorScheme.onPrimary;

    return Theme(
      data: theme.copyWith(
        tabBarTheme: TabBarTheme(
          indicator: RoundedUnderlineTabIndicator(
            borderSide: BorderSide(
              width: 3,
              color: foregroundColor,
            ),
          ),
          labelColor: foregroundColor,
          unselectedLabelColor: foregroundColor.withOpacity(.7),
        ),
      ),
      child: child,
    );
  }
}
