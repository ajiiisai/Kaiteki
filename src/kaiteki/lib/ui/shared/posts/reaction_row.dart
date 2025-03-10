import 'package:flutter/material.dart';
import 'package:kaiteki/di.dart';
import 'package:kaiteki/fediverse/model/reaction.dart';
import 'package:kaiteki/preferences/app_experiment.dart';
import 'package:kaiteki/ui/shared/posts/reaction_button.dart';

class ReactionRow extends ConsumerWidget {
  final List<Reaction> reactions;
  final Function(Reaction reaction) onPressed;

  const ReactionRow(
    this.reactions,
    this.onPressed, {
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dense = ref
        .watch(preferencesProvider.select((p) => p.enabledExperiments))
        .contains(AppExperiment.denseReactions);
    final spacing = dense ? 2.0 : 6.0;
    return Wrap(
      spacing: spacing,
      runSpacing: spacing,
      children: [
        for (var reaction in reactions)
          ReactionButton(
            reaction: reaction,
            onPressed: () => onPressed(reaction),
          ),
      ],
    );
  }
}
