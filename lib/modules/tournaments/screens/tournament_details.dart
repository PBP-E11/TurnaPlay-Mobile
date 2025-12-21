import 'package:flutter/material.dart';
import 'package:turnaplay_mobile/modules/tournament_registration/screens/create_team_form.dart';
import 'package:turnaplay_mobile/modules/tournaments/models/TournamentEntry.dart';

class TournamentDetails extends StatelessWidget {
  final Tournament tournament;

  const TournamentDetails({super.key, required this.tournament});

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Turnamen')),
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
                  SizedBox(height: 20),
                  Text(
                    tournament.description,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 20),
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
    return Center(
      child: SizedBox(
        width: 200,
        height: 40,
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CreateTeamForm(tournament: tournament),
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
            "Daftar",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ),
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
