import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '/services/auth_service.dart';
import '/ui/screens/Settings/settings_screen_controller.dart';
import '/ui/widgets/snackbar.dart';

class AuthScreenController extends GetxController {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final displayNameController = TextEditingController();

  final isLoading = false.obs;
  final obscurePassword = true.obs;
  final obscureConfirmPassword = true.obs;

  // 0 = sign-in, 1 = create account
  final tabIndex = 0.obs;

  final loginFormKey = GlobalKey<FormState>();
  final registerFormKey = GlobalKey<FormState>();

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    displayNameController.dispose();
    super.onClose();
  }

  // ── Sign-in ───────────────────────────────────────────────────────────────

  Future<void> signIn() async {
    if (!loginFormKey.currentState!.validate()) return;
    isLoading.value = true;
    try {
      final auth = Get.find<AuthService>();
      await auth.signIn(
        email: emailController.text.trim(),
        password: passwordController.text,
      );
      _syncSettingsController();
      Get.back(); // close auth screen
      _showSnack("signedInAs".tr + " " + auth.displayName);
    } on AuthException catch (e) {
      _showSnack(e.message);
    } catch (e) {
      _showSnack("errorOccuredAlert".tr);
    } finally {
      isLoading.value = false;
    }
  }

  // ── Sign-up ───────────────────────────────────────────────────────────────

  Future<void> signUp() async {
    if (!registerFormKey.currentState!.validate()) return;
    isLoading.value = true;
    try {
      final auth = Get.find<AuthService>();
      final response = await auth.signUp(
        email: emailController.text.trim(),
        password: passwordController.text,
        displayName: displayNameController.text.trim(),
      );
      if (response.user != null) {
        _syncSettingsController();
        Get.back();
        _showSnack("accountCreated".tr);
      } else {
        // Email confirmation required — user must verify before session is set
        Get.back();
        _showSnack("confirmEmailSent".tr);
      }
    } on AuthException catch (e) {
      _showSnack(e.message);
    } catch (e) {
      _showSnack("errorOccuredAlert".tr);
    } finally {
      isLoading.value = false;
    }
  }

  // ── Forgot password ───────────────────────────────────────────────────────

  Future<void> sendPasswordReset() async {
    final email = emailController.text.trim();
    if (email.isEmpty || !GetUtils.isEmail(email)) {
      _showSnack("enterValidEmail".tr);
      return;
    }
    isLoading.value = true;
    try {
      await Get.find<AuthService>().sendPasswordResetEmail(email);
      _showSnack("passwordResetSent".tr);
    } on AuthException catch (e) {
      _showSnack(e.message);
    } catch (e) {
      _showSnack("errorOccuredAlert".tr);
    } finally {
      isLoading.value = false;
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  void _syncSettingsController() {
    try {
      final auth = Get.find<AuthService>();
      final ctrl = Get.find<SettingsScreenController>();
      ctrl.isSignedIn.value = auth.isSignedIn;
      ctrl.userDisplayName.value = auth.displayName;
      ctrl.userEmail.value = auth.email;
      ctrl.userPhotoUrl.value = auth.photoUrl;
    } catch (_) {}
  }

  void _showSnack(String message) {
    if (Get.context != null) {
      ScaffoldMessenger.of(Get.context!).showSnackBar(
        snackbar(Get.context!, message, size: SanckBarSize.MEDIUM),
      );
    }
  }

  // ── Validators ────────────────────────────────────────────────────────────

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) return "fieldRequired".tr;
    if (!GetUtils.isEmail(value.trim())) return "enterValidEmail".tr;
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) return "fieldRequired".tr;
    if (value.length < 6) return "passwordTooShort".tr;
    return null;
  }

  String? validateConfirmPassword(String? value) {
    if (value != passwordController.text) return "passwordsDoNotMatch".tr;
    return null;
  }

  String? validateDisplayName(String? value) {
    if (value == null || value.trim().isEmpty) return "fieldRequired".tr;
    return null;
  }
}
