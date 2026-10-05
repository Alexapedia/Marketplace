import '../utils/functions/json_helpers.dart';
import '../utils/functions/print_state.dart';

class CustomFieldModel {
  final String id;
  final String name;
  final String label;
  final String type;
  final bool required;
  final List<String> options;
  final String placeholder;

  const CustomFieldModel({
    this.id = '',
    this.name = '',
    this.label = '',
    this.type = 'text',
    this.required = false,
    this.options = const [],
    this.placeholder = '',
  });

  factory CustomFieldModel.fromJson(dynamic json) {
    final map = asMap(json);
    final id = asString(map['_id'] ?? map['id']);
    return CustomFieldModel(
      id: id,
      name: asString(map['name'] ?? map['key'], id),
      label: localized(map['label'] ?? map['labels'] ?? map['name']),
      type: asString(map['type'] ?? map['fieldType'], 'text'),
      required: asBool(map['required']),
      options: asList(map['options']).map((e) => localized(e)).toList(),
      placeholder: localized(map['placeholder']),
    );
  }

  String get key => id.isNotEmpty ? id : name;
}

class ProposalModel {
  final String id;
  final double price;
  final String notes;
  final String status;
  final DateTime? createdAt;

  const ProposalModel({
    this.id = '',
    this.price = 0,
    this.notes = '',
    this.status = '',
    this.createdAt,
  });

  factory ProposalModel.fromJson(dynamic json) {
    final map = asMap(json);
    return ProposalModel(
      id: asString(map['_id'] ?? map['id']),
      price: asDouble(map['price'] ?? map['amount']),
      notes: localized(map['notes'] ?? map['message'] ?? map['description']),
      status: asString(map['status']),
      createdAt: DateTime.tryParse(asString(map['createdAt'])),
    );
  }

  bool get canRespond => status.isEmpty || status == 'sent';
}

class ChatMessageModel {
  final String id;
  final String text;
  final String type;
  final String senderId;
  final String senderRole;
  final List<String> images;
  final DateTime? createdAt;
  final bool isMine;

  const ChatMessageModel({
    this.id = '',
    this.text = '',
    this.type = 'text',
    this.senderId = '',
    this.senderRole = '',
    this.images = const [],
    this.createdAt,
    this.isMine = false,
  });

  factory ChatMessageModel.fromJson(dynamic json, {String? myId}) {
    final map = asMap(json);
    // final sender = map['sender'] is Map ? asMap(map['sender']) : map;
    final senderId = asString(
      map['senderId'] ?? map['userId'],
      // sender['_id'] ?? sender['id'] ?? map['senderId'] ?? map['userId'],
    );
    final files = asList(map['files'] ?? map['images'] ?? map['attachments']);
    printState(
      'ChatMessageModel.fromJson: senderId: $senderId, myId: $myId ${myId != null && myId.isNotEmpty && senderId == myId}',
    );
    return ChatMessageModel(
      id: asString(map['_id'] ?? map['id']),
      text: asString(map['text'] ?? map['message'] ?? map['body']),
      type: asString(map['type'], 'text'),
      senderId: senderId,
      senderRole: asString(map['senderRole']),
      images: files
          .map((e) {
            if (e is String) return e;
            return asString(asMap(e)['url'] ?? asMap(e)['path']);
          })
          .where((e) => e.isNotEmpty)
          .toList(),
      createdAt: DateTime.tryParse(asString(map['createdAt'])),
      isMine:
          myId != null &&
          myId.isNotEmpty &&
          senderId.toString() == myId.toString(),
    );
  }
}

class CustomOrderModel {
  final String id;
  final String status;
  final String categoryId;
  final String categoryName;
  final String description;
  final List<String> images;
  final Map<String, dynamic> fields;
  final List<ProposalModel> proposals;
  final DateTime? createdAt;

  const CustomOrderModel({
    this.id = '',
    this.status = 'submitted',
    this.categoryId = '',
    this.categoryName = '',
    this.description = '',
    this.images = const [],
    this.fields = const {},
    this.proposals = const [],
    this.createdAt,
  });

  factory CustomOrderModel.fromJson(dynamic json) {
    final map = asMap(unwrapData(json));
    final files = asList(map['images'] ?? map['files'] ?? map['attachments']);
    final catRaw = map['categoryId'] ?? map['category'];
    final catMap = catRaw is Map ? asMap(catRaw) : <String, dynamic>{};
    return CustomOrderModel(
      id: asString(map['_id'] ?? map['id']),
      status: asString(map['status'], 'submitted'),
      categoryId: catMap.isNotEmpty
          ? asString(catMap['_id'] ?? catMap['id'])
          : asString(catRaw),
      categoryName: catMap.isNotEmpty
          ? localized(catMap['names'] ?? catMap['name'])
          : asString(map['categoryName']),
      description: asString(map['description'] ?? map['notes']),
      images: files
          .map((e) {
            if (e is String) return e;
            return asString(asMap(e)['url'] ?? asMap(e)['path']);
          })
          .where((e) => e.isNotEmpty)
          .toList(),
      fields: asMap(map['fields'] ?? map['customFields']),
      proposals: asList(map['proposals']).map(ProposalModel.fromJson).toList(),
      createdAt: DateTime.tryParse(asString(map['createdAt'])),
    );
  }
}
