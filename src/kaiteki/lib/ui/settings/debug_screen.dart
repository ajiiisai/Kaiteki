import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kaiteki/auth/login_functions.dart';
import 'package:kaiteki/di.dart';
import 'package:kaiteki/ui/onboarding/onboarding_screen.dart';
import 'package:kaiteki/utils/extensions.dart';
import 'package:kaiteki_material/kaiteki_material.dart';
import 'package:url_launcher/url_launcher.dart';

class DebugScreen extends ConsumerStatefulWidget {
  const DebugScreen({super.key});

  @override
  ConsumerState<DebugScreen> createState() => _DebugScreenState();
}

class _DebugScreenState extends ConsumerState<DebugScreen> {
  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    final developerMode =
        ref.watch(preferencesProvider.select((value) => value.developerMode));
    final m3 = Theme.of(context).useMaterial3;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsDebugMaintenance)),
      body: Column(
        children: [
          Padding(
            padding: m3 ? const EdgeInsets.all(16.0) : EdgeInsets.zero,
            child: MainSwitchListTile(
              title: const Text("Enable developer mode"),
              onChanged: (value) {
                ref.read(preferencesProvider).developerMode = value;
              },
              value: developerMode,
              contentPadding:
                  m3 ? const EdgeInsets.symmetric(vertical: 4.0) : null,
              shape: m3
                  ? RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    )
                  : null,
            ),
          ),
          ListTile(
            leading: const Icon(Icons.palette_rounded),
            title: const Text("Show theme"),
            onTap: () => context.push("/settings/debug/theme"),
            enabled: developerMode,
          ),
          ListTile(
            leading: const Icon(Icons.key_rounded),
            title: const Text("Run OAuth Server"),
            onTap: () async => runOAuthServer(
              (u, _) => launchUrl(u),
              await generateOAuthLandingPage(Theme.of(context).colorScheme),
            ),
            enabled: developerMode,
          ),
          ListTile(
            leading: const Icon(Icons.waving_hand_rounded),
            title: const Text("Open onboarding"),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const OnboardingScreen(),
              ),
            ),
            enabled: developerMode,
          ),
          ListTile(
            leading: const Icon(Icons.feedback_rounded),
            title: const Text("Open exception dialog"),
            onTap: () async {
              try {
                throw Exception("Test exception");
              } catch (e, s) {
                await context.showExceptionDialog(e, s);
              }
            },
            enabled: developerMode,
          ),
        ],
      ),
    );
  }
}
