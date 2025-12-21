import 'dart:convert';

TournamentInviteResponse tournamentInviteResponseFromJson(String str) =>
    TournamentInviteResponse.fromJson(json.decode(str));

String tournamentInviteResponseToJson(TournamentInviteResponse data) =>
    json.encode(data.toJson());

DateTime _parseDate(dynamic value) {
  if (value == null) return DateTime.now();
  final parsed = DateTime.tryParse(value.toString());
  return parsed ?? DateTime.now();
}

class TournamentInviteResponse {
  final bool ok;
  final String? message;
  final List<TournamentInvite> invites;

  TournamentInviteResponse({
    required this.ok,
    required this.invites,
    this.message,
  });

  factory TournamentInviteResponse.fromJson(Map<String, dynamic> json) {
    final invitesJson = (json['invites'] as List?) ?? const [];
    return TournamentInviteResponse(
      ok: json['ok'] == true,
      message: json['message']?.toString(),
      invites: invitesJson
          .whereType<Map<String, dynamic>>()
          .map((e) => TournamentInvite.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'ok': ok,
        'message': message,
        'invites': invites.map((e) => e.toJson()).toList(),
      };
}

class TournamentInvite {
  final String id;
  final String status;
  final DateTime createdAt;
  final TournamentInfo tournament;
  final TeamInfo team;

  TournamentInvite({
    required this.id,
    required this.status,
    required this.createdAt,
    required this.tournament,
    required this.team,
  });

  factory TournamentInvite.fromJson(Map<String, dynamic> json) {
    return TournamentInvite(
      id: json['id']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      createdAt: _parseDate(json['created_at']),
      tournament:
          TournamentInfo.fromJson((json['tournament'] as Map?)?.cast<String, dynamic>() ?? {}),
      team: TeamInfo.fromJson((json['team'] as Map?)?.cast<String, dynamic>() ?? {}),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'status': status,
        'created_at': createdAt.toIso8601String(),
        'tournament': tournament.toJson(),
        'team': team.toJson(),
      };
}

class TournamentInfo {
  final String id;
  final String name;
  final String? game;

  TournamentInfo({
    required this.id,
    required this.name,
    this.game,
  });

  factory TournamentInfo.fromJson(Map<String, dynamic> json) => TournamentInfo(
        id: json['id']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
        game: json['game']?.toString(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'game': game,
      };
}

class TeamInfo {
  final String id;
  final String name;

  TeamInfo({
    required this.id,
    required this.name,
  });

  factory TeamInfo.fromJson(Map<String, dynamic> json) => TeamInfo(
        id: json['id']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
      };
}