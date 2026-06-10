class UserStats {
  final int totalDonations;
  final int totalMealsDonated;
  final int totalDeliveriesCompleted;
  final int totalPurchases;
  final int totalFoodListingsCreated;
  final int favoriteListingsCount;

  const UserStats({
    this.totalDonations = 0,
    this.totalMealsDonated = 0,
    this.totalDeliveriesCompleted = 0,
    this.totalPurchases = 0,
    this.totalFoodListingsCreated = 0,
    this.favoriteListingsCount = 0,
  });
}

class AdminAnalytics {
  final int totalUsers;
  final int totalDonors;
  final int totalVolunteers;
  final int totalBuyers;
  final int totalNgos;
  final int totalFoodListings;
  final int totalActiveListings;
  final int totalCompletedDeliveries;
  final int totalMealsDonated;
  final int totalPurchases;
  final int totalFavoriteCounts;
  final double totalRevenue;
  final Map<String, int> userGrowthByMonth;
  final Map<String, int> donationsByMonth;
  final Map<String, int> deliveriesByMonth;
  final Map<String, int> categoryDistribution;
  final Map<String, int> roleDistribution;

  const AdminAnalytics({
    this.totalUsers = 0,
    this.totalDonors = 0,
    this.totalVolunteers = 0,
    this.totalBuyers = 0,
    this.totalNgos = 0,
    this.totalFoodListings = 0,
    this.totalActiveListings = 0,
    this.totalCompletedDeliveries = 0,
    this.totalMealsDonated = 0,
    this.totalPurchases = 0,
    this.totalFavoriteCounts = 0,
    this.totalRevenue = 0,
    this.userGrowthByMonth = const {},
    this.donationsByMonth = const {},
    this.deliveriesByMonth = const {},
    this.categoryDistribution = const {},
    this.roleDistribution = const {},
  });
}
