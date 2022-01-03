import 'package:dotenv/dotenv.dart' show load, env;

abstract class Config {
  // server config
  static int get port => int.tryParse(env['PORT'] ?? "8080")!;
  static String get url => env['URL']!;
  static String get baseUrl => env['PROTOCOL']! + '://' + env['URL']!;
  static String get jwtKey => env['JWT_KEY']!;
  // mongo db config
  static String get mongoURI => env['MONGO_URI']!;
  // redis config
  static String get redisHost => env['REDIS_HOST']!;
  static int get redisPort => int.tryParse(env['PORT'] ?? "6666")!;

  static init() async {
    return load('.env.chat');
  }
}
