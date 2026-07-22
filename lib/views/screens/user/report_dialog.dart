import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:food_bridge/controllers/auth_controller.dart';
import 'package:food_bridge/models/report_model.dart';
import 'package:food_bridge/utils/theme/colors.dart';
import 'package:food_bridge/views/widgets/custom_bw_button.dart';
import 'package:food_bridge/views/widgets/custom_textfield.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

class ReportDialog extends StatefulWidget {
  final String reportType; // 'food' or 'user'
  final String targetId;

  const ReportDialog({
    super.key,
    required this.reportType,
    required this.targetId,
  });

  static void show({
    required BuildContext context,
    required String reportType,
    required String targetId,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: ReportDialog(
          reportType: reportType,
          targetId: targetId,
        ),
      ),
    );
  }

  @override
  State<ReportDialog> createState() => _ReportDialogState();
}

class _ReportDialogState extends State<ReportDialog> {
  final _descriptionController = TextEditingController();
  final _uuid = const Uuid();
  String? _selectedReason;
  XFile? _selectedImage;
  bool _isSubmitting = false;

  List<String> get _reasons {
    if (widget.reportType == 'food') {
      return [
        'expired_food'.tr,
        'unsafe_food'.tr,
        'fake_listing'.tr,
        'incorrect_info'.tr,
      ];
    } else {
      return [
        'fake_account'.tr,
        'bad_behavior'.tr,
        'fraud'.tr,
        'harassment'.tr,
      ];
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (image != null) {
      setState(() {
        _selectedImage = image;
      });
    }
  }

  Future<void> _submitReport() async {
    if (_selectedReason == null) {
      Get.snackbar('error'.tr, "Please select a reason for the report.");
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final reporterId = Get.find<AuthController>().userModel.value?.uid ?? '';
      String? imageUrl;

      // Upload image if selected
      if (_selectedImage != null) {
        final ref = FirebaseStorage.instance
            .ref()
            .child('reports/${_uuid.v4()}.jpg');
        final uploadTask = await ref.putFile(File(_selectedImage!.path));
        imageUrl = await uploadTask.ref.getDownloadURL();
      }

      final reportId = _uuid.v4();
      final report = ReportModel(
        id: reportId,
        type: widget.reportType,
        reason: _selectedReason!,
        description: _descriptionController.text.trim(),
        targetId: widget.targetId,
        reporterId: reporterId,
        imageUrl: imageUrl,
        createdAt: DateTime.now(),
        status: 'Pending',
      );

      // Save to Firebase
      await FirebaseFirestore.instance
          .collection('reports')
          .doc(reportId)
          .set(report.toMap());

      Get.back(); // Close dialog
      Get.snackbar(
        'success'.tr,
        'report_success'.tr,
        backgroundColor: AppColors.primary,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar('error'.tr, "Failed to submit report: $e");
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'report_title'.tr,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Get.back(),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Reason selector dropdown
          DropdownButtonFormField<String>(
            value: _selectedReason,
            hint: Text(
              'report_reason'.tr,
              style: TextStyle(color: AppColors.textSecondary),
            ),
            dropdownColor: AppColors.card,
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.background,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: isDark ? Colors.white10 : Colors.black12),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: isDark ? Colors.white10 : Colors.black12),
              ),
            ),
            style: TextStyle(color: AppColors.textPrimary, fontSize: 15),
            items: _reasons
                .map((reason) => DropdownMenuItem(
                      value: reason,
                      child: Text(reason),
                    ))
                .toList(),
            onChanged: (val) {
              setState(() {
                _selectedReason = val;
              });
            },
          ),
          const SizedBox(height: 16),

          // Description box
          TextField(
            controller: _descriptionController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'report_desc_hint'.tr,
              hintStyle: TextStyle(color: AppColors.textSecondary),
              filled: true,
              fillColor: AppColors.background,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: isDark ? Colors.white10 : Colors.black12),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: isDark ? Colors.white10 : Colors.black12),
              ),
            ),
            style: TextStyle(color: AppColors.textPrimary),
          ),
          const SizedBox(height: 16),

          // Optional Image picker box
          Text(
            'optional_image'.tr,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: _pickImage,
            child: Container(
              height: 100,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
              ),
              child: _selectedImage != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        File(_selectedImage!.path),
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ),
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.add_a_photo_outlined, color: AppColors.primary, size: 28),
                        const SizedBox(height: 4),
                        Text(
                          'optional_image'.tr,
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 24),

          // Submit button
          CustomBWButton(
            isLoading: _isSubmitting,
            title: 'submit'.tr,
            bgColor: AppColors.primary,
            shadowLight: AppColors.card,
            shadowDark: AppColors.surfaceMuted,
            textColor: Colors.white,
            onTap: _submitReport,
          ),
        ],
      ),
    );
  }
}
