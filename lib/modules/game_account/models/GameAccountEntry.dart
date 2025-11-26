// To parse this JSON data, do
//
//     final gameAccountEntry = gameAccountEntryFromJson(jsonString);

import 'dart:convert';

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
