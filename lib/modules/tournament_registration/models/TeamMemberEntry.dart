// To parse this JSON data, do
//
//     final teamMemberEntry = teamMemberEntryFromJson(jsonString);

import 'dart:convert';

TeamMemberEntry teamMemberEntryFromJson(String str) =>
    TeamMemberEntry.fromJson(json.decode(str));

String teamMemberEntryToJson(TeamMemberEntry data) =>
    json.encode(data.toJson());

class TeamMemberEntry {
  List<TeamMember> teamMembers;

  TeamMemberEntry({required this.teamMembers});

  factory TeamMemberEntry.fromJson(Map<String, dynamic> json) =>
      TeamMemberEntry(
        teamMembers: List<TeamMember>.from(
          json["team_members"].map((x) => TeamMember.fromJson(x)),
        ),
      );

  Map<String, dynamic> toJson() => {
    "team_members": List<dynamic>.from(teamMembers.map((x) => x.toJson())),
  };
}

class TeamMember {
  int id;
  String gameAccountId;
  String teamId;
  bool isLeader;

  TeamMember({
    required this.id,
    required this.gameAccountId,
    required this.teamId,
    required this.isLeader,
  });

  factory TeamMember.fromJson(Map<String, dynamic> json) => TeamMember(
    id: json["id"] ?? 0,
    gameAccountId: json["game_account_id"] ?? "",
    teamId: json["team_id"] ?? "",
    isLeader: json["is_leader"] ?? false,
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "game_account_id": gameAccountId,
    "team_id": teamId,
    "is_leader": isLeader,
  };
}
