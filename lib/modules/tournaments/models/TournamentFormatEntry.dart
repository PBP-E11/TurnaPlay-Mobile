// To parse this JSON data, do
//
//     final tournamentFormatEntry = tournamentFormatEntryFromJson(jsonString);

import 'dart:convert';

TournamentFormatEntry tournamentFormatEntryFromJson(String str) =>
    TournamentFormatEntry.fromJson(json.decode(str));

String tournamentFormatEntryToJson(TournamentFormatEntry data) =>
    json.encode(data.toJson());

class TournamentFormatEntry {
  List<TournamentFormat> tournamentFormat;

  TournamentFormatEntry({required this.tournamentFormat});

  factory TournamentFormatEntry.fromJson(Map<String, dynamic> json) =>
      TournamentFormatEntry(
        tournamentFormat: List<TournamentFormat>.from(
          json["tournament_format"].map((x) => TournamentFormat.fromJson(x)),
        ),
      );

  Map<String, dynamic> toJson() => {
    "tournament_format": List<dynamic>.from(
      tournamentFormat.map((x) => x.toJson()),
    ),
  };
}

class TournamentFormat {
  String id;
  String gameId;
  String name;
  int teamSize;

  TournamentFormat({
    required this.id,
    required this.gameId,
    required this.name,
    required this.teamSize,
  });

  factory TournamentFormat.fromJson(Map<String, dynamic> json) =>
      TournamentFormat(
        id: json["id"] ?? "",
        gameId: json["game_id"] ?? "",
        name: json["name"] ?? "",
        teamSize: json["team_size"] ?? 0,
      );

  Map<String, dynamic> toJson() => {
    "id": id,
    "game_id": gameId,
    "name": name,
    "team_size": teamSize,
  };
}
