import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/GameAccountEntry.dart';
import '../../tournaments/models/GameEntry.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';

class GameAccountApi {
  final CookieRequest request;

  GameAccountApi(this.request);

  Future<List<GameAccountEntry>> fetchAccounts({String? gameId}) async {
    final url = gameId == null
        ? 'http://localhost:8000/api/game-accounts/'
        : 'http://localhost:8000/api/game-accounts/?game=$gameId';

    final response = await request.get(url);
    return (response as List).map((e) => GameAccountEntry.fromJson(e)).toList();
  }

  Future<GameAccountEntry> createAccount({
    required String gameId,
    required String ingameName,
  }) async {
    final response = await request.postJson(
      'http://localhost:8000/api/game-accounts/',
      jsonEncode({'game': gameId, 'ingame_name': ingameName}),
    );

    return GameAccountEntry.fromJson(response);
  }

  Future<GameAccountEntry> updateAccount({
    required String id,
    required String gameId,
    required String ingameName,
  }) async {
    final response = await request.postJson(
      'http://localhost:8000/api/game-accounts/$id/',
      jsonEncode({
        '_method': 'PATCH',
        'game': gameId,
        'ingame_name': ingameName,
      }),
    );

    return GameAccountEntry.fromJson(response);
  }

  Future<void> deleteAccount(String id) async {
    await request.postJson(
      'http://localhost:8000/api/game-accounts/$id/',
      jsonEncode({'_method': 'DELETE'}),
    );
  }

  Future<dynamic> fetchGamesRaw() async {
    return await request.get('http://localhost:8000/api/tournaments/games/');
  }
}
