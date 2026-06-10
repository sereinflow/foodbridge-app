import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:food_bridge/models/food_post_model.dart';
import 'package:food_bridge/models/food_request_model.dart';
import 'package:food_bridge/models/user_stats.dart';
import 'package:intl/intl.dart';

class StatsRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Parses a numeric meal count from quantity strings like "10 plates" or "5".
  int parseMealQuantity(String quantity) {
    final match = RegExp(r'(\d+)').firstMatch(quantity);
    if (match != null) return int.tryParse(match.group(1)!) ?? 1;
    return 1;
  }

  Future<UserStats> getUserStats(String userId, List<String> savedPostIds) async {
    if (userId.isEmpty) return const UserStats();

    final postsSnapshot = await _firestore
        .collection('food_posts')
        .where('userId', isEqualTo: userId)
        .get();

    final requestsSnapshot = await _firestore
        .collection('food_requests')
        .where('requesterId', isEqualTo: userId)
        .get();

    final donorRequestsSnapshot = await _firestore
        .collection('food_requests')
        .where('donorId', isEqualTo: userId)
        .get();

    final posts = postsSnapshot.docs
        .map((d) => FoodPostModel.fromMap(d.data(), d.id))
        .toList();

    final myRequests = requestsSnapshot.docs
        .map((d) => FoodRequestModel.fromMap(d.data(), d.id))
        .toList();

    final donorRequests = donorRequestsSnapshot.docs
        .map((d) => FoodRequestModel.fromMap(d.data(), d.id))
        .toList();

    final donatedPosts = posts.where((p) =>
        p.type == 'Free' &&
        ['Claimed', 'Completed', 'Sold'].contains(p.status));

    final totalMealsDonated = donatedPosts.fold<int>(
      0,
      (sum, p) => sum + parseMealQuantity(p.quantity),
    );

    final completedAsVolunteer = myRequests.where((r) =>
        r.status == 'Completed' && r.postType == 'Free').length;

    final completedDeliveriesDonor = donorRequests
        .where((r) => r.status == 'Completed')
        .length;

    final totalPurchases = myRequests
        .where((r) => r.status == 'Completed' && r.postType == 'Sale')
        .length;

    return UserStats(
      totalDonations: donatedPosts.length,
      totalMealsDonated: totalMealsDonated,
      totalDeliveriesCompleted:
          completedAsVolunteer + completedDeliveriesDonor,
      totalPurchases: totalPurchases,
      totalFoodListingsCreated: posts.length,
      favoriteListingsCount: savedPostIds.length,
    );
  }

  Future<AdminAnalytics> getAdminAnalytics() async {
    final usersSnap = await _firestore.collection('users').get();
    final postsSnap = await _firestore.collection('food_posts').get();
    final requestsSnap = await _firestore.collection('food_requests').get();
    final campaignsSnap = await _firestore.collection('campaigns').get();

    final users = usersSnap.docs;
    final posts = postsSnap.docs
        .map((d) => FoodPostModel.fromMap(d.data(), d.id))
        .toList();
    final requests = requestsSnap.docs
        .map((d) => FoodRequestModel.fromMap(d.data(), d.id))
        .toList();

    final donorIds = posts.map((p) => p.userId).toSet();
    final volunteerIds = requests
        .where((r) => r.status == 'Completed' && r.postType == 'Free')
        .map((r) => r.requesterId)
        .toSet();
    final buyerIds = requests
        .where((r) => r.status == 'Completed' && r.postType == 'Sale')
        .map((r) => r.requesterId)
        .toSet();
    final ngoIds = campaignsSnap.docs
        .map((d) => d.data()['userId'] as String? ?? '')
        .where((id) => id.isNotEmpty)
        .toSet();

    int totalFavorites = 0;
    final roleDistribution = <String, int>{
      'Donors': 0,
      'Volunteers': 0,
      'Buyers': 0,
      'NGOs': 0,
      'General': 0,
    };

    final userGrowthByMonth = <String, int>{};
    final monthLabelFormat = DateFormat('MMM yy');

    for (final doc in users) {
      final data = doc.data();
      totalFavorites +=
          (data['savedPosts'] as List<dynamic>? ?? []).length;

      final userType = data['userType'] as String?;
      if (userType != null && userType.isNotEmpty) {
        final key = _capitalizeRole(userType);
        roleDistribution[key] = (roleDistribution[key] ?? 0) + 1;
      } else {
        final uid = doc.id;
        if (ngoIds.contains(uid)) {
          roleDistribution['NGOs'] = (roleDistribution['NGOs'] ?? 0) + 1;
        } else if (donorIds.contains(uid)) {
          roleDistribution['Donors'] = (roleDistribution['Donors'] ?? 0) + 1;
        } else if (volunteerIds.contains(uid)) {
          roleDistribution['Volunteers'] =
              (roleDistribution['Volunteers'] ?? 0) + 1;
        } else if (buyerIds.contains(uid)) {
          roleDistribution['Buyers'] = (roleDistribution['Buyers'] ?? 0) + 1;
        } else {
          roleDistribution['General'] =
              (roleDistribution['General'] ?? 0) + 1;
        }
      }

      final createdAt = (data['createdAt'] as Timestamp?)?.toDate();
      if (createdAt != null) {
        _incrementMonthCount(userGrowthByMonth, createdAt, monthLabelFormat);
      }
    }

    final donationsByMonth = <String, int>{};
    final deliveriesByMonth = <String, int>{};
    final categoryDistribution = <String, int>{};

    for (final post in posts) {
      final category = post.tags.isNotEmpty ? post.tags.first : 'General';
      categoryDistribution[category] =
          (categoryDistribution[category] ?? 0) + 1;

      if (post.type == 'Free' &&
          ['Claimed', 'Completed'].contains(post.status)) {
        _incrementMonthCount(donationsByMonth, post.createdAt, monthLabelFormat);
      }
    }

    for (final request in requests) {
      if (request.status == 'Completed') {
        _incrementMonthCount(
          deliveriesByMonth,
          request.createdAt,
          monthLabelFormat,
        );
      }
    }

    final completedDeliveries =
        requests.where((r) => r.status == 'Completed').length;
    final completedPurchases = requests
        .where((r) => r.status == 'Completed' && r.postType == 'Sale')
        .length;

    final donatedMeals = posts
        .where((p) =>
            p.type == 'Free' &&
            ['Claimed', 'Completed'].contains(p.status))
        .fold<int>(0, (sum, p) => sum + parseMealQuantity(p.quantity));

    double totalRevenue = 0;
    for (final request in requests) {
      if (request.status == 'Completed' && request.postType == 'Sale') {
        final post = posts.where((p) => p.id == request.postId).firstOrNull;
        if (post != null) totalRevenue += post.price;
      }
    }

    return AdminAnalytics(
      totalUsers: users.length,
      totalDonors: donorIds.length,
      totalVolunteers: volunteerIds.length,
      totalBuyers: buyerIds.length,
      totalNgos: ngoIds.length,
      totalFoodListings: posts.length,
      totalActiveListings:
          posts.where((p) => p.status == 'Available').length,
      totalCompletedDeliveries: completedDeliveries,
      totalMealsDonated: donatedMeals,
      totalPurchases: completedPurchases,
      totalFavoriteCounts: totalFavorites,
      totalRevenue: totalRevenue,
      userGrowthByMonth: _sortMonthMap(userGrowthByMonth),
      donationsByMonth: _sortMonthMap(donationsByMonth),
      deliveriesByMonth: _sortMonthMap(deliveriesByMonth),
      categoryDistribution: categoryDistribution,
      roleDistribution: roleDistribution,
    );
  }

  void _incrementMonthCount(
    Map<String, int> map,
    DateTime date,
    DateFormat labelFormat,
  ) {
    final sortKey = '${date.year}-${date.month.toString().padLeft(2, '0')}';
    final label = '${labelFormat.format(date)}|$sortKey';
    map[label] = (map[label] ?? 0) + 1;
  }

  Map<String, int> _sortMonthMap(Map<String, int> raw) {
    final entries = raw.entries.toList()
      ..sort((a, b) {
        final aKey = a.key.split('|').last;
        final bKey = b.key.split('|').last;
        return aKey.compareTo(bKey);
      });
    return {
      for (final e in entries) e.key.split('|').first: e.value,
    };
  }

  String _capitalizeRole(String role) {
    switch (role.toLowerCase()) {
      case 'donor':
        return 'Donors';
      case 'volunteer':
        return 'Volunteers';
      case 'buyer':
        return 'Buyers';
      case 'ngo':
        return 'NGOs';
      default:
        return role;
    }
  }
}

extension _FirstOrNull<E> on Iterable<E> {
  E? get firstOrNull {
    final iterator = this.iterator;
    if (iterator.moveNext()) return iterator.current;
    return null;
  }
}
