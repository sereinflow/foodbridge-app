import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:food_bridge/models/report_model.dart';
import 'package:food_bridge/utils/theme/colors.dart';
import 'package:food_bridge/utils/theme/spacing.dart';
import 'package:food_bridge/utils/theme/typography.dart';
import 'package:food_bridge/views/widgets/app_card.dart';
import 'package:food_bridge/views/widgets/custom_bw_button.dart';
import 'package:food_bridge/views/widgets/custom_confirmation_dialog.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class AdminReportsScreen extends StatefulWidget {
  const AdminReportsScreen({super.key});

  @override
  State<AdminReportsScreen> createState() => _AdminReportsScreenState();
}

class _AdminReportsScreenState extends State<AdminReportsScreen> {
  final _firestore = FirebaseFirestore.instance;

  String _filterType = 'All'; // All, Food, User
  String _filterStatus = 'Pending'; // Pending, Resolved

  Stream<List<ReportModel>> _streamReports() {
    Query query = _firestore.collection('reports');

    if (_filterStatus != 'All') {
      query = query.where('status', isEqualTo: _filterStatus);
    }

    if (_filterType != 'All') {
      query = query.where('type', isEqualTo: _filterType.toLowerCase());
    }

    return query.snapshots().map((snap) {
      final list = snap.docs
          .map((doc) => ReportModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
      // Sort in-memory by date descending
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }

  Future<void> _resolveReport(String reportId) async {
    try {
      await _firestore.collection('reports').doc(reportId).update({'status': 'Resolved'});
      Get.snackbar("Success", "Report marked as resolved", backgroundColor: Colors.green, colorText: Colors.white);
    } catch (e) {
      Get.snackbar("Error", "Failed to resolve report: $e");
    }
  }

  Future<void> _deleteListing(String reportId, String postId) async {
    try {
      // Delete post document
      await _firestore.collection('food_posts').doc(postId).delete();
      // Mark report resolved
      await _firestore.collection('reports').doc(reportId).update({'status': 'Resolved'});
      Get.snackbar("Success", "Listing deleted and report resolved", backgroundColor: Colors.green, colorText: Colors.white);
    } catch (e) {
      Get.snackbar("Error", "Failed to delete listing: $e");
    }
  }

  Future<void> _suspendUser(String reportId, String userId) async {
    try {
      // Suspend user by updating isSuspended flag
      await _firestore.collection('users').doc(userId).update({'isSuspended': true});
      // Mark report resolved
      await _firestore.collection('reports').doc(reportId).update({'status': 'Resolved'});
      Get.snackbar("Success", "User suspended and report resolved", backgroundColor: Colors.green, colorText: Colors.white);
    } catch (e) {
      Get.snackbar("Error", "Failed to suspend user: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Reports Management'),
        backgroundColor: AppColors.card,
      ),
      body: Column(
        children: [
          _buildFilterBar(),
          Expanded(
            child: StreamBuilder<List<ReportModel>>(
              stream: _streamReports(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                final reports = snapshot.data ?? [];
                if (reports.isEmpty) {
                  return const Center(
                    child: Text('No reports matching current filters.'),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: reports.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final report = reports[index];
                    return _buildReportItem(report);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      color: AppColors.card,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Report Type', style: TextStyle(fontWeight: FontWeight.bold)),
              Row(
                children: ['All', 'Food', 'User'].map((type) {
                  final isSelected = _filterType == type;
                  return Padding(
                    padding: const EdgeInsets.only(left: 6.0),
                    child: ChoiceChip(
                      label: Text(type),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _filterType = type;
                          });
                        }
                      },
                      selectedColor: AppColors.primary.withValues(alpha: 0.2),
                      checkmarkColor: AppColors.primary,
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Status', style: TextStyle(fontWeight: FontWeight.bold)),
              Row(
                children: ['Pending', 'Resolved', 'All'].map((status) {
                  final isSelected = _filterStatus == status;
                  return Padding(
                    padding: const EdgeInsets.only(left: 6.0),
                    child: ChoiceChip(
                      label: Text(status),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _filterStatus = status;
                          });
                        }
                      },
                      selectedColor: AppColors.primary.withValues(alpha: 0.2),
                      checkmarkColor: AppColors.primary,
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReportItem(ReportModel report) {
    final isFood = report.type == 'food';
    final isPending = report.status == 'Pending';

    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    isFood ? Icons.restaurant : Icons.person_outline,
                    color: isFood ? AppColors.primary : Colors.purple,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isFood ? 'Food Report' : 'User Report',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isFood ? AppColors.primary : Colors.purple,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isPending ? Colors.orange.shade100 : Colors.green.shade100,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  report.status,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: isPending ? Colors.deepOrange : Colors.green,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Reason: ${report.reason}',
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
          const SizedBox(height: 4),
          Text(
            report.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                DateFormat('dd/MM/yyyy HH:mm').format(report.createdAt),
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
              TextButton(
                onPressed: () => _reviewReportDetails(report),
                child: const Text('Review Report'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _reviewReportDetails(ReportModel report) {
    final isFood = report.type == 'food';
    final isPending = report.status == 'Pending';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isFood ? 'Food Report Details' : 'User Report Details',
                        style: AppTypography.headlineLarge,
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Get.back(),
                      ),
                    ],
                  ),
                  const Divider(height: 24),

                  // Metadata details
                  _buildDetailRow('Report ID', report.id),
                  _buildDetailRow('Reason', report.reason),
                  _buildDetailRow('Reported ID', report.targetId),
                  _buildDetailRow('Reporter ID', report.reporterId),
                  _buildDetailRow('Submitted At', DateFormat('yyyy-MM-dd HH:mm').format(report.createdAt)),
                  _buildDetailRow('Status', report.status),

                  const SizedBox(height: 16),
                  const Text('Description', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      report.description.isNotEmpty ? report.description : 'No description provided.',
                      style: AppTypography.bodyMedium,
                    ),
                  ),

                  if (report.imageUrl != null) ...[
                    const SizedBox(height: 16),
                    const Text('Uploaded Evidence', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        report.imageUrl!,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) return child;
                          return const SizedBox(height: 200, child: Center(child: CircularProgressIndicator()));
                        },
                      ),
                    ),
                  ],

                  // Action Buttons (only visible if report is Pending)
                  if (isPending) ...[
                    const SizedBox(height: 32),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              CustomConfirmationDialog.show(
                                title: 'Mark Resolved',
                                message: 'Are you sure you want to mark this report as resolved?',
                                onConfirm: () {
                                  Get.back(); // Close dialog
                                  Get.back(); // Close bottom sheet
                                  _resolveReport(report.id);
                                },
                              );
                            },
                            child: const Text('Mark Resolved'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              CustomConfirmationDialog.show(
                                title: isFood ? 'Delete Listing' : 'Suspend User',
                                message: isFood
                                    ? 'Are you sure you want to delete this listing? This will also resolve this report.'
                                    : 'Are you sure you want to suspend this user? This will also resolve this report.',
                                onConfirm: () {
                                  Get.back(); // Close dialog
                                  Get.back(); // Close bottom sheet
                                  if (isFood) {
                                    _deleteListing(report.id, report.targetId);
                                  } else {
                                    _suspendUser(report.id, report.targetId);
                                  }
                                },
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.error,
                              foregroundColor: Colors.white,
                            ),
                            child: Text(isFood ? 'Delete Listing' : 'Suspend User'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 13),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
