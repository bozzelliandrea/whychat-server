import 'package:mongo_dart/mongo_dart.dart';
import 'package:redis/redis.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:whychat/src/auth_api.dart';
import 'package:whychat/src/config.dart';
import 'package:whychat/src/token_service.dart';
import 'package:whychat/src/user_api.dart';
import 'package:whychat/src/utils.dart';

void main(List<String> args) async {
  await Config.init();

  final Db mongodb = Db(Config.mongoURI);
  await mongodb.open();
  final DbCollection usersDb = mongodb.collection('users');
  print('WhyChat: MongoDB connected');

  final TokenService tokenService = TokenService(RedisConnection(), Config.jwtKey);
  await tokenService.start(Config.redisHost, Config.redisPort);
  print('WhyChat: Cache connected');

  final Router app = Router();
  app.mount('/auth/', AuthApi(usersDb, Config.jwtKey, tokenService).router);
  app.mount('/user/', UserApi(usersDb).router);

  final handler = Pipeline()
      .addMiddleware(logRequests())
      .addMiddleware(handleCors())
      .addMiddleware(handleAuth(Config.jwtKey))
      .addHandler(app);

  await serve(handler, Config.url, Config.port);
  print('WhyChat: Server ready and listening on ${Config.baseUrl}');
}
