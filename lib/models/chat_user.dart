import 'package:cloud_firestore/cloud_firestore.dart';

class ChatUser {
  final String id;
  final String name;
  final String profileImage;
  final bool isOnline;
  final DateTime lastSeen;

  ChatUser({
    required this.id,
    required this.name,
    required this.profileImage,
    required this.isOnline,
    required this.lastSeen,
  });

  factory ChatUser.fromFirestore(Map<String, dynamic> data, String id) {
    return ChatUser(
      id: id,
      name: data['name'] ?? '',
      profileImage: data['profileImage'] ?? 'images/pp.jpg', // Default or actual image
      isOnline: data['isOnline'] ?? false,
      lastSeen: data['lastSeen']?.toDate() ?? DateTime.now(),
    );
  }

  // Create from AppUser
  factory ChatUser.fromAppUser(AppUser appUser) {
    return ChatUser(
      id: appUser.id,
      name: appUser.name,
      profileImage: appUser.profileImage,
      isOnline: appUser.isOnline,
      lastSeen: appUser.lastSeen,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'profileImage': profileImage,
      'isOnline': isOnline,
      'lastSeen': lastSeen,
    };
  }
}

// AppUser class (now the single source of truth)
class AppUser {
  final String id;
  final String name;
  final String email;
  final String userType; // 'client' or 'delivery'
  final String profileImage;
  final DateTime createdAt;
  final bool isOnline;
  final DateTime lastSeen;

  AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.userType,
    required this.profileImage,
    required this.createdAt,
    required this.isOnline,
    required this.lastSeen,
  });

  factory AppUser.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AppUser(
      id: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      userType: data['userType'] ?? 'client',
      profileImage: data['profileImage'] ?? 'images/pp.jpg', // Ensure this is correctly set
      createdAt: data['createdAt']?.toDate() ?? DateTime.now(),
      isOnline: data['isOnline'] ?? false,
      lastSeen: data['lastSeen']?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'email': email,
      'userType': userType,
      'profileImage': profileImage,
      'createdAt': Timestamp.fromDate(createdAt),
      'isOnline': isOnline,
      'lastSeen': Timestamp.fromDate(lastSeen),
    };
  }

  // Convert to ChatUser for compatibility
  ChatUser toChatUser() {
    return ChatUser.fromAppUser(this);
  }
}
