import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/GameAccountEntry.dart';
import '../../tournaments/models/GameEntry.dart';

class GameAccountApi {
  final String baseUrl;

  GameAccountApi(this.baseUrl);

  Future<List<GameAccountEntry>> fetchAccounts({String? gameId}) async {
    final uri = Uri.parse(
      gameId == null
          ? '$baseUrl/api/game-accounts/'
          : '$baseUrl/api/game-accounts/?game=$gameId',
    );

    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch accounts');
    }

    return gameAccountEntryFromJson(response.body);
  }

  Future<GameAccountEntry> createAccount({
    required String gameId,
    required String ingameName,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/game-accounts/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'game': gameId, 'ingame_name': ingameName}),
    );

    if (response.statusCode != 201) {
      throw Exception(
        'Failed to create account '
        '[${response.statusCode}]: ${response.body}',
      );
    }

    return GameAccountEntry.fromJson(jsonDecode(response.body));
  }

  Future<void> deleteAccount(String id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/api/game-accounts/$id/'),
    );

    if (response.statusCode != 204) {
      throw Exception('Failed to delete account');
    }
  }

  Future<dynamic> fetchGamesRaw() async {
    final response =
        await http.get(Uri.parse('$baseUrl/api/tournaments/games/'));

    if (response.statusCode != 200) {
      throw Exception('Failed to load games');
    }

    return jsonDecode(response.body);
  }
}
