import 'dart:convert';
import 'package:flutter/material.dart';

TeamMemberListEntry teamMemberEntryFromJson(String str) =>
    TeamMemberListEntry.fromJson(json.decode(str));

String teamMemberEntryToJson(TeamMemberListEntry data) =>
    json.encode(data.toJson());

class TeamMemberListEntry {
  List<TeamMember> teamMembers;

  TeamMemberListEntry({required this.teamMembers});

  factory TeamMemberListEntry.fromJson(Map<String, dynamic> json) =>
      TeamMemberListEntry(
        teamMembers: List<TeamMember>.from(
          json["members"].map((x) => TeamMember.fromJson(x)),
        ),
      );

  Map<String, dynamic> toJson() => {
    "members": List<dynamic>.from(teamMembers.map((x) => x.toJson())),
  };
}

class TeamMember {
  String gameAccountId;
  String teamId;
  bool isLeader;
  String? gameAccountName;
  String? userAccountName;

  TeamMember({
    required this.gameAccountId,
    required this.teamId,
    required this.isLeader,
    this.gameAccountName,
    this.userAccountName,
  });

  static TeamMember? fromJson(Map<String, dynamic> json) {
    if (json["game_account_id"] == null ||
        json["team_id"] == null ||
        json["is_leader"] == null) {
      debugPrint('Json data: $json');
      return null;
    }
    return TeamMember(
      gameAccountId: json["game_account_id"],
      teamId: json["team_id"],
      isLeader: json["is_leader"],
      gameAccountName: json["game_account_name"],
      userAccountName: json["user_account_name"],
    );
  }

  Map<String, dynamic> toJson() => {
    "game_account_id": gameAccountId,
    "team_id": teamId,
    "is_leader": isLeader,
    "game_account_name": gameAccountName,
    "user_account_name": userAccountName,
  };
}
