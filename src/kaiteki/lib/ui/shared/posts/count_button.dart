import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kaiteki/theming/kaiteki/text_theme.dart';

class CountButton extends StatelessWidget {
  final bool active;
  final bool disabled;

  final int? count;
  final Color? activeColor;
  final Color? color;

  final Widget icon;
  final Widget? activeIcon;

  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final FocusNode? focusNode;

  const CountButton({
    super.key,
    this.active = false,
    this.count = 0,
    this.color,
    this.activeColor,
    required this.icon,
    this.activeIcon,
    this.onTap,
    this.disabled = false,
    this.focusNode,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final callback = active ? (onTap ?? () {}) : (disabled ? null : onTap);
    final color = _getColor(context);
    final currentIcon = active ? (activeIcon ?? icon) : icon;
    final count = this.count;

    final hasNumber = count != null && count >= 1;
    final shortenedCount = NumberFormat.compact() //
        .format(count ?? 0)
        .toLowerCase();

    return Row(
      children: [
        GestureDetector(
          onLongPress: onLongPress,
          child: IconButton(
            icon: currentIcon,
            color: color,
            onPressed: callback,
            enableFeedback: !disabled,
            focusNode: focusNode,
            splashRadius: 18,
            padding: EdgeInsets.zero,
          ),
        ),
        if (hasNumber)
          Expanded(
            child: DefaultTextStyle.merge(
              style: Theme.of(context).ktkTextTheme!.countTextStyle.copyWith(
                    color: color,
                  ),
              child: Text(
                shortenedCount,
                maxLines: 1,
                overflow: TextOverflow.fade,
                softWrap: false,
              ),
            ),
          ),
      ],
    );

    // if (hasNumber) {
    //   return IconButton(
    //     icon: currentIcon,
    //     color: iconColor,
    //     onPressed: callback,
    //     enableFeedback: !disabled,
    //     focusNode: focusNode,
    //     splashRadius: 18,
    //   );
    // } else {
    //   return TextButton.icon(
    //     icon: currentIcon,
    //     onPressed: callback,
    //     style: ButtonStyle(
    //       foregroundColor: MaterialStateProperty.all<Color>(iconColor),
    //     ),
    //     label: Text(count.toString()),
    //     focusNode: focusNode,
    //   );
    // }
  }

  Color _getColor(BuildContext context) {
    if (disabled || onTap == null) return Theme.of(context).disabledColor;
    final inactiveColor = color ?? Theme.of(context).colorScheme.onBackground;
    if (active) return activeColor ?? inactiveColor;
    return inactiveColor;
  }
}
