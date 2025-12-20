// To parse this JSON data, do
//
//     final gameAccountEntry = gameAccountEntryFromJson(jsonString);

import 'dart:convert';

List<GameAccountEntry> gameAccountEntryFromJson(String str) => List<GameAccountEntry>.from(json.decode(str).map((x) => GameAccountEntry.fromJson(x)));

String gameAccountEntryToJson(List<GameAccountEntry> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class GameAccountEntry {
    final String id;
    final String? user;
    final String? game;
    final String? gameName;
    final String ingameName;
    final bool active;


    GameAccountEntry({
        required this.id,
        this.user,
        this.game,
        this.gameName,
        required this.ingameName,
        required this.active,
    });

    factory GameAccountEntry.fromJson(Map<String, dynamic> json) => GameAccountEntry(
        id: json["id"].toString(),
        user: json["user"]?.toString(),
        game: json["game"]?.toString(),
        gameName: json["game_name"]?.toString(),
        ingameName: json["ingame_name"] ?? '',
        active: json["active"] ?? true,
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
