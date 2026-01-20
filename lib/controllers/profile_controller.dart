import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:food_bridge/controllers/auth_controller.dart';
import 'package:get/get.dart';

class ProfileController extends GetxController {
  final AuthController _authController = Get.find<AuthController>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Form Controllers
  late TextEditingController nameController;
  late TextEditingController phoneController;
  late TextEditingController bioController;

  var isLoading = false.obs;
  var isEditing = false.obs;

  @override
  void onInit() {
    super.onInit();
    final user = _authController.userModel.value;
    nameController = TextEditingController(text: user?.name ?? '');
    phoneController = TextEditingController(text: user?.phone ?? '');
    bioController = TextEditingController(text: user?.bio ?? '');
  }

  @override
  void onClose() {
    nameController.dispose();
    phoneController.dispose();
    bioController.dispose();
    super.onClose();
  }

  void toggleEdit() {
    isEditing.value = !isEditing.value;
  }

  Future<void> updateProfile() async {
    try {
      isLoading.value = true;
      String uid = _authController.userModel.value!.uid;

      Map<String, dynamic> updates = {
        'name': nameController.text.trim(),
        'phone': phoneController.text.trim(),
        'bio': bioController.text.trim(),
      };

      await _firestore.collection('users').doc(uid).update(updates);

      // Update local User Model
      _authController.userModel.value = _authController.userModel.value
          ?.copyWith(
            name: updates['name'],
            phone: updates['phone'],
            bio: updates['bio'],
          );

      isEditing.value = false;
      Get.snackbar("Success", "Profile updated successfully");
    } catch (e) {
      Get.snackbar("Error", "Failed to update profile: $e");
    } finally {
      isLoading.value = false;
    }
  }
}
