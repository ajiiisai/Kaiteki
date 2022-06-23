import 'package:flutter/material.dart';
import 'package:kaiteki/fediverse/model/post.dart';
import 'package:kaiteki/ui/shared/posts/avatar_widget.dart';
import 'package:kaiteki/ui/shared/posts/post_widget.dart';
import 'package:kaiteki/ui/shared/posts/user_display_name_widget.dart';
import 'package:kaiteki/utils/extensions.dart';

class MetaBar extends StatelessWidget {
  const MetaBar({
    Key? key,
    required Post post,
    this.authorTextStyle,
    this.showAvatar = false,
  })  : _post = post,
        super(key: key);

  final Post _post;
  final TextStyle? authorTextStyle;
  final bool showAvatar;

  @override
  Widget build(BuildContext context) {
    final visibility = _post.visibility;
    final secondaryColor = Theme.of(context).disabledColor;
    final secondaryTextTheme = TextStyle(color: secondaryColor);

    return Padding(
      padding: kPostPadding.copyWith(top: 0),
      child: Row(
        children: [
          if (showAvatar)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: AvatarWidget(_post.author, size: 40),
            ),
          Expanded(child: UserDisplayNameWidget(_post.author)),
          Tooltip(
            message: _post.postedAt.toString(),
            child: Text(
              DateTime.now().difference(_post.postedAt).toStringHuman(
                    context: context,
                  ),
              style: secondaryTextTheme,
            ),
          ),
          if (visibility != null)
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Tooltip(
                message: visibility.toDisplayString(),
                child: Icon(
                  visibility.toIconData(),
                  size: 20,
                  color: secondaryColor,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
