import 'package:breakpoint/breakpoint.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:html/dom.dart';
import 'package:kaiteki/di.dart';
import 'package:kaiteki/fediverse/adapter.dart';
import 'package:kaiteki/fediverse/backends/mastodon/adapter.dart';
import 'package:kaiteki/fediverse/backends/mastodon/shared_adapter.dart';
import 'package:kaiteki/fediverse/backends/misskey/adapter.dart';
import 'package:kaiteki/fediverse/model/chat_message.dart';
import 'package:kaiteki/fediverse/model/post/post.dart';
import 'package:kaiteki/fediverse/model/user/reference.dart';
import 'package:kaiteki/fediverse/model/user/user.dart';
import 'package:kaiteki/model/auth/account_key.dart';
import 'package:kaiteki/utils/helpers.dart';
import 'package:kaiteki/utils/text/parsers.dart';
import 'package:kaiteki/utils/text/text_renderer.dart';
import 'package:tuple/tuple.dart';

export 'package:kaiteki/utils/extensions/build_context.dart';
export 'package:kaiteki/utils/extensions/duration.dart';
export 'package:kaiteki/utils/extensions/enum.dart';
export 'package:kaiteki/utils/extensions/iterable.dart';
export 'package:kaiteki/utils/extensions/m3.dart';
export 'package:kaiteki/utils/extensions/string.dart';

extension ObjectExtensions<T> on T? {
  S? nullTransform<S>(S Function(T object) function) {
    final value = this;
    if (value == null) return null;
    return function.call(value);
  }
}

extension BrightnessExtensions on Brightness {
  Brightness get inverted {
    switch (this) {
      case Brightness.dark:
        return Brightness.light;
      case Brightness.light:
        return Brightness.dark;
    }
  }

  SystemUiOverlayStyle get systemUiOverlayStyle {
    switch (this) {
      case Brightness.dark:
        return SystemUiOverlayStyle.dark;
      case Brightness.light:
        return SystemUiOverlayStyle.light;
    }
  }

  Color getColor({
    Color dark = const Color(0xFF000000),
    Color light = const Color(0xFFFFFFFF),
  }) {
    switch (this) {
      case Brightness.dark:
        return dark;
      case Brightness.light:
        return light;
    }
  }
}

extension TextDirectionExtensions on TextDirection {
  TextDirection get inverted {
    switch (this) {
      case TextDirection.ltr:
        return TextDirection.rtl;
      case TextDirection.rtl:
        return TextDirection.ltr;
    }
  }
}

extension AsyncSnapshotExtensions on AsyncSnapshot {
  @Deprecated("Use appropriate AsyncSnapshot properties instead")
  AsyncSnapshotState get state {
    if (hasError) {
      return AsyncSnapshotState.errored;
    } else if (!hasData) {
      return AsyncSnapshotState.loading;
    } else {
      return AsyncSnapshotState.done;
    }
  }
}

Set<TextParser> _getTextParsers(WidgetRef ref) {
  const socialTextParser = SocialTextParser();
  final adapter = ref.watch(adapterProvider);
  if (adapter is MisskeyAdapter) {
    return const {MfmTextParser(), socialTextParser};
  } else if (adapter is SharedMastodonAdapter) {
    return const {MastodonHtmlTextParser(), socialTextParser};
  } else {
    return const {socialTextParser};
  }
}

enum AsyncSnapshotState { errored, loading, done }

extension UserExtensions on User {
  InlineSpan renderDisplayName(BuildContext context, WidgetRef ref) {
    return renderText(context, ref, displayName!);
  }

  InlineSpan renderDescription(BuildContext context, WidgetRef ref) {
    return renderText(context, ref, description!);
  }

  InlineSpan renderText(BuildContext context, WidgetRef ref, String text) {
    final parsers = _getTextParsers(ref);

    return render(
      parsers: parsers,
      context,
      text,
      textContext: TextContext(
        users: [],
        emojis: emojis?.toList(growable: false),
      ),
      onUserClick: (reference) => resolveAndOpenUser(reference, context, ref),
    );
  }
}

extension PostExtensions on Post {
  InlineSpan renderContent(
    BuildContext context,
    WidgetRef ref, {
    bool hideReplyee = false,
  }) {
    final parsers = _getTextParsers(ref);
    final replyee = replyToUser?.data;

    return render(
      parsers: parsers,
      context,
      content!,
      textContext: TextContext(
        emojis: emojis?.toList(growable: false),
        users: mentionedUsers,
        excludedUsers: [
          if (hideReplyee && replyee != null)
            UserReference.handle(replyee.username, replyee.host)
        ],
      ),
      onUserClick: (reference) => resolveAndOpenUser(reference, context, ref),
    );
  }

  Post getRoot() => _getRoot(this);

  Post _getRoot(Post post) {
    final repeatChild = post.repeatOf;
    return repeatChild == null ? post : _getRoot(repeatChild);
  }
}

extension ChatMessageExtensions on ChatMessage {
  InlineSpan renderContent(BuildContext context, WidgetRef ref) {
    final parsers = _getTextParsers(ref);

    return render(
      parsers: parsers,
      context,
      content!,
      textContext: TextContext(
        emojis: emojis.toList(growable: false),
      ),
      onUserClick: (reference) => resolveAndOpenUser(reference, context, ref),
    );
  }
}

extension VectorExtensions<T> on Iterable<Iterable<T>> {
  List<T> concat() {
    final list = <T>[];
    for (final childList in this) {
      list.addAll(childList);
    }
    return list;
  }
}

extension HtmlNodeExtensions on Node {
  bool hasClass(String className) {
    return attributes["class"]?.split(" ").contains(className) == true;
  }
}

extension UserReferenceExtensions on UserReference {
  Future<User?> resolve(BackendAdapter adapter) async {
    if (id != null) {
      return adapter.getUserById(id!);
    }

    // if (reference.username != null) {
    //   return await manager.adapter.getUser(reference.username!, reference.host);
    // }

    return null;
  }
}

extension WidgetRefExtensions on WidgetRef {
  String getCurrentAccountHandle() {
    final accountKey = read(accountProvider)!.key;
    return "@${accountKey.username}@${accountKey.host}";
  }

  Map<String, String> get accountRouterParams {
    final accountKey = read(accountProvider)!.key;
    return accountKey.routerParams;
  }
}

extension ProviderContainerExtensions on ProviderContainer {
  Map<String, String> get accountRouterParams {
    final accountKey = read(accountProvider)!.key;
    return accountKey.routerParams;
  }
}

extension AccountKeyExtensions on AccountKey {
  Map<String, String> get routerParams {
    return {"accountUsername": username, "accountHost": host};
  }
}

extension BreakpointExtensions on Breakpoint {
  double? get margin {
    if (window == WindowSize.xsmall) return 16;
    if (window == WindowSize.small && columns == 8) return 32;
    if (window == WindowSize.small && columns == 12) return null;
    if (window == WindowSize.medium) return 200;
    return null;
  }

  double? get body {
    if (window == WindowSize.xsmall) return null;
    if (window == WindowSize.small && columns == 8) return null;
    if (window == WindowSize.small && columns == 12) return 840;
    if (window == WindowSize.medium) return null;
    return 1040;
  }
}

extension QueryExtension on Map<String, String> {
  String toQueryString() {
    if (isEmpty) return "";

    final pairs = <String>[];
    for (final kv in entries) {
      final key = Uri.encodeQueryComponent(kv.key);
      final value = Uri.encodeQueryComponent(kv.value);
      pairs.add("$key=$value");
    }
    return "?${pairs.join("&")}";
  }
}

extension UriExtensions on Uri {
  Tuple2<String, String> get fediverseHandle {
    var username = pathSegments.last;
    if (username[0] == '@') {
      username = username.substring(1);
    }
    return Tuple2(host, username);
  }
}

extension ListExtensions<T> on List<T> {
  List<T> joinNonString(T separator) {
    if (length <= 1) return this;

    return List<T>.generate(
      length * 2 - 1,
      (i) => i % 2 == 0 ? this[i ~/ 2] : separator,
    );
  }
}

extension NullableObjectExtensions on Object? {}

extension FunctionExtensions<T> on T Function(Map<String, dynamic>) {
  T Function(Object?) get generic {
    return (obj) => this(obj as Map<String, dynamic>);
  }

  List<T>? Function(Object?) get genericList {
    return (obj) {
      if (obj == null) return null;
      final list = obj as List<dynamic>;
      final castedList = list.cast<Map<String, dynamic>>();
      return castedList.map(this).toList();
    };
  }
}
