import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import './utils.dart';
import 'models.dart';

class UserApi {
  DbCollection store;

  UserApi(this.store);

  Handler get router {
    final router = Router();

    router.get('/', (Request req) async {
      final authDetails = req.context['authDetails'] as JWT;
      final user = await store.findOne(
          where.eq('_id', ObjectId.fromHexString(authDetails.subject!)));

      return Response.ok(User(user!['name'], user['email']!).toJson(),
          headers: {
            'content-type': 'application/json',
          });
    });

    final handler =
        Pipeline().addMiddleware(checkAuthorisation()).addHandler(router);

    return handler;
  }
}
