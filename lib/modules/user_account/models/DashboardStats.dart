class DashboardStats {
  final int totalUsers;
  final int userCount;
  final int organizerCount;
  final int adminCount;

  DashboardStats({
    required this.totalUsers,
    required this.userCount,
    required this.organizerCount,
    required this.adminCount,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      totalUsers: json['total_users'] ?? 0,
      userCount: json['users_by_role']['user'] ?? 0,
      organizerCount: json['users_by_role']['organizer'] ?? 0,
      adminCount: json['users_by_role']['admin'] ?? 0,
    );
  }
}
