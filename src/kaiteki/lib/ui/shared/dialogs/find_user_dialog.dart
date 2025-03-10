import 'package:flutter/material.dart';
import 'package:kaiteki/di.dart';
import 'package:kaiteki/fediverse/interfaces/search_support.dart';
import 'package:kaiteki/fediverse/model/user/user.dart';
import 'package:kaiteki/ui/shared/posts/user_list_dialog.dart';
import 'package:kaiteki/ui/shared/search_bar.dart';

class FindUserDialog extends ConsumerStatefulWidget {
  const FindUserDialog({super.key});

  @override
  ConsumerState<FindUserDialog> createState() => _FindUserDialogState();
}

class _FindUserDialogState extends ConsumerState<FindUserDialog> {
  late TextEditingController _textController;

  Future<List<User>>? _future;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      scrollable: true,
      title: const Text("Find user"),
      content: FutureBuilder<List<User>>(
        future: _future,
        builder: (context, snapshot) {
          final searchBar = SearchBar(
            autofocus: true,
            controller: _textController,
            hintText: "Search for user",
            onSubmitted: (query) async {
              final adapter = ref.watch(adapterProvider);
              setState(() {
                _future = (adapter as SearchSupport)
                    .search(query)
                    .then((value) => value.users);
              });
            },
          );

          final results = snapshot.data ?? const [];
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                children: [
                  searchBar,
                  if (snapshot.connectionState == ConnectionState.waiting)
                    const Positioned.fill(
                      child: ClipRRect(
                        borderRadius: BorderRadius.vertical(
                          bottom: Radius.circular(8),
                        ),
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: LinearProgressIndicator(),
                        ),
                      ),
                    ),
                ],
              ),
              if (results.isNotEmpty) const SizedBox(height: 8),
              for (final user in results)
                UserListTile(
                  user: user,
                  onPressed: () {
                    Navigator.of(context).pop(user);
                  },
                ),
            ],
          );
        },
      ),
    );
  }
}
