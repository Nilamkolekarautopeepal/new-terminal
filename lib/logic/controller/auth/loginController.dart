import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginController extends GetxController {
  // 1. Controllers for TextFields
  final usernameController = TextEditingController(text: "abc@autopeepal.com");
  final passwordController = TextEditingController(text: "1234");

  final hidePassword = true.obs;
  final isLoading = false.obs;
  void togglePasswordVisibility() {
    hidePassword.value = !hidePassword.value;
  }
  @override
  void onClose() {
    usernameController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  void login() async {
    String user = "abc@autopeepal.com";
    String pass = "1234";

    if (user.isEmpty || pass.isEmpty) {
      Get.snackbar("Error", "Please enter credentials");
      return;
    }

    isLoading.value = true;
    print("Attempting login for: $user");
    
    await Future.delayed(const Duration(seconds: 2));
    isLoading.value = false;
  }
}