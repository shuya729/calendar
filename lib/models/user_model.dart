import 'package:cloud_firestore/cloud_firestore.dart';

class UserData {
  final String id;
  final String name;
  final String imageUrl;
  final List<String> freindLidt;

  UserData({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.freindLidt,
  });

  factory UserData.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return UserData(
      id: data['id'],
      name: data['name'],
      imageUrl: data['imageUrl'],
      freindLidt: data['freindLidt'],
    );
  }

  factory UserData.toFireStore(UserData user) {
    return UserData(
      id: user.id,
      name: user.name,
      imageUrl: user.imageUrl,
      freindLidt: user.freindLidt,
    );
  }
}
