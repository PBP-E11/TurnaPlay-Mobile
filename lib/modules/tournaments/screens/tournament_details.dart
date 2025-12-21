import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:turnaplay_mobile/modules/tournament_registration/screens/create_team_form.dart';
import 'package:turnaplay_mobile/modules/tournaments/models/TournamentEntry.dart';
import 'package:turnaplay_mobile/modules/tournaments/screens/creationForm.dart';
import 'package:turnaplay_mobile/providers/user_provider.dart';

import 'package:turnaplay_mobile/widgets/base_screen.dart';

class TournamentDetails extends StatelessWidget {
  final Tournament tournament;

  const TournamentDetails({super.key, required this.tournament});

  void _onItemTapped(BuildContext context, int index) {
    if (index == 0) {
      Navigator.pushReplacementNamed(context, '/home');
    } else if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const TournamentForm()),
      );
    } else if (index == 2) {
      Navigator.pushReplacementNamed(context, '/profile');
    }
  }

  String _formatDate(DateTime date) {
    const List<String> months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return "${date.day} ${months[date.month - 1]} ${date.year}";
  }

  Future<void> _deleteTournament(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Tournament'),
        content: const Text('Are you sure you want to delete this tournament?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      final request = context.read<CookieRequest>();
      try {
        final response = await request.post(
          "http://localhost:8000/api/tournaments/delete-tournament/${tournament.id}/",
          {},
        );

        if (context.mounted) {
          if (response['status'] == 'success') {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Tournament deleted successfully!")),
            );
            Navigator.pop(context, true); // Return true to signal update
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(
                      response['message'] ?? "Failed to delete tournament")),
            );
          }
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error: $e")),
          );
        }
      }
    }
  }

  Future<void> _editTournament(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TournamentForm(tournament: tournament),
      ),
    );

    if (result == true && context.mounted) {
      Navigator.pop(context, true); // Return true to signal update
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      initialIndex: 0,
      onTap: (index) => _onItemTapped(context, index),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImage(context),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context),
                  const SizedBox(height: 20),
                  Text(
                    tournament.description,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildButtons(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage(BuildContext _) {
    return ClipRRect(
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Image.network(
          tournament.banner ??
              "https://images.unsplash.com/photo-1542751371-adc38448a05e?auto=format&fit=crop&w=1170&q=80", // Fallback
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: Colors.grey[300],
              child: const Center(
                child: Icon(Icons.broken_image, color: Colors.grey),
              ),
            );
          },
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'ongoing':
        return Colors.green;
      case 'selesai':
        return Colors.red;
      default:
        return Colors.black;
    }
  }

  Color _getStatusBackgroundColor(String status) {
    switch (status.toLowerCase()) {
      case 'ongoing':
        return Colors.green.withOpacity(0.1);
      case 'selesai':
        return Colors.red.withOpacity(0.1);
      default:
        return Colors.grey.withOpacity(0.1);
    }
  }

  Widget _buildHeader(BuildContext _) {
    // Format date: "15 Oct 2024"
    final dateString = _formatDate(tournament.tournamentDate);
    return Column(
      children: [
        Center(
          child: Text(
            tournament.tournamentName,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _getStatusBackgroundColor(tournament.status),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _getStatusColor(tournament.status),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  tournament.status,
                  style: TextStyle(
                    color: _getStatusColor(tournament.status),
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Date
        Text(
          dateString, // e.g., "15 Oct 2024"
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
        const SizedBox(height: 16),

        _buildInfoCard(
          icon: Icons.bolt,
          label: "Format",
          value: "Competitive 5v5",
        ),
        const SizedBox(height: 8),
        _buildInfoCard(
          icon: Icons.monetization_on,
          label: "Total Prize Pool",
          value: "Rp 10.000.000",
        ),
        const SizedBox(height: 8),
        _buildInfoCard(
          icon: Icons.group,
          label: "Slot terbatas",
          value: "20 tim",
        ),
      ],
    );
  }

  Widget _buildButtons(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final bool canEdit = userProvider.isAdmin ||
        (userProvider.role == 'admin') ||
        (userProvider.id == tournament.organizerId);

    return Column(
      children: [
        if (canEdit)
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () => _deleteTournament(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.withOpacity(0.1),
                    foregroundColor: Colors.red,
                    elevation: 0,
                    side: const BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                  ),
                  child: const Text("Delete Tournament"),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () => _editTournament(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF494598).withOpacity(0.1),
                    foregroundColor: const Color(0xFF494598),
                    elevation: 0,
                    side: const BorderSide(color: Color(0xFF494598)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                  ),
                  child: const Text("Edit Tournament"),
                ),
              ],
            ),
          ),
        if (tournament.status.toLowerCase() != 'selesai')
          Center(
            child: SizedBox(
              width: 200,
              height: 40,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          CreateTeamForm(tournament: tournament),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF494598), // Purple
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text(
                  "Register Now",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, size: 28, color: const Color(0xFF494598)),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
