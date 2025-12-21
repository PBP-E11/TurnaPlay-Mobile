// To parse this JSON data, do
//
//     final tournamentEntry = tournamentEntryFromJson(jsonString);

import 'dart:convert';

TournamentEntry tournamentEntryFromJson(String str) =>
    TournamentEntry.fromJson(json.decode(str));

String tournamentEntryToJson(TournamentEntry data) =>
    json.encode(data.toJson());

class TournamentEntry {
  List<Tournament> tournament;

  TournamentEntry({required this.tournament});

  factory TournamentEntry.fromJson(Map<String, dynamic> json) =>
      TournamentEntry(
        tournament: List<Tournament>.from(
          json["tournament"].map((x) => Tournament.fromJson(x)),
        ),
      );

  Map<String, dynamic> toJson() => {
    "tournament": List<dynamic>.from(tournament.map((x) => x.toJson())),
  };
}

class Tournament {
  String id;
  String organizerId;
  String tournamentFormatId;
  String tournamentName;
  String description;
  DateTime tournamentDate;
  int prizePool;
  String? banner;
  int teamMaximumCount;
  DateTime createdAt;
  DateTime updatedAt;
  bool isActive;
  String status;
  int participantsCount;
  String? game;
  String? organizerName;
  String? tournamentFormatName;
  String? gameId;
  String? gameName;

  Tournament({
    required this.id,
    required this.organizerId,
    required this.tournamentFormatId,
    required this.tournamentName,
    required this.description,
    required this.tournamentDate,
    required this.prizePool,
    required this.banner,
    required this.teamMaximumCount,
    required this.createdAt,
    required this.updatedAt,
    required this.isActive,
    required this.status,
    required this.participantsCount,
    this.game,
    this.organizerName,
    this.tournamentFormatName,
    this.gameId,
    this.gameName,
  });

  factory Tournament.fromJson(Map<String, dynamic> json) => Tournament(
    id: json["id"] ?? "",
    organizerId: json["organizer_id"] ?? "",
    tournamentFormatId: json["tournament_format_id"] ?? "",
    tournamentName: json["tournament_name"] ?? "",
    description: json["description"] ?? "",
    tournamentDate: DateTime.parse(
      json["tournament_date"] ?? DateTime.now().toIso8601String(),
    ),
    prizePool: json["prize_pool"] ?? 0,
    banner: json["banner"],
    teamMaximumCount: json["team_maximum_count"] ?? 0,
    createdAt: DateTime.parse(
      json["created_at"] ?? DateTime.now().toIso8601String(),
    ),
    updatedAt: DateTime.parse(
      json["updated_at"] ?? DateTime.now().toIso8601String(),
    ),
    isActive: json["is_active"] ?? false,
    status: json["status"] ?? "",
    participantsCount: json["participants_count"] ?? 0,
    game: json["game"],
    organizerName: json["organizer"],
    tournamentFormatName: json["tournament_format_name"],
    gameId: json["game_id"],
    gameName: json["game_name"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "organizer_id": organizerId,
    "tournament_format_id": tournamentFormatId,
    "tournament_name": tournamentName,
    "description": description,
    "tournament_date":
        "${tournamentDate.year.toString().padLeft(4, '0')}-${tournamentDate.month.toString().padLeft(2, '0')}-${tournamentDate.day.toString().padLeft(2, '0')}",
    "prize_pool": prizePool,
    "banner": banner,
    "team_maximum_count": teamMaximumCount,
    "created_at": createdAt.toIso8601String(),
    "updated_at": updatedAt.toIso8601String(),
    "is_active": isActive,
    "status": status,
    "participants_count": participantsCount,
    "game": game,
    "organizer": organizerName,
    "tournament_format_name": tournamentFormatName,
    "game_id": gameId,
    "game_name": gameName,
  };
}
