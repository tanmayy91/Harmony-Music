import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../Auth/auth_screen.dart';
import '../Settings/settings_screen_controller.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key, this.isBottomNavActive = false});
  final bool isBottomNavActive;

  @override
  Widget build(BuildContext context) {
    final settingsController = Get.find<SettingsScreenController>();
    final topPadding = context.isLandscape ? 50.0 : 90.0;

    return Padding(
      padding: isBottomNavActive
          ? EdgeInsets.only(left: 20, top: topPadding, right: 15)
          : EdgeInsets.only(top: topPadding, left: 5, right: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "profile".tr,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.only(bottom: 200),
              children: [
                // ── Profile card ──────────────────────────────────────────
                Obx(() {
                  final signed = settingsController.isSignedIn.value;
                  final photoUrl = settingsController.userPhotoUrl.value;
                  return _ProfileCard(
                    signed: signed,
                    photoUrl: photoUrl,
                    displayName: settingsController.userDisplayName.value,
                    email: settingsController.userEmail.value,
                    onSignIn: () => Get.to(() => const AuthScreen()),
                    onSignOut: settingsController.signOut,
                    onEditName: () =>
                        _showSetNameDialog(context, settingsController),
                  );
                }),
                const SizedBox(height: 20),

                // ── Listen Together ───────────────────────────────────────
                _SocialFeatureCard(
                  icon: Icons.headphones_rounded,
                  title: "listenTogether".tr,
                  subtitle: "listenTogetherDes".tr,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6C3DE2), Color(0xFF9D6BFF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  onTap: () =>
                      _showComingSoonSheet(context, "listenTogether".tr),
                  actionLabel: "startSession".tr,
                ),
                const SizedBox(height: 14),

                // ── Blend ──────────────────────────────────────────────────
                _SocialFeatureCard(
                  icon: Icons.shuffle_rounded,
                  title: "blend".tr,
                  subtitle: "blendDes".tr,
                  gradient: const LinearGradient(
                    colors: [Color(0xFFE2633D), Color(0xFFFF9D6B)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  onTap: () => _showComingSoonSheet(context, "blend".tr),
                  actionLabel: "createBlend".tr,
                ),
                const SizedBox(height: 14),

                // ── Follow ─────────────────────────────────────────────────
                _SocialFeatureCard(
                  icon: Icons.people_rounded,
                  title: "follow".tr,
                  subtitle: "followDes".tr,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2D9C5E), Color(0xFF6BFFA0)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  onTap: () => _showComingSoonSheet(context, "follow".tr),
                  actionLabel: "findFriends".tr,
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showSetNameDialog(
      BuildContext context, SettingsScreenController ctrl) {
    final textCtrl =
        TextEditingController(text: ctrl.userDisplayName.value);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("setDisplayName".tr),
        content: TextField(
          controller: textCtrl,
          decoration: InputDecoration(hintText: "enterYourName".tr),
          textCapitalization: TextCapitalization.words,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text("cancel".tr),
          ),
          FilledButton(
            onPressed: () {
              final name = textCtrl.text.trim();
              if (name.isNotEmpty) {
                ctrl.updateDisplayName(name);
              }
              Navigator.of(ctx).pop();
            },
            child: Text("save".tr),
          ),
        ],
      ),
    );
  }

  void _showComingSoonSheet(BuildContext context, String featureName) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color:
                    Theme.of(ctx).colorScheme.onSurface.withOpacity(0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Icon(Icons.rocket_launch_rounded,
                size: 48, color: Theme.of(ctx).colorScheme.primary),
            const SizedBox(height: 16),
            Text(
              featureName,
              style: Theme.of(ctx)
                  .textTheme
                  .titleLarge!
                  .copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              "comingSoon".tr,
              style: Theme.of(ctx).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            FilledButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text("ok".tr),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Profile card widget
// ─────────────────────────────────────────────────────────────────────────────

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({
    required this.signed,
    required this.photoUrl,
    required this.displayName,
    required this.email,
    required this.onSignIn,
    required this.onSignOut,
    required this.onEditName,
  });

  final bool signed;
  final String? photoUrl;
  final String displayName;
  final String email;
  final VoidCallback onSignIn;
  final VoidCallback onSignOut;
  final VoidCallback onEditName;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withOpacity(0.55),
        borderRadius: BorderRadius.circular(20),
      ),
      child: signed ? _SignedInView(
        photoUrl: photoUrl,
        displayName: displayName,
        email: email,
        onEditName: onEditName,
        onSignOut: onSignOut,
      ) : _SignedOutView(onSignIn: onSignIn),
    );
  }
}

class _SignedInView extends StatelessWidget {
  const _SignedInView({
    required this.photoUrl,
    required this.displayName,
    required this.email,
    required this.onEditName,
    required this.onSignOut,
  });

  final String? photoUrl;
  final String displayName;
  final String email;
  final VoidCallback onEditName;
  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        Row(
          children: [
            // Avatar
            CircleAvatar(
              radius: 36,
              backgroundColor: colorScheme.primary,
              backgroundImage:
                  (photoUrl != null && photoUrl!.isNotEmpty)
                      ? CachedNetworkImageProvider(photoUrl!)
                      : null,
              child: (photoUrl == null || photoUrl!.isEmpty)
                  ? Text(
                      displayName.isNotEmpty
                          ? displayName[0].toUpperCase()
                          : '?',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onPrimary,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayName.isNotEmpty ? displayName : email,
                    style: Theme.of(context).textTheme.titleMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (displayName.isNotEmpty)
                    Text(
                      email,
                      style: Theme.of(context).textTheme.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                icon: const Icon(Icons.edit_outlined, size: 18),
                label: Text("editProfile".tr),
                onPressed: onEditName,
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: OutlinedButton.icon(
                icon: const Icon(Icons.logout_rounded, size: 18),
                label: Text("signOut".tr),
                onPressed: onSignOut,
                style: OutlinedButton.styleFrom(
                  foregroundColor: colorScheme.error,
                  side: BorderSide(
                      color: colorScheme.error.withOpacity(0.5)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SignedOutView extends StatelessWidget {
  const _SignedOutView({required this.onSignIn});
  final VoidCallback onSignIn;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundColor: colorScheme.primaryContainer,
          child: Icon(
            Icons.person_outline_rounded,
            size: 44,
            color: colorScheme.primary,
          ),
        ),
        const SizedBox(height: 14),
        Text(
          "signInToUnlock".tr,
          style: Theme.of(context)
              .textTheme
              .titleMedium!
              .copyWith(fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          "signInBenefits".tr,
          style: Theme.of(context).textTheme.bodySmall!.copyWith(
                color: colorScheme.onSurface.withOpacity(0.6),
              ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        FilledButton.icon(
          icon: const Icon(Icons.login_rounded, size: 20),
          label: Text("signInOrCreateAccount".tr),
          onPressed: onSignIn,
          style: FilledButton.styleFrom(
            minimumSize: const Size(double.infinity, 48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Social feature card widget
// ─────────────────────────────────────────────────────────────────────────────

class _SocialFeatureCard extends StatelessWidget {
  const _SocialFeatureCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.gradient,
    required this.onTap,
    required this.actionLabel,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final LinearGradient gradient;
  final VoidCallback onTap;
  final String actionLabel;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, size: 28, color: Colors.white),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        )),
                    const SizedBox(height: 4),
                    Text(subtitle,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.85),
                          fontSize: 12,
                        ),
                        maxLines: 2),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.22),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(actionLabel,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 12)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
