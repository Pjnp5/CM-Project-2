class UserModel {
  String email;
  String name;
  bool dep;

  UserModel({required this.email, required this.name, this.dep = false});

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'name': name,
      'dep': dep,
    };
  }
}
