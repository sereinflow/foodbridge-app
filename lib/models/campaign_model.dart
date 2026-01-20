class CampaignModel {
  final String id;
  final String image;
  final String tag;
  final String title;
  final int donors;
  final double target;
  final double raised;
  final String description;
  final String contactNumber;
  final String userId; // Added for ownership

  CampaignModel({
    required this.id,
    required this.image,
    required this.tag,
    required this.title,
    required this.donors,
    required this.target,
    required this.raised,
    this.description = '',
    this.contactNumber = '',
    this.userId = '',
  });

  factory CampaignModel.fromMap(Map<String, dynamic> map, String id) {
    return CampaignModel(
      id: id,
      image: map['image'] ?? '',
      tag: map['tag'] ?? '',
      title: map['title'] ?? '',
      donors: map['donors'] is int ? map['donors'] : 0,
      target: map['target'] is num ? (map['target'] as num).toDouble() : 0.0,
      raised: map['raised'] is num ? (map['raised'] as num).toDouble() : 0.0,
      description: map['description'] ?? '',
      contactNumber: map['contactNumber'] ?? '',
      userId: map['userId'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'image': image,
      'tag': tag,
      'title': title,
      'donors': donors,
      'target': target,
      'raised': raised,
      'description': description,
      'contactNumber': contactNumber,
      'userId': userId,
    };
  }
}
