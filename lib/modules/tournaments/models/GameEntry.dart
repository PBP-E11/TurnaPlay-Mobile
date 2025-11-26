// To parse this JSON data, do
//
//     final gameEntry = gameEntryFromJson(jsonString);

import 'dart:convert';

GameEntry gameEntryFromJson(String str) => GameEntry.fromJson(json.decode(str));

String gameEntryToJson(GameEntry data) => json.encode(data.toJson());

class GameEntry {
  List<Game> game;

  GameEntry({required this.game});

  factory GameEntry.fromJson(Map<String, dynamic> json) => GameEntry(
    game: List<Game>.from(json["game"].map((x) => Game.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "game": List<dynamic>.from(game.map((x) => x.toJson())),
  };
}

class Game {
  String id;
  String name;

  Game({required this.id, required this.name});

  factory Game.fromJson(Map<String, dynamic> json) =>
      Game(id: json["id"] ?? "", name: json["name"] ?? "");

  Map<String, dynamic> toJson() => {"id": id, "name": name};
}
