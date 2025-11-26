// To parse this JSON data, do
//
//     final tournamentRegistEntry = tournamentRegistEntryFromJson(jsonString);

import 'dart:convert';

TournamentRegistEntry tournamentRegistEntryFromJson(String str) =>
    TournamentRegistEntry.fromJson(json.decode(str));

String tournamentRegistEntryToJson(TournamentRegistEntry data) =>
    json.encode(data.toJson());

class TournamentRegistEntry {
  List<TournamentRegistration> tournamentRegistrations;

  TournamentRegistEntry({required this.tournamentRegistrations});

  factory TournamentRegistEntry.fromJson(Map<String, dynamic> json) =>
      TournamentRegistEntry(
        tournamentRegistrations: List<TournamentRegistration>.from(
          json["tournament_registrations"].map(
            (x) => TournamentRegistration.fromJson(x),
          ),
        ),
      );

  Map<String, dynamic> toJson() => {
    "tournament_registrations": List<dynamic>.from(
      tournamentRegistrations.map((x) => x.toJson()),
    ),
  };
}

class TournamentRegistration {
  String id;
  int tournamentId;
  String teamName;
  String status;

  TournamentRegistration({
    required this.id,
    required this.tournamentId,
    required this.teamName,
    required this.status,
  });

  factory TournamentRegistration.fromJson(Map<String, dynamic> json) =>
      TournamentRegistration(
        id: json["id"] ?? "",
        tournamentId: json["tournament_id"] ?? 0,
        teamName: json["team_name"] ?? "",
        status: json["status"] ?? "",
      );

  Map<String, dynamic> toJson() => {
    "id": id,
    "tournament_id": tournamentId,
    "team_name": teamName,
    "status": status,
  };
}
