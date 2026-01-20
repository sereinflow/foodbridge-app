import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SupportController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final messageController = TextEditingController();
  var isSending = false.obs;

  var termsContent = ''.obs;
  var aboutContent = ''.obs;
  var isLoadingContent = true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchContent();
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    messageController.dispose();
    super.onClose();
  }

  Future<void> submitFeedback() async {
    if (messageController.text.isEmpty) {
      Get.snackbar("Error", "Please enter a message");
      return;
    }

    try {
      isSending.value = true;
      await _firestore.collection('feedback').add({
        'name': nameController.text,
        'email': emailController.text,
        'message': messageController.text,
        'createdAt': FieldValue.serverTimestamp(),
      });

      Get.snackbar("Success", "Message sent successfully!");
      nameController.clear();
      emailController.clear();
      messageController.clear();
    } catch (e) {
      Get.snackbar("Error", "Failed to send message: $e");
    } finally {
      isSending.value = false;
    }
  }

  Future<void> fetchContent() async {
    try {
      isLoadingContent.value = true;
      final termsDoc = await _firestore
          .collection('app_content')
          .doc('terms')
          .get();
      final aboutDoc = await _firestore
          .collection('app_content')
          .doc('about')
          .get();

      if (termsDoc.exists) {
        termsContent.value =
            termsDoc.data()?['text'] ??
            "Terms & Service content not available.";
      } else {
        termsContent.value = "Terms & Service content will be updated soon.";
      }

      if (aboutDoc.exists) {
        aboutContent.value =
            aboutDoc.data()?['text'] ?? "About Us content not available.";
      } else {
        aboutContent.value = "About Us content will be updated soon.";
      }
    } catch (e) {
      debugPrint("Error fetching content: $e");
      termsContent.value = "Failed to load content.";
      aboutContent.value = "Failed to load content.";
    } finally {
      isLoadingContent.value = false;
    }
  }
}
