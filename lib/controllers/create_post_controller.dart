import 'dart:io';
import 'package:flutter/material.dart';
import 'package:food_bridge/controllers/auth_controller.dart';
import 'package:food_bridge/controllers/home_controller.dart';
import 'package:food_bridge/data/post_repository.dart';
import 'package:food_bridge/models/campaign_model.dart';
import 'package:food_bridge/models/food_post_model.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

class CreatePostController extends GetxController {
  final AuthController _authController = Get.find();
  final PostRepository _repository = PostRepository();
  final ImagePicker _picker = ImagePicker();

  var isLoading = false.obs;
  var selectedPostType = 0.obs;
  var foodType = 'Free'.obs;

  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final quantityController = TextEditingController();
  final locationController = TextEditingController();
  final priceController = TextEditingController();
  final targetController = TextEditingController();
  final phoneController = TextEditingController();
  final imageUrlController = TextEditingController();

  var selectedImage = Rx<File?>(null);
  var isUsingUrl = false.obs;

  @override
  void onClose() {
    titleController.dispose();
    descriptionController.dispose();
    quantityController.dispose();
    locationController.dispose();
    priceController.dispose();
    targetController.dispose();
    phoneController.dispose();
    imageUrlController.dispose();
    super.onClose();
  }

  void pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      selectedImage.value = File(pickedFile.path);
    }
  }

  void removeImage() {
    selectedImage.value = null;
  }

  Future<String?> _uploadImage(String path) async {
    if (selectedImage.value == null) return null;
    try {
      final ref = FirebaseStorage.instance.ref().child(
        '$path/${DateTime.now().millisecondsSinceEpoch}.jpg',
      );
      await ref.putFile(selectedImage.value!);
      return await ref.getDownloadURL();
    } catch (e) {
      Get.snackbar("Error", "Failed to upload image");
      return null;
    }
  }

  Future<void> createPost() async {
    if (titleController.text.isEmpty || descriptionController.text.isEmpty) {
      Get.snackbar("Error", "Title and Description are required");
      return;
    }

    if (!isUsingUrl.value && selectedImage.value == null) {
      Get.snackbar("Error", "Please select an image");
      return;
    }

    if (isUsingUrl.value && imageUrlController.text.isEmpty) {
      Get.snackbar("Error", "Please enter an image URL");
      return;
    }

    try {
      isLoading.value = true;
      String userId = _repository.currentUserId;
      String postId = const Uuid().v4();

      String? imageUrl;
      if (isUsingUrl.value) {
        imageUrl = imageUrlController.text.trim();
      } else {
        imageUrl = await _uploadImage(
          selectedPostType.value == 0 ? 'food_posts' : 'campaigns',
        );
      }

      if (imageUrl == null) return;

      if (selectedPostType.value == 0) {
        final post = FoodPostModel(
          id: postId,
          userId: userId,
          userName: _authController.userModel.value!.name,
          type: foodType.value,
          title: titleController.text,
          description: descriptionController.text,
          quantity: quantityController.text,
          pickupLocation: locationController.text,
          imageUrl: imageUrl,
          status: 'Available',
          createdAt: DateTime.now(),
          price: double.tryParse(priceController.text) ?? 0.0,
        );

        await _repository.createFoodPost(post);
        Get.snackbar("Success", "Food post created successfully!");
      } else {
        final campaign = CampaignModel(
          id: postId,
          userId: userId,
          image: imageUrl,
          tag: locationController.text.isNotEmpty
              ? locationController.text
              : "General",
          title: titleController.text,
          donors: 0,
          target: double.tryParse(targetController.text) ?? 0.0,
          raised: 0.0,
          description: descriptionController.text,
          contactNumber: phoneController.text,
        );

        await _repository.createCampaign(campaign);
        Get.snackbar("Success", "Campaign created successfully!");
      }

      _clearForm();
      if (Get.isRegistered<HomeController>()) {
        Get.find<HomeController>().fetchData();
      }

      Get.back();
    } catch (e) {
      Get.snackbar("Error", "Failed to create post: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void _clearForm() {
    titleController.clear();
    descriptionController.clear();
    quantityController.clear();
    locationController.clear();
    priceController.clear();
    targetController.clear();
    phoneController.clear();
    imageUrlController.clear();
    selectedImage.value = null;
    isUsingUrl.value = false;
  }
}
