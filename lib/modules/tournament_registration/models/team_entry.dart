import 'team_member_entry.dart';
import 'package:flutter/material.dart';

class Team {
  String teamId;
  String tournamentId;
  String teamName;
  String status;
  List<TeamMember> members;

  Team({
    required this.teamId,
    required this.tournamentId,
    required this.teamName,
    required this.status,
    required this.members,
  });

  static Team? fromJson(Map<String, dynamic> json) {
    if (json["team_id"] == null ||
        json["tournament_id"] == null ||
        json["team_name"] == null) {
      debugPrint('Json data: $json');
      return null;
    }
    return Team(
      teamId: json["team_id"],
      tournamentId: json["tournament_id"],
      teamName: json["team_name"],
      status: json["status"] ?? "invalid",
      members: TeamMemberListEntry.fromJson(json).teamMembers,
    );
  }

  Map<String, dynamic> toJson() => {
    "team_id": teamId,
    "tournament_id": tournamentId,
    "team_name": teamName,
    "status": status,
    "members": members,
  };
}
