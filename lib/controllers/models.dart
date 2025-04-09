import 'package:cloud_firestore/cloud_firestore.dart';

class SwapRequestModel {
  SwapRequestModel({
    required this.requestId,
    required this.userId,
    required this.skillsNeeded,
    required this.skillsOffering,
    required this.createdOn,
    required this.status,
    required this.message,
    this.comments,
    this.unread = 0,
    this.counter = false,
  });
  String requestId;
  String userId;
  List skillsNeeded;
  List skillsOffering;
  Timestamp createdOn;
  String status;
  String message;
  List? comments;
  int unread;
  bool counter;

  static SwapRequestModel fromJson(Map json) {
    return SwapRequestModel(
      requestId: json['requestId'] ?? "",
      userId: json['userId'] ?? "",
      skillsNeeded: json['skillsNeeded'] ?? [],
      skillsOffering: json['skillsOffering'] ?? [],
      createdOn: json['createdOn'] ?? Timestamp.now(),
      status: json['status'] ?? "",
      message: json['message'] ?? "",
      comments: json['comments'] ?? [],
      unread: json['unread'] ?? 0,
      counter: json['counter'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "requestId": requestId,
      "userId": userId,
      "skillsNeeded": skillsNeeded,
      "skillsOffering": skillsOffering,
      "createdOn": createdOn,
      "status": status,
      "message": message,
      'comments': comments,
      'unread': unread,
      'counter': counter,
    };
  }

  SwapRequestModel copyWith({
    String? requestId,
    String? userId,
    List? skillsNeeded,
    List? skillsOffering,
    Timestamp? createdOn,
    String? status,
    String? message,
    List? comments,
    int? unread,
    bool? counter,
  }) {
    return SwapRequestModel(
      requestId: requestId ?? this.requestId,
      userId: userId ?? this.userId,
      skillsNeeded: skillsNeeded ?? this.skillsNeeded,
      skillsOffering: skillsOffering ?? this.skillsOffering,
      createdOn: createdOn ?? this.createdOn,
      status: status ?? this.status,
      message: message ?? this.message,
      comments: comments ?? this.comments,
      unread: unread ?? this.unread,
      counter: counter ?? this.counter,
    );
  }
}

class SwapModel {
  SwapModel({
    required this.id,
    required this.userId,
    required this.skillsNeeded,
    required this.skillsOffering,
    required this.createdOn,
    this.completed = false,
    this.completedByMe = false,
  });
  String id;
  String userId;
  List skillsNeeded;
  List skillsOffering;
  Timestamp createdOn;
  bool completed;
  bool completedByMe;

  static SwapModel fromJson(Map json) {
    return SwapModel(
      id: json['id'],
      userId: json["userId"],
      skillsNeeded: json["skillsNeeded"],
      skillsOffering: json["skillsOffering"],
      createdOn: json["createdOn"],
      completed: json["completed"],
      completedByMe: json["completedByMe"],
    );
  }

  Map toJson() {
    return {
      "userId": userId,
      "skillsNeeded": skillsNeeded,
      "skillsOffering": skillsOffering,
      "createdOn": createdOn,
      "completed": completed,
      "completedByMe": completedByMe,
      'id': id,
    };
  }

  SwapModel copyWith({
    String? userId,
    List? skillsNeeded,
    List? skillsOffering,
    Timestamp? createdOn,
    bool? completed,
    bool? completedByMe,
  }) {
    return SwapModel(
      id: id,
      userId: userId ?? this.userId,
      skillsNeeded: skillsNeeded ?? this.skillsNeeded,
      skillsOffering: skillsOffering ?? this.skillsOffering,
      createdOn: createdOn ?? this.createdOn,
      completed: completed ?? this.completed,
      completedByMe: completedByMe ?? this.completedByMe,
    );
  }
}
