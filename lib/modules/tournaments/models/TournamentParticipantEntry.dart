// To parse this JSON data, do
//
//     final tournamentParticipantEntry = tournamentParticipantEntryFromJson(jsonString);

import 'dart:convert';

TournamentParticipantEntry tournamentParticipantEntryFromJson(String str) =>
    TournamentParticipantEntry.fromJson(json.decode(str));

String tournamentParticipantEntryToJson(TournamentParticipantEntry data) =>
    json.encode(data.toJson());

class TournamentParticipantEntry {
  List<TournamentParticipant> tournamentParticipant;

  TournamentParticipantEntry({required this.tournamentParticipant});

  factory TournamentParticipantEntry.fromJson(Map<String, dynamic> json) =>
      TournamentParticipantEntry(
        tournamentParticipant: List<TournamentParticipant>.from(
          json["tournament_participant"].map(
            (x) => TournamentParticipant.fromJson(x),
          ),
        ),
      );

  Map<String, dynamic> toJson() => {
    "tournament_participant": List<dynamic>.from(
      tournamentParticipant.map((x) => x.toJson()),
    ),
  };
}

class TournamentParticipant {
  String id;
  String tournamentId;
  String participantId;
  String status;
  DateTime registeredAt;
  String? teamName;

  TournamentParticipant({
    required this.id,
    required this.tournamentId,
    required this.participantId,
    required this.status,
    required this.registeredAt,
    required this.teamName,
  });

  factory TournamentParticipant.fromJson(Map<String, dynamic> json) =>
      TournamentParticipant(
        id: json["id"] ?? "",
        tournamentId: json["tournament_id"] ?? "",
        participantId: json["participant_id"] ?? "",
        status: json["status"] ?? "",
        registeredAt: DateTime.parse(
          json["registered_at"] ?? DateTime.now().toIso8601String(),
        ),
        teamName: json["team_name"],
      );

  Map<String, dynamic> toJson() => {
    "id": id,
    "tournament_id": tournamentId,
    "participant_id": participantId,
    "status": status,
    "registered_at": registeredAt.toIso8601String(),
    "team_name": teamName,
  };
}
