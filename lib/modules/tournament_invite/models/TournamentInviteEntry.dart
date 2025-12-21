import 'dart:convert';

TournamentInviteResponse tournamentInviteResponseFromJson(String str) =>
    TournamentInviteResponse.fromJson(json.decode(str));

String tournamentInviteResponseToJson(TournamentInviteResponse data) =>
    json.encode(data.toJson());

class TournamentInviteResponse {
  final bool ok;
  final List<TournamentInvite> invites;

  TournamentInviteResponse({
    required this.ok,
    required this.invites,
  });

  factory TournamentInviteResponse.fromJson(Map<String, dynamic> json) {
    final invitesJson = (json['invites'] as List?) ?? const [];
    return TournamentInviteResponse(
      ok: json['ok'] == true,
      invites: invitesJson
          .map((e) => TournamentInvite.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'ok': ok,
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
      id: (json['id'] ?? '') as String,
      status: (json['status'] ?? '') as String,
      createdAt: DateTime.parse(
        (json['created_at'] ?? DateTime.now().toIso8601String()) as String,
      ),
      tournament:
          TournamentInfo.fromJson((json['tournament'] ?? {}) as Map<String, dynamic>),
      team: TeamInfo.fromJson((json['team'] ?? {}) as Map<String, dynamic>),
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
    required this.game,
  });

  factory TournamentInfo.fromJson(Map<String, dynamic> json) => TournamentInfo(
        id: (json['id'] ?? '') as String,
        name: (json['name'] ?? '') as String,
        game: json['game'] as String?,
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
        id: (json['id'] ?? '') as String,
        name: (json['name'] ?? '') as String,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
      };
}