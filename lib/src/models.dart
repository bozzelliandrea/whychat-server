class User {
  final String name;
  final String email;

  User(this.name, this.email);

  User.fromJson(Map<String, dynamic> json)
      : name = json['name'],
        email = json['email'];

  Map<String, dynamic> toJson() => {
        'name': name,
        'email': email,
      };
}

class Auth {
  final String? name;
  final String email;
  final String password;

  Auth(this.name, this.email, this.password);

  Auth.login(this.email, this.password) : name = null;

  Auth.fromJson(Map<String, dynamic> json)
      : name = json['name'],
        email = json['email'],
        password = json['password'];

  Map<String, dynamic> toJson() =>
      {'name': name, 'email': email, 'password': password};
}
