// To parse this JSON data, do
//
//     final gameAccountEntry = gameAccountEntryFromJson(jsonString);

import 'dart:convert';
import 'dart:io';
import 'package:pbp_django_auth/pbp_django_auth.dart';

GameAccountEntry gameAccountEntryFromJson(String str) =>
    GameAccountEntry.fromJson(json.decode(str));

String gameAccountEntryToJson(GameAccountEntry data) =>
    json.encode(data.toJson());

class GameAccountEntry {
  List<GameAccount> gameAccounts;

  GameAccountEntry({required this.gameAccounts});

  factory GameAccountEntry.fromJson(Map<String, dynamic> json) =>
      GameAccountEntry(
        gameAccounts: List<GameAccount>.from(
          json["game_accounts"].map((x) => GameAccount.fromJson(x)),
        ),
      );

  Map<String, dynamic> toJson() => {
    "game_accounts": List<dynamic>.from(gameAccounts.map((x) => x.toJson())),
  };
}

class GameAccount {
  String id;
  int userId;
  int gameId;
  String ingameName;
  bool active;

  GameAccount({
    required this.id,
    required this.userId,
    required this.gameId,
    required this.ingameName,
    required this.active,
  });

  factory GameAccount.fromJson(Map<String, dynamic> json) => GameAccount(
    id: json["id"] ?? "",
    userId: json["user_id"] ?? 0,
    gameId: json["game_id"] ?? 0,
    ingameName: json["ingame_name"] ?? "",
    active: json["active"] ?? false,
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "user_id": userId,
    "game_id": gameId,
    "ingame_name": ingameName,
    "active": active,
  };
}

class GameAccountService {
  static const String _base = 'http://localhost:8000/api/game-accounts';
  static const String _listUrl =
      '$_base/'; // GET -> list (supports ?game=<id>) POST -> create
  static const String _createUrl = '$_base/';
  static String detailUrl(String uuid) =>
      '$_base/$uuid/'; // GET/PUT/PATCH/DELETE detail

  // Fetch list of game accounts. Accepts either a raw list response or wrapped `{count, results}`.
  // Returns List<GameAccount>
  static Future<String?> create(
    dynamic request, {
    required String gameId,
    required String ingameName,
  }) async {
    final payload = {'game': gameId, 'ingame_name': ingameName};

    dynamic resp;
    try {
      resp = await request.post(_createUrl, payload);
    } catch (e) {
      // Tangani FormatException (JSON kosong) atau error jaringan
      if (e is FormatException) {
        // coba fallback menggunakan HttpClient untuk dapatkan status code
        return await _fallbackPost(_createUrl, payload);
      }
      return 'Request failed: $e';
    }

    // Jika request.post mengembalikan string kosong atau non-json, coba fallback
    if (resp is String && resp.trim().isEmpty) {
      return await _fallbackPost(_createUrl, payload);
    }

    if (resp == null) return 'No response from server';

    // backend returns created object (with id or game) or status 201 handled by pbp_django_auth returning map
    if (resp is Map &&
        (resp.containsKey('id') ||
            resp.containsKey('game') ||
            resp.containsKey('ingame_name'))) {
      return null; // no error
    }
    // If backend returns 'detail' message
    if (resp is Map && resp.containsKey('detail')) {
      final detail = resp['detail']?.toString() ?? 'Unknown error';
      // Map DB constraint to user read message
      if (detail.toLowerCase().contains('already exists') ||
          detail.toLowerCase().contains('duplicate')) {
        return 'Account with that in-game name already exists for this game.';
      }
      return detail;
    }

    // If backend returns form errors structure
    if (resp is Map && resp.containsKey('errors')) {
      final errors = resp['errors'];
      if (errors is Map) {
        // join first field messages
        final first = errors.entries.first;
        final fval = first.value;
        if (fval is List && fval.isNotEmpty) return fval.join(' ');
        return fval.toString();
      }
    }

    // Fallback: return message
    final s = resp.toString();
    if (s.toLowerCase().contains('already exists') ||
        s.toLowerCase().contains('duplicate')) {
      return 'Account with that in-game name already exists for this game.';
    }

    return 'Failed to create account';
  }

  // fallback raw HTTP POST to inspect status code/body when automatic decode fails
  static Future<String?> _fallbackPost(String url, Map payload) async {
    try {
      final client = HttpClient();
      final req = await client.postUrl(Uri.parse(url));
      req.headers.set(
        HttpHeaders.contentTypeHeader,
        'application/json; charset=UTF-8',
      );
      req.add(utf8.encode(json.encode(payload)));
      final res = await req.close();
      final body = await res.transform(utf8.decoder).join();
      client.close();

      if (res.statusCode >= 200 && res.statusCode < 300) {
        return null; // treat success
      }

      // if body is empty, try infer from status code
      if (body.trim().isEmpty) {
        if (res.statusCode == 409) {
          return 'Account with that in-game name already exists for this game.';
        }
        return 'Server returned status ${res.statusCode}';
      }

      // try parse JSON body
      dynamic j;
      try {
        j = json.decode(body);
      } catch (_) {
        j = body;
      }

      if (j is Map && j.containsKey('detail')) {
        final detail = j['detail']?.toString() ?? 'Unknown error';
        if (detail.toLowerCase().contains('already exists') ||
            detail.toLowerCase().contains('duplicate')) {
          return 'Account with that in-game name already exists for this game.';
        }
        return detail;
      }

      if (j is Map && j.containsKey('errors')) {
        final errors = j['errors'];
        if (errors is Map) {
          final first = errors.entries.first;
          final fval = first.value;
          if (fval is List && fval.isNotEmpty) return fval.join(' ');
          return fval.toString();
        }
      }

      final s = j.toString();
      if (s.toLowerCase().contains('already exists') ||
          s.toLowerCase().contains('duplicate')) {
        return 'Account with that in-game name already exists for this game.';
      }

      return 'Request failed: ${res.statusCode} - ${body.length > 300 ? body.substring(0, 300) : body}';
    } catch (e) {
      return 'Fallback request failed: $e';
    }
  }
}
