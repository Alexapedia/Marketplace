import '../utils/functions/json_helpers.dart';

class ReviewModel {
  final String id;
  final String targetType;
  final String targetId;
  final double rating;
  final String comment;
  final String userName;
  final String targetName;
  final DateTime? createdAt;

  const ReviewModel({
    this.id = '',
    this.targetType = '',
    this.targetId = '',
    this.rating = 0,
    this.comment = '',
    this.userName = '',
    this.targetName = '',
    this.createdAt,
  });

  factory ReviewModel.fromJson(dynamic json) {
    final map = asMap(json);
    return ReviewModel(
      id: asString(map['_id'] ?? map['id']),
      targetType: asString(map['targetType']),
      targetId: asString(map['targetId']),
      rating: asDouble(map['rating']),
      comment: asString(map['comment']),
      userName: asString(map['userName'] ?? map['name'], 'Customer'),
      targetName: localized(map['targetName']),
      createdAt: DateTime.tryParse(asString(map['createdAt'])),
    );
  }
}

class ReviewsPayload {
  final List<ReviewModel> items;
  final double ratingAvg;
  final int ratingCount;
  final bool canRate;
  final ReviewModel? myReview;

  const ReviewsPayload({
    this.items = const [],
    this.ratingAvg = 0,
    this.ratingCount = 0,
    this.canRate = false,
    this.myReview,
  });

  factory ReviewsPayload.fromJson(dynamic json) {
    final data = unwrapData(json);
    if (data is List) {
      return ReviewsPayload(items: data.map(ReviewModel.fromJson).toList());
    }
    final map = asMap(data);
    final mine = map['myReview'];
    return ReviewsPayload(
      items: asList(map['items'] ?? map['reviews']).map(ReviewModel.fromJson).toList(),
      ratingAvg: asDouble(map['ratingAvg']),
      ratingCount: asInt(map['ratingCount']),
      canRate: asBool(map['canRate']),
      myReview: mine is Map ? ReviewModel.fromJson(mine) : null,
    );
  }
}
