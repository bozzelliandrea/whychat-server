import 'package:redis/redis.dart';
import 'package:uuid/uuid.dart';
import 'package:whychat/src/config.dart';

import 'token_pair.dart';
import 'utils.dart';

class TokenService {
  const TokenService(this.db, this.secret);

  final RedisConnection db;
  final String secret;

  static late Command _cache;
  final String _prefix = 'token';

  Future<void> start(String host, int port) async {
    _cache = await db.connect(host, port);
  }

  Future<TokenPair> createTokenPair(String userId) async {
    final tokenId = Uuid().v4();
    final token =
        generateJwt(userId, Config.baseUrl, secret, jwtId: tokenId);

    final refreshTokenExpiry = Duration(seconds: 60);
    final refreshToken = generateJwt(
      userId,
      Config.baseUrl,
      secret,
      jwtId: tokenId,
      expiry: refreshTokenExpiry,
    );

    await addRefreshToken(tokenId, refreshToken, refreshTokenExpiry);

    return TokenPair(token, refreshToken);
  }

  Future<void> addRefreshToken(String id, String token, Duration expiry) async {
    await _cache.send_object(['SET', '$_prefix:$id', token]);
    await _cache.send_object(['EXPIRE', '$_prefix:$id', expiry.inSeconds]);
  }

  Future<dynamic> getRefreshToken(String id) async {
    return await _cache.get('$_prefix:$id');
  }

  Future<void> removeRefreshToken(String id) async {
    await _cache.send_object(['EXPIRE', '$_prefix:$id', '-1']);
  }
}
