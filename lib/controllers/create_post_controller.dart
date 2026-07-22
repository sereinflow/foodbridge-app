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
  var selectedTags = <String>[].obs;

  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final quantityController = TextEditingController();
  final locationController = TextEditingController();
  final priceController = TextEditingController();
  final targetController = TextEditingController();
  final phoneController = TextEditingController();
  final imageUrlController = TextEditingController();
  final temperatureController = TextEditingController();

  var selectedImage = Rx<File?>(null);
  var isUsingUrl = false.obs;
  var expiryDate = Rx<DateTime?>(null);
  var isSafetyVerified = false.obs;

  Future<void> pickExpiryDateTime(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (pickedTime != null) {
        expiryDate.value = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );
      }
    }
  }

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
    temperatureController.dispose();
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

  var isEdit = false.obs;
  FoodPostModel? _editingPost;

  void initForEdit(FoodPostModel post) {
    isEdit.value = true;
    _editingPost = post;

    selectedPostType.value = 0;
    titleController.text = post.title;
    descriptionController.text = post.description;
    quantityController.text = post.quantity;
    locationController.text = post.pickupLocation;
    priceController.text = post.price.toStringAsFixed(0);
    foodType.value = post.type;
    selectedTags.assignAll(post.tags);
    expiryDate.value = post.expiryDate;
    temperatureController.text = post.storageTemperature ?? '';
    imageUrlController.text = post.imageUrl;
    isUsingUrl.value = true;
    isSafetyVerified.value = true;
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
      String postId = isEdit.value && _editingPost != null ? _editingPost!.id : const Uuid().v4();

      String? imageUrl;
      if (isUsingUrl.value) {
        imageUrl = imageUrlController.text.trim();
      } else {
        imageUrl = await _uploadImage(
          selectedPostType.value == 0 ? 'food_posts' : 'campaigns',
        );
        imageUrl ??= isEdit.value && _editingPost != null ? _editingPost!.imageUrl : null;
      }

      if (imageUrl == null) return;

      if (selectedPostType.value == 0) {
        List<String> safetyAlerts = [];
        if (temperatureController.text.isNotEmpty) {
          safetyAlerts.add("Requires specific storage temperature: ${temperatureController.text}");
        }
        if (expiryDate.value != null) {
          final hoursUntilExpiry = expiryDate.value!.difference(DateTime.now()).inHours;
          if (hoursUntilExpiry < 24) {
            safetyAlerts.add("Expires soon (within 24 hours)");
          }
        }

        if (isEdit.value && _editingPost != null) {
          final updatedPost = _editingPost!.copyWith(
            title: titleController.text,
            description: descriptionController.text,
            quantity: quantityController.text,
            pickupLocation: locationController.text,
            price: double.tryParse(priceController.text) ?? 0.0,
            type: foodType.value,
            tags: selectedTags.toList(),
            expiryDate: expiryDate.value,
            storageTemperature: temperatureController.text.trim().isEmpty ? null : temperatureController.text.trim(),
            imageUrl: imageUrl,
            safetyAlerts: safetyAlerts,
          );
          await _repository.updateFoodPost(updatedPost);
          Get.snackbar("Success", "Food post updated successfully!");
        } else {
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
            tags: selectedTags.toList(),
            expiryDate: expiryDate.value,
            storageTemperature: temperatureController.text.trim().isEmpty ? null : temperatureController.text.trim(),
            safetyAlerts: safetyAlerts,
          );
          await _repository.createFoodPost(post);
          Get.snackbar("Success", "Food post created successfully!");
        }
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

      clearForm();
      if (Get.isRegistered<HomeController>()) {
        Get.find<HomeController>().fetchData();
      }

      Get.back();
    } catch (e) {
      Get.snackbar("Error", "Failed to save post: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void clearForm() {
    isEdit.value = false;
    _editingPost = null;
    titleController.clear();
    descriptionController.clear();
    quantityController.clear();
    locationController.clear();
    priceController.clear();
    targetController.clear();
    phoneController.clear();
    imageUrlController.clear();
    temperatureController.clear();
    selectedImage.value = null;
    isUsingUrl.value = false;
    selectedTags.clear();
    expiryDate.value = null;
    isSafetyVerified.value = false;
  }
}
