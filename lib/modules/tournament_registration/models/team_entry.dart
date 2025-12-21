import 'team_member_entry.dart';
import 'package:flutter/material.dart';

class Team {
  String teamId;
  String tournamentId;
  String teamName;
  String status;
  String userId;
  bool isUserLeader;
  bool isUserInTeam;
  List<TeamMember> members;

  Team({
    required this.teamId,
    required this.tournamentId,
    required this.teamName,
    required this.status,
    required this.userId,
    required this.isUserLeader,
    required this.isUserInTeam,
    required this.members,
  });

  static Team? fromJson(Map<String, dynamic> json) {
    if (json["team_id"] == null ||
        json["tournament_id"] == null ||
        json["team_name"] == null ||
        json["user_id"] == null ||
        json["is_user_leader"] == null ||
        json["is_user_in_team"] == null ||
        json["members"] == null) {
      debugPrint('Json data: $json');
      return null;
    }
    return Team(
      teamId: json["team_id"],
      tournamentId: json["tournament_id"],
      teamName: json["team_name"],
      userId: json["user_id"],
      isUserLeader: json["is_user_leader"],
      isUserInTeam: json["is_user_in_team"],
      status: json["status"] ?? "invalid",
      members: TeamMemberListEntry.fromJson(json).teamMembers,
    );
  }

  Map<String, dynamic> toJson() => {
    "team_id": teamId,
    "tournament_id": tournamentId,
    "team_name": teamName,
    "user_id": userId,
    "status": status,
    "is_user_leader": isUserLeader,
    "is_user_in_team": isUserInTeam,
    "members": members,
  };
}
