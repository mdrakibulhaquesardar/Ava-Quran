import 'package:nylo_framework/nylo_framework.dart';

class User extends Model {
  String? id;
  String? name;
  String? email;
  String? avatar;
  String? quranId;
  int followersCount = 0;
  int followingCount = 0;
  int currentStreak = 0;

  static final StorageKey key = 'user';

  User() : super(key: key);

  User.fromJson(dynamic data) {
    id = data['id'];
    name = data['name'];
    email = data['email'];
    avatar = data['avatar'];
    quranId = data['quranId'];
    followersCount = data['followersCount'] ?? 0;
    followingCount = data['followingCount'] ?? 0;
    
    // Parse nested streak object if available
    if (data['streak'] != null) {
      currentStreak = data['streak']['currentStreak'] ?? 0;
    }
  }

  @override
  toJson() => {
    "id": id,
    "name": name, 
    "email": email, 
    "avatar": avatar,
    "followersCount": followersCount,
    "followingCount": followingCount,
    "currentStreak": currentStreak,
  };
}
