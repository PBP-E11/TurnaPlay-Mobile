import 'package:flutter/foundation.dart';
import '../models/GameAccountAPI.dart';
import '../models/GameAccountEntry.dart';
import '../../tournaments/models/GameEntry.dart';

class GameAccountController extends ChangeNotifier {
  final GameAccountApi api;

  GameAccountController(this.api) {
    loadAccounts();
    loadGames();
  }

  List<GameAccountEntry> accounts = [];
  bool loading = false;
  String? error;

  Future<void> loadAccounts({String? gameId}) async {
    loading = true;
    error = null;
    notifyListeners();

    try {
      accounts = await api.fetchAccounts(gameId: gameId);
    } catch (e) {
      error = e.toString();
    }

    loading = false;
    notifyListeners();
  }

  Future<void> addAccount(String gameId, String ingameName) async {
    final account = await api.createAccount(
      gameId: gameId,
      ingameName: ingameName,
    );
    accounts.add(account);
    notifyListeners();
  }

  Future<void> deleteAccount(String id) async {
    await api.deleteAccount(id);
    accounts.removeWhere((a) => a.id == id);
    notifyListeners();
  }

  List<Game> games = [];
  bool gamesLoading = false;
  String? gamesError;

  Future<void> loadGames() async {
    gamesLoading = true;
    notifyListeners();

    try {
      final response = await api.fetchGamesRaw(); // see API below

      if (response is List) {
        games = response.map((x) => Game.fromJson(x)).toList();
      } else {
        final entry = GameEntry.fromJson(response);
        games = entry.game;
      }
    } catch (e) {
      error = e.toString();
    }

    gamesLoading = false;
    notifyListeners();
  }
}
