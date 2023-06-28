import 'package:cloud_firestore/cloud_firestore.dart';

class UserData {
  final String id;
  final String name;
  final String imageUrl;
  final List<String?> friendList;

  UserData({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.friendList,
  });

  factory UserData.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return UserData(
      id: data['id'] ?? '',
      name: data['name'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      friendList:
          data['friendList'] is Iterable ? List.from(data['friendList']) : [],
    );
  }

  factory UserData.toFireStore(UserData user) {
    return UserData(
      id: user.id,
      name: user.name,
      imageUrl: user.imageUrl,
      friendList: user.friendList,
    );
  }

  UserData empty() {
    return UserData(
      id: '',
      name: '',
      imageUrl: '',
      friendList: [],
    );
  }
}
