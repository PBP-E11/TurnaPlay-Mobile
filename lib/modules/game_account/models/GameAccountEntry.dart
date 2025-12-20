// To parse this JSON data, do
//
//     final gameAccountEntry = gameAccountEntryFromJson(jsonString);

import 'dart:convert';

List<GameAccountEntry> gameAccountEntryFromJson(String str) => List<GameAccountEntry>.from(json.decode(str).map((x) => GameAccountEntry.fromJson(x)));

String gameAccountEntryToJson(List<GameAccountEntry> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class GameAccountEntry {
    String id;
    String user;
    String game;
    String gameName;
    String ingameName;
    bool active;

    GameAccountEntry({
        required this.id,
        required this.user,
        required this.game,
        required this.gameName,
        required this.ingameName,
        required this.active,
    });

    factory GameAccountEntry.fromJson(Map<String, dynamic> json) => GameAccountEntry(
        id: json["id"],
        user: json["user"],
        game: json["game"],
        gameName: json["game_name"],
        ingameName: json["ingame_name"],
        active: json["active"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "user": user,
        "game": game,
        "game_name": gameName,
        "ingame_name": ingameName,
        "active": active,
    };
}
