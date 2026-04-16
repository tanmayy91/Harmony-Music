import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'auth_screen_controller.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.put(AuthScreenController());
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      // Back / skip button in the top-right corner
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              "skipForNow".tr,
              style: TextStyle(color: colorScheme.onSurface.withOpacity(0.6)),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: DefaultTabController(
          length: 2,
          child: Column(
            children: [
              // ── Header ───────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 8),
                    CircleAvatar(
                      radius: 36,
                      backgroundColor: colorScheme.primaryContainer,
                      child: Icon(
                        Icons.music_note_rounded,
                        size: 38,
                        color: colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "Nerox Music",
                      style: theme.textTheme.headlineSmall!.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "authSubtitle".tr,
                      style: theme.textTheme.bodyMedium!.copyWith(
                        color: colorScheme.onSurface.withOpacity(0.6),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),

              // ── Tab bar ───────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: TabBar(
                    onTap: (i) => ctrl.tabIndex.value = i,
                    dividerColor: Colors.transparent,
                    indicator: BoxDecoration(
                      color: colorScheme.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    labelColor: colorScheme.onPrimary,
                    unselectedLabelColor:
                        colorScheme.onSurface.withOpacity(0.65),
                    tabs: [
                      Tab(text: "signIn".tr),
                      Tab(text: "createAccount".tr),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // ── Tab views ─────────────────────────────────────────────────
              Expanded(
                child: TabBarView(
                  children: [
                    _SignInTab(ctrl: ctrl),
                    _RegisterTab(ctrl: ctrl),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sign-in tab
// ─────────────────────────────────────────────────────────────────────────────

class _SignInTab extends StatelessWidget {
  const _SignInTab({required this.ctrl});
  final AuthScreenController ctrl;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Form(
        key: ctrl.loginFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Email
            TextFormField(
              controller: ctrl.emailController,
              validator: ctrl.validateEmail,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              decoration: _inputDecoration(
                context,
                label: "email".tr,
                icon: Icons.email_outlined,
              ),
            ),
            const SizedBox(height: 14),

            // Password
            Obx(() => TextFormField(
                  controller: ctrl.passwordController,
                  validator: ctrl.validatePassword,
                  obscureText: ctrl.obscurePassword.value,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => ctrl.signIn(),
                  decoration: _inputDecoration(
                    context,
                    label: "password".tr,
                    icon: Icons.lock_outline_rounded,
                    suffix: IconButton(
                      icon: Icon(
                        ctrl.obscurePassword.value
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        size: 20,
                        color: colorScheme.onSurface.withOpacity(0.6),
                      ),
                      onPressed: () =>
                          ctrl.obscurePassword.value =
                              !ctrl.obscurePassword.value,
                    ),
                  ),
                )),

            // Forgot password
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: ctrl.sendPasswordReset,
                child: Text(
                  "forgotPassword".tr,
                  style: TextStyle(
                    fontSize: 13,
                    color: colorScheme.primary,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 8),

            // Sign-in button
            Obx(() => FilledButton(
                  onPressed: ctrl.isLoading.value ? null : ctrl.signIn,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: ctrl.isLoading.value
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : Text(
                          "signIn".tr,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                )),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Register tab
// ─────────────────────────────────────────────────────────────────────────────

class _RegisterTab extends StatelessWidget {
  const _RegisterTab({required this.ctrl});
  final AuthScreenController ctrl;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Form(
        key: ctrl.registerFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Display name
            TextFormField(
              controller: ctrl.displayNameController,
              validator: ctrl.validateDisplayName,
              keyboardType: TextInputType.name,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
              decoration: _inputDecoration(
                context,
                label: "displayName".tr,
                icon: Icons.person_outline_rounded,
              ),
            ),
            const SizedBox(height: 14),

            // Email
            TextFormField(
              controller: ctrl.emailController,
              validator: ctrl.validateEmail,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              decoration: _inputDecoration(
                context,
                label: "email".tr,
                icon: Icons.email_outlined,
              ),
            ),
            const SizedBox(height: 14),

            // Password
            Obx(() => TextFormField(
                  controller: ctrl.passwordController,
                  validator: ctrl.validatePassword,
                  obscureText: ctrl.obscurePassword.value,
                  textInputAction: TextInputAction.next,
                  decoration: _inputDecoration(
                    context,
                    label: "password".tr,
                    icon: Icons.lock_outline_rounded,
                    suffix: IconButton(
                      icon: Icon(
                        ctrl.obscurePassword.value
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        size: 20,
                        color: colorScheme.onSurface.withOpacity(0.6),
                      ),
                      onPressed: () =>
                          ctrl.obscurePassword.value =
                              !ctrl.obscurePassword.value,
                    ),
                  ),
                )),
            const SizedBox(height: 14),

            // Confirm password
            Obx(() => TextFormField(
                  controller: ctrl.confirmPasswordController,
                  validator: ctrl.validateConfirmPassword,
                  obscureText: ctrl.obscureConfirmPassword.value,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => ctrl.signUp(),
                  decoration: _inputDecoration(
                    context,
                    label: "confirmPassword".tr,
                    icon: Icons.lock_outline_rounded,
                    suffix: IconButton(
                      icon: Icon(
                        ctrl.obscureConfirmPassword.value
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        size: 20,
                        color: colorScheme.onSurface.withOpacity(0.6),
                      ),
                      onPressed: () =>
                          ctrl.obscureConfirmPassword.value =
                              !ctrl.obscureConfirmPassword.value,
                    ),
                  ),
                )),
            const SizedBox(height: 22),

            // Create account button
            Obx(() => FilledButton(
                  onPressed: ctrl.isLoading.value ? null : ctrl.signUp,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: ctrl.isLoading.value
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : Text(
                          "createAccount".tr,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                )),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared input decoration helper
// ─────────────────────────────────────────────────────────────────────────────

InputDecoration _inputDecoration(
  BuildContext context, {
  required String label,
  required IconData icon,
  Widget? suffix,
}) {
  final colorScheme = Theme.of(context).colorScheme;
  return InputDecoration(
    labelText: label,
    prefixIcon: Icon(icon, size: 20),
    suffixIcon: suffix,
    filled: true,
    fillColor: colorScheme.surfaceContainerHighest.withOpacity(0.4),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(
        color: colorScheme.outline.withOpacity(0.25),
      ),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: colorScheme.error),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: colorScheme.error, width: 1.5),
    ),
  );
}
