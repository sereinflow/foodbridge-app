import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:food_bridge/controllers/auth_controller.dart';
import 'package:food_bridge/data/stats_repository.dart';
import 'package:food_bridge/data/review_repository.dart';
import 'package:food_bridge/models/user.dart';
import 'package:food_bridge/models/user_stats.dart';
import 'package:food_bridge/models/review_model.dart';
import 'package:food_bridge/models/food_post_model.dart';
import 'package:food_bridge/models/food_request_model.dart';
import 'package:food_bridge/models/campaign_model.dart';
import 'package:food_bridge/utils/theme/colors.dart';
import 'package:food_bridge/utils/theme/spacing.dart';
import 'package:food_bridge/utils/theme/typography.dart';
import 'package:food_bridge/views/screens/user/report_dialog.dart';
import 'package:food_bridge/views/screens/chat/chat_screen.dart';
import 'package:food_bridge/views/widgets/app_card.dart';
import 'package:food_bridge/views/widgets/star_rating_widget.dart';
import 'package:food_bridge/views/widgets/stat_card.dart';
import 'package:get/get.dart';

class UserProfileDetailsScreen extends StatefulWidget {
  final String userId;

  const UserProfileDetailsScreen({super.key, required this.userId});

  @override
  State<UserProfileDetailsScreen> createState() => _UserProfileDetailsScreenState();
}

class _UserProfileDetailsScreenState extends State<UserProfileDetailsScreen> {
  final _firestore = FirebaseFirestore.instance;
  final _statsRepository = StatsRepository();
  final _reviewRepository = ReviewRepository();

  bool _isLoading = true;
  UserModel? _user;
  UserStats? _stats;
  List<ReviewModel> _reviews = [];
  List<FoodPostModel> _donations = [];
  List<FoodRequestModel> _purchases = [];
  List<CampaignModel> _ngoCampaigns = [];
  bool _canChat = false;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    try {
      setState(() {
        _isLoading = true;
      });

      // Fetch user doc
      final userDoc = await _firestore.collection('users').doc(widget.userId).get();
      if (!userDoc.exists) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      _user = UserModel.fromMap(userDoc.data()!);

      // Fetch stats
      _stats = await _statsRepository.getUserStats(_user!.uid, _user!.savedPosts);

      // Fetch reviews
      _reviews = await _reviewRepository.getReviewsForUser(_user!.uid);

      // Fetch role-specific histories
      final role = _user!.role.toLowerCase();
      if (role == 'donor') {
        final postsSnap = await _firestore
            .collection('food_posts')
            .where('userId', isEqualTo: _user!.uid)
            .get();
        _donations = postsSnap.docs
            .map((doc) => FoodPostModel.fromMap(doc.data(), doc.id))
            .toList();
      } else if (role == 'buyer') {
        final reqsSnap = await _firestore
            .collection('food_requests')
            .where('requesterId', isEqualTo: _user!.uid)
            .get();
        _purchases = reqsSnap.docs
            .map((doc) => FoodRequestModel.fromMap(doc.data(), doc.id))
            .toList();
      } else if (role == 'ngo') {
        final campaignsSnap = await _firestore
            .collection('campaigns')
            .where('userId', isEqualTo: _user!.uid)
            .get();
        _ngoCampaigns = campaignsSnap.docs
            .map((doc) => CampaignModel.fromMap(doc.data(), doc.id))
            .toList();
      }
      await _checkChatPermission();
    } catch (e) {
      debugPrint("Error loading user profile: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _checkChatPermission() async {
    final currentUserId = Get.find<AuthController>().userModel.value?.uid ?? '';
    if (currentUserId.isEmpty || widget.userId == currentUserId) return;

    try {
      final requestsSnap1 = await _firestore
          .collection('food_requests')
          .where('donorId', isEqualTo: currentUserId)
          .where('requesterId', isEqualTo: widget.userId)
          .get();

      final requestsSnap2 = await _firestore
          .collection('food_requests')
          .where('donorId', isEqualTo: widget.userId)
          .where('requesterId', isEqualTo: currentUserId)
          .get();

      final allRequests = [...requestsSnap1.docs, ...requestsSnap2.docs];

      final hasActiveTransaction = allRequests.any((doc) {
        final status = doc.data()['status'] as String?;
        return status == 'Approved' || status == 'Completed';
      });

      setState(() {
        _canChat = hasActiveTransaction;
      });
    } catch (e) {
      debugPrint("Error checking chat permission: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(title: Text('loading'.tr)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_user == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(title: Text('error'.tr)),
        body: Center(child: Text('User not found'.tr)),
      );
    }

    final currentUserId = Get.find<AuthController>().userModel.value?.uid;
    final isSelf = currentUserId == _user!.uid;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(_user!.name),
        actions: [
          if (!isSelf)
            IconButton(
              icon: const Icon(Icons.flag_outlined, color: AppColors.error),
              tooltip: 'report_button'.tr,
              onPressed: () {
                ReportDialog.show(
                  context: context,
                  reportType: 'user',
                  targetId: _user!.uid,
                );
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.screenPadding,
        child: Column(
          children: [
            const SizedBox(height: AppSpacing.lg),
            // Avatar Card
            Container(
              height: 90,
              width: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppColors.warmGradient,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.25),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: Text(
                _user!.name.isNotEmpty ? _user!.name[0].toUpperCase() : 'U',
                style: AppTypography.displayMedium.copyWith(color: Colors.white),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(_user!.name, style: AppTypography.headlineMedium),
            Text(_user!.role.toUpperCase(), style: AppTypography.bodySmall.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold)),
            const SizedBox(height: AppSpacing.sm),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                StarRatingWidget(rating: _user!.averageRating, size: 18),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  "${_user!.averageRating.toStringAsFixed(1)} (${_user!.reviewCount} ${_user!.reviewCount == 1 ? 'review' : 'reviews'})",
                  style: AppTypography.bodySmall,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),

            // Chat button for others
            if (!isSelf) ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    if (_canChat) {
                      Get.to(() => ChatScreen(
                            peerId: _user!.uid,
                            peerName: _user!.name,
                          ));
                    } else {
                      Get.snackbar(
                        'Chat Disabled',
                        'You can start chatting once a pickup/donation is approved or a purchase is completed.',
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: Colors.orange,
                        colorText: Colors.white,
                      );
                    }
                  },
                  icon: const Icon(Icons.chat_bubble_outline, color: Colors.white),
                  label: Text('chats'.tr, style: const TextStyle(fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _canChat ? AppColors.primary : Colors.grey.shade400,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
            ],

            // Stats row
            _buildStatsGrid(),
            const SizedBox(height: AppSpacing.lg),

            // Bio & Details
            _buildInfoCard(),
            const SizedBox(height: AppSpacing.lg),

            // History sections
            _buildHistorySection(),
            const SizedBox(height: AppSpacing.lg),

            // Reviews list
            _buildReviewsList(),
            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsGrid() {
    if (_stats == null) return const SizedBox.shrink();
    final role = _user!.role.toLowerCase();

    if (role == 'donor') {
      return Row(
        children: [
          Expanded(child: StatCard(title: 'donations_stat'.tr, value: _stats!.totalDonations, icon: Icons.volunteer_activism, iconColor: AppColors.primary)),
          const SizedBox(width: 10),
          Expanded(child: StatCard(title: 'meals_stat'.tr, value: _stats!.totalMealsDonated, icon: Icons.restaurant, iconColor: AppColors.success)),
          const SizedBox(width: 10),
          Expanded(child: StatCard(title: 'deliveries_stat'.tr, value: _stats!.totalDeliveriesCompleted, icon: Icons.local_shipping, iconColor: AppColors.info)),
        ],
      );
    } else if (role == 'volunteer') {
      return Row(
        children: [
          Expanded(child: StatCard(title: 'deliveries_stat'.tr, value: _stats!.totalDeliveriesCompleted, icon: Icons.local_shipping, iconColor: AppColors.primary)),
          const SizedBox(width: 10),
          Expanded(child: StatCard(title: 'meals_stat'.tr, value: _stats!.totalDeliveriesCompleted * 4, icon: Icons.restaurant, iconColor: AppColors.success)),
        ],
      );
    } else if (role == 'buyer') {
      return Row(
        children: [
          Expanded(child: StatCard(title: 'purchases_stat'.tr, value: _stats!.totalPurchases, icon: Icons.shopping_bag, iconColor: AppColors.primary)),
        ],
      );
    } else if (role == 'ngo') {
      return Row(
        children: [
          Expanded(child: StatCard(title: 'donations_stat'.tr, value: _stats!.totalDonations, icon: Icons.campaign, iconColor: AppColors.primary)),
          const SizedBox(width: 10),
          Expanded(child: StatCard(title: 'meals_stat'.tr, value: _stats!.totalMealsDonated, icon: Icons.restaurant, iconColor: AppColors.success)),
        ],
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildInfoCard() {
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.info_outline, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text('about_us'.tr, style: AppTypography.titleMedium),
            ],
          ),
          const Divider(height: 24),
          Text(
            (_user!.bio?.isNotEmpty ?? false) ? _user!.bio! : 'no_bio'.tr,
            style: AppTypography.bodyMedium,
          ),
          if (_user!.phone?.isNotEmpty ?? false) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.phone_outlined, size: 16, color: AppColors.textSecondary),
                const SizedBox(width: 8),
                Text(_user!.phone!, style: AppTypography.bodyMedium),
              ],
            ),
          ]
        ],
      ),
    );
  }

  Widget _buildHistorySection() {
    final role = _user!.role.toLowerCase();

    if (role == 'donor' && _donations.isNotEmpty) {
      return _buildSectionLayout(
        title: 'campaign_history'.tr,
        items: _donations.take(4).map((post) {
          return ListTile(
            title: Text(post.title, style: AppTypography.titleMedium),
            subtitle: Text('${post.quantity} • ${post.pickupLocation}'),
            trailing: Text(post.status, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
          );
        }).toList(),
      );
    } else if (role == 'buyer' && _purchases.isNotEmpty) {
      return _buildSectionLayout(
        title: 'my_collections'.tr,
        items: _purchases.take(4).map((req) {
          return ListTile(
            title: Text(req.postTitle, style: AppTypography.titleMedium),
            subtitle: Text(DateFormat('yyyy-MM-dd').format(req.createdAt)),
            trailing: Text(req.status, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
          );
        }).toList(),
      );
    } else if (role == 'ngo' && _ngoCampaigns.isNotEmpty) {
      return _buildSectionLayout(
        title: 'Donation Rising'.tr,
        items: _ngoCampaigns.take(4).map((camp) {
          return ListTile(
            title: Text(camp.title, style: AppTypography.titleMedium),
            subtitle: Text('Target: BDT ${camp.target}'),
            trailing: Text('Raised: BDT ${camp.raised}', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
          );
        }).toList(),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildSectionLayout({required String title, required List<Widget> items}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        const SizedBox(height: 8),
        AppCard(
          padding: EdgeInsets.zero,
          child: Column(children: items),
        ),
      ],
    );
  }

  Widget _buildReviewsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('view_reviews'.tr, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        const SizedBox(height: 8),
        if (_reviews.isEmpty)
          AppCard(
            padding: const EdgeInsets.all(20),
            child: Center(child: Text('no_messages'.tr, style: AppTypography.bodyMedium)),
          )
        else
          Column(
            children: _reviews.take(5).map((review) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: AppCard(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(review.reviewerName, style: AppTypography.titleMedium),
                          StarRatingWidget(rating: review.rating.toDouble(), size: 14),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        review.comment ?? '',
                        style: AppTypography.bodyMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat('yyyy-MM-dd HH:mm').format(review.createdAt),
                        style: AppTypography.bodySmall,
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
      ],
    );
  }
}
