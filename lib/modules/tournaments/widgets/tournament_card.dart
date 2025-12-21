import 'package:flutter/material.dart';
import 'package:turnaplay_mobile/modules/tournaments/models/TournamentEntry.dart';
import 'package:turnaplay_mobile/modules/tournament_registration/screens/create_team_form.dart';
import 'package:turnaplay_mobile/modules/tournaments/screens/tournament_details.dart';

class TournamentCard extends StatelessWidget {
  final Tournament tournament;
  final VoidCallback? onUpdate;

  const TournamentCard({super.key, required this.tournament, this.onUpdate});

  String _formatDate(DateTime date) {
    const List<String> months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return "${date.day} ${months[date.month - 1]} ${date.year}";
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

  @override
  Widget build(BuildContext context) {
    // Format date: "15 Oct 2024"
    final dateString = _formatDate(tournament.tournamentDate);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 24.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image Section
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Image.network(
                tournament.banner ?? "https://images.unsplash.com/photo-1542751371-adc38448a05e?auto=format&fit=crop&w=1170&q=80", // Fallback
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[300],
                    child: const Center(child: Icon(Icons.broken_image, color: Colors.grey)),
                  );
                },
              ),
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title and Status
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        tournament.tournamentName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getStatusBackgroundColor(tournament.status),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: _getStatusColor(tournament.status),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            tournament.status,
                            style: TextStyle(
                              color: _getStatusColor(tournament.status),
                              fontWeight: FontWeight.w600,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                
                // Date
                Text(
                  dateString, // e.g., "15 Oct 2024"
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 16),
                
                // Buttons
                Row(
                  children: [
                    // Detail Button
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  TournamentDetails(tournament: tournament),
                            ),
                          ).then((result) {
                            if (result == true) {
                              onUpdate?.call();
                            }
                          });
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF494598),
                          side: const BorderSide(color: Color(0xFF494598)), // Purple Border
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text("Detail", style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                    if (tournament.status.toLowerCase() != 'selesai') ...[
                      const SizedBox(width: 12),
                      // Daftar (Register) Button
                      Expanded(
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
                          child: const Text("Daftar", style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
