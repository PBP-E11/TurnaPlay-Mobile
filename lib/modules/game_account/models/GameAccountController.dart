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
    await api.createAccount(
      gameId: gameId,
      ingameName: ingameName,
    );
    await loadAccounts(gameId: selectedGameId);
  }

  Future<GameAccountEntry> updateAccount({
    required String id,
    required String gameId,
    required String ingameName,
  }) async {
    final updated = await api.updateAccount(
      id: id,
      gameId: gameId,
      ingameName: ingameName,
    );

    final index = accounts.indexWhere((a) => a.id == id);
    if (index != -1) {
      accounts[index] = updated;
      notifyListeners();
    }

    return updated;
  }

  Future<void> deleteAccount(String id) async {
    await api.deleteAccount(id);
    accounts.removeWhere((a) => a.id == id);
    notifyListeners();
  }

  String? selectedGameId; // null = All
  void setGameFilter(String? gameId) {
    selectedGameId = gameId;
    loadAccounts();
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
