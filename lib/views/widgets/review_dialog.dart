import 'package:flutter/material.dart';
import 'package:food_bridge/models/review_model.dart';
import 'package:food_bridge/utils/theme/colors.dart';
import 'package:food_bridge/utils/theme/spacing.dart';
import 'package:food_bridge/utils/theme/typography.dart';
import 'package:food_bridge/views/widgets/star_rating_widget.dart';

class ReviewDialog extends StatefulWidget {
  final String title;
  final String subtitle;
  final ReviewModel? existingReview;
  final Future<bool> Function(int rating, String? comment) onSubmit;

  const ReviewDialog({
    super.key,
    required this.title,
    required this.subtitle,
    this.existingReview,
    required this.onSubmit,
  });

  static Future<void> show({
    required BuildContext context,
    required String title,
    required String subtitle,
    ReviewModel? existingReview,
    required Future<bool> Function(int rating, String? comment) onSubmit,
  }) {
    return showDialog(
      context: context,
      builder: (_) => ReviewDialog(
        title: title,
        subtitle: subtitle,
        existingReview: existingReview,
        onSubmit: onSubmit,
      ),
    );
  }

  @override
  State<ReviewDialog> createState() => _ReviewDialogState();
}

class _ReviewDialogState extends State<ReviewDialog> {
  late int _rating;
  final _commentController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _rating = widget.existingReview?.rating ?? 0;
    _commentController.text = widget.existingReview?.comment ?? '';
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existingReview != null;

    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      ),
      title: Text(widget.title, style: AppTypography.headlineMedium),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.subtitle, style: AppTypography.bodyMedium),
            const SizedBox(height: AppSpacing.xl),
            Center(
              child: StarRatingWidget(
                rating: _rating.toDouble(),
                size: 36,
                interactive: true,
                onRatingChanged: (val) => setState(() => _rating = val),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            TextField(
              controller: _commentController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Write a review (optional)',
                labelText: 'Review',
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _rating == 0 || _isSubmitting
              ? null
              : () async {
                  setState(() => _isSubmitting = true);
                  final success = await widget.onSubmit(
                    _rating,
                    _commentController.text,
                  );
                  if (success && context.mounted) Navigator.pop(context);
                  if (mounted) setState(() => _isSubmitting = false);
                },
          child: _isSubmitting
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(isEdit ? 'Update' : 'Submit'),
        ),
      ],
    );
  }
}
