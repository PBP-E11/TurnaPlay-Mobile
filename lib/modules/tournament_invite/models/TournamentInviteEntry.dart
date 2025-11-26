// To parse this JSON data, do
//
//     final tournamentInviteEntry = tournamentInviteEntryFromJson(jsonString);

import 'dart:convert';

TournamentInviteEntry tournamentInviteEntryFromJson(String str) =>
    TournamentInviteEntry.fromJson(json.decode(str));

String tournamentInviteEntryToJson(TournamentInviteEntry data) =>
    json.encode(data.toJson());

class TournamentInviteEntry {
  List<TournamentInvite> tournamentInvites;

  TournamentInviteEntry({required this.tournamentInvites});

  factory TournamentInviteEntry.fromJson(Map<String, dynamic> json) =>
      TournamentInviteEntry(
        tournamentInvites: List<TournamentInvite>.from(
          json["tournament_invites"].map((x) => TournamentInvite.fromJson(x)),
        ),
      );

  Map<String, dynamic> toJson() => {
    "tournament_invites": List<dynamic>.from(
      tournamentInvites.map((x) => x.toJson()),
    ),
  };
}

class TournamentInvite {
  String id;
  int userAccountId;
  String tournamentRegistrationId;
  String status;
  DateTime createdAt;
  DateTime updatedAt;

  TournamentInvite({
    required this.id,
    required this.userAccountId,
    required this.tournamentRegistrationId,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TournamentInvite.fromJson(Map<String, dynamic> json) =>
      TournamentInvite(
        id: json["id"] ?? "",
        userAccountId: json["user_account_id"] ?? 0,
        tournamentRegistrationId: json["tournament_registration_id"] ?? "",
        status: json["status"] ?? "",
        createdAt: DateTime.parse(
          json["created_at"] ?? DateTime.now().toIso8601String(),
        ),
        updatedAt: DateTime.parse(
          json["updated_at"] ?? DateTime.now().toIso8601String(),
        ),
      );

  Map<String, dynamic> toJson() => {
    "id": id,
    "user_account_id": userAccountId,
    "tournament_registration_id": tournamentRegistrationId,
    "status": status,
    "created_at": createdAt.toIso8601String(),
    "updated_at": updatedAt.toIso8601String(),
  };
}
