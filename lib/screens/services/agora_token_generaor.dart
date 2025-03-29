import 'dart:convert';
import 'package:crypto/crypto.dart';

class AgoraTokenGenerator {
  static String generateToken({
    required String appId,
    required String appCertificate,
    required String channelName,
    required int uid,
    int expirationSeconds = 3600, // 1 hour
  }) {
    final int timestamp =
        (DateTime.now().millisecondsSinceEpoch ~/ 1000) + expirationSeconds;
    final String message = "$appId$channelName$uid$timestamp";

    var key = utf8.encode(appCertificate);
    var bytes = utf8.encode(message);

    var hmacSha256 = Hmac(sha256, key);
    var digest = hmacSha256.convert(bytes);

    return "$appId:$digest:$timestamp";
  }
}
