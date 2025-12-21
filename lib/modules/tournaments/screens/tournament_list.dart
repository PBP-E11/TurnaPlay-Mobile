import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:turnaplay_mobile/modules/tournaments/models/TournamentEntry.dart';
import 'package:turnaplay_mobile/modules/tournaments/models/GameEntry.dart';
import 'package:turnaplay_mobile/modules/tournaments/models/TournamentFormatEntry.dart';
import 'package:turnaplay_mobile/modules/tournaments/screens/creationForm.dart';
import 'package:turnaplay_mobile/modules/tournaments/widgets/tournament_card.dart';
import 'package:turnaplay_mobile/widgets/navbar.dart'; // Import CustomAppBar
import 'package:turnaplay_mobile/widgets/footer.dart'; // Import footer.dart

class TournamentListScreen extends StatefulWidget {
  const TournamentListScreen({super.key});

  @override
  State<TournamentListScreen> createState() => _TournamentListScreenState();
}

class _TournamentListScreenState extends State<TournamentListScreen> {
  final Color primaryColor = const Color(0xFF494598);
  final ScrollController _scrollController = ScrollController();
  bool _showButton = false;
  final GlobalKey _activeTournamentsKey = GlobalKey();
  int _currentIndex = 0; // State for BottomNavigationBar

  // Pagination State
  List<Tournament> _tournaments = [];
  int _page = 1;
  bool _isLoading = false;
  bool _hasMore = true;

  // Game Filter State
  List<Game> _games = [];
  List<TournamentFormat> _formats = [];
  String? _selectedGameId; // null means "All"

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    // Fetch initial data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchGamesAndFormats();
      _fetchTournaments();
    });
  }

  Future<void> _fetchGamesAndFormats() async {
    final request = context.read<CookieRequest>();

    try {
      // Fetch Games
      final gamesResponse = await request.get(
        'http://localhost:8000/api/tournaments/games/',
      );
      debugPrint("Games Response: $gamesResponse");
      debugPrint("Games Response Type: ${gamesResponse.runtimeType}");

      if (gamesResponse != null) {
        List<Game> fetchedGames = [];
        if (gamesResponse is List) {
          fetchedGames = gamesResponse
              .map((x) => Game.fromJson(x as Map<String, dynamic>))
              .toList();
        } else if (gamesResponse is Map<String, dynamic>) {
          if (gamesResponse.containsKey('game')) {
            fetchedGames = (gamesResponse['game'] as List)
                .map((x) => Game.fromJson(x as Map<String, dynamic>))
                .toList();
          }
        }
        debugPrint("Fetched ${fetchedGames.length} games");

        setState(() {
          _games = fetchedGames;
        });
      }

      // Fetch Formats
      final formatsResponse = await request.get(
        'http://localhost:8000/api/tournaments/formats/',
      );
      debugPrint("Formats Response: $formatsResponse");
      debugPrint("Formats Response Type: ${formatsResponse.runtimeType}");

      if (formatsResponse != null) {
        List<TournamentFormat> fetchedFormats = [];
        if (formatsResponse is List) {
          fetchedFormats = formatsResponse
              .map((x) => TournamentFormat.fromJson(x as Map<String, dynamic>))
              .toList();
        } else if (formatsResponse is Map<String, dynamic>) {
          if (formatsResponse.containsKey('tournament_format')) {
            fetchedFormats = (formatsResponse['tournament_format'] as List)
                .map(
                  (x) => TournamentFormat.fromJson(x as Map<String, dynamic>),
                )
                .toList();
          }
        }
        debugPrint("Fetched ${fetchedFormats.length} formats");

        setState(() {
          _formats = fetchedFormats;
        });
      }
    } catch (e) {
      debugPrint("Error fetching games/formats: $e");
    }
  }

  String? _getGameIdFromFormatId(String formatId) {
    final format = _formats.where((f) => f.id == formatId).toList();
    if (format.isNotEmpty) {
      return format.first.gameId;
    }
    return null;
  }

  List<Tournament> get _filteredTournaments {
    if (_selectedGameId == null) {
      // Show all tournaments when "All" is selected
      return _tournaments;
    }
    return _tournaments.where((tournament) {
      final gameId = _getGameIdFromFormatId(tournament.tournamentFormatId);
      return gameId == _selectedGameId;
    }).toList();
  }

  Future<void> _fetchTournaments() async {
    if (_isLoading || !_hasMore) return;

    setState(() {
      _isLoading = true;
    });

    final request = context.read<CookieRequest>();
    try {
      // Using pbp_django_auth's request.get which returns dynamic (decoded JSON)
      final response = await request.get(
        'http://localhost:8000/api/tournaments/list/?page=$_page',
      );

      // Debug print to check response structure
      debugPrint("Fetch Tournaments Response: $response");

      if (response != null) {
        // Expecting structure: {"tournament": [...], "has_next": true/false}
        // OR standard list if not paginated yet, but we will assume our backend implementation

        List<Tournament> newTournaments = [];
        bool hasNext = false;

        if (response is Map<String, dynamic>) {
          if (response.containsKey('tournament')) {
            newTournaments = List<Tournament>.from(
              response['tournament'].map((x) => Tournament.fromJson(x)),
            );
          }
          if (response.containsKey('has_next')) {
            hasNext = response['has_next'];
          }
        } else if (response is List) {
          // Fallback if backend returns raw list
          newTournaments = response.map((x) => Tournament.fromJson(x)).toList();
          hasNext = false; // Assume no next page if raw list
        }

        setState(() {
          _tournaments.addAll(newTournaments);
          _hasMore = hasNext;
          _page++;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error fetching tournaments: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _scrollListener() {
    // Pagination Logic: Fetch when 200px from bottom
    if (_scrollController.position.extentAfter < 200) {
      _fetchTournaments();
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    if (index == 0) {
      // Already on Home
    } else if (index == 1) {
       // Navigate to Create Tournament
       Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const TournamentCreationForm(),
        ),
      ).then((result) {
         // Reset index to home when coming back
         setState(() {
           _currentIndex = 0;
         });
         
         // If a tournament was created, refresh the list
         if (result == true) {
           setState(() {
             _tournaments.clear();
             _page = 1;
             _hasMore = true;
             _isLoading = false;
           });
           _fetchTournaments();
         }
      });
    } else if (index == 2) {
      // Navigate to ProfileScreen
      Navigator.pushReplacementNamed(
        context,
        '/profile',
      );
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToActiveTournaments() {
    final ctx = _activeTournamentsKey.currentContext;
    if (ctx != null) {
      Scrollable.ensureVisible(
        ctx,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    } else {
      // Fallback: scroll to a reasonable offset
      _scrollController.animateTo(
        400,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5), // Light grey background
      appBar: const Navbar(), // Use Navbar
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 2. Hero Box Section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.black,
                      Color(0xFF2A1639), // Dark purple
                    ],
                  ),
                  image: const DecorationImage(
                    image: NetworkImage(
                      "https://images.unsplash.com/photo-1542751371-adc38448a05e?ixlib=rb-4.0.3&auto=format&fit=crop&w=1170&q=80",
                    ), // Placeholder e-sports image
                    fit: BoxFit.cover,
                    opacity: 0.4,
                  ),
                ),
                child: Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          const Text(
                            "TurnaPlay 2025",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            "The ultimate e-sports showdown of the year.",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              _scrollToActiveTournaments();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor, // Vibrant Purple
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                            ),
                            child: const Text(
                              "Register Now",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 3. Horizontal List of Games
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: const Text(
                "Explore by Game",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  // "All" chip
                  _buildGameChip(
                    "All",
                    _selectedGameId == null,
                    onPressed: () {
                      setState(() {
                        _selectedGameId = null;
                      });
                    },
                  ),
                  // Dynamic game chips
                  ..._games.map((game) {
                    return _buildGameChip(
                      game.name,
                      _selectedGameId == game.id,
                      onPressed: () {
                        setState(() {
                          _selectedGameId = game.id;
                        });
                      },
                    );
                  }),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Active Tournaments Header
            Padding(
              key: _activeTournamentsKey,
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: const Text(
                "Active Tournaments",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),

            // List of Tournaments
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView.builder(
                primary: false, // Using parent scroll controller
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _filteredTournaments.length + (_isLoading ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == _filteredTournaments.length) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }
                  return TournamentCard(
                    tournament: _filteredTournaments[index],
                  );
                },
              ),
            ),

            // Empty State / Error Hint
            if (_filteredTournaments.isEmpty && !_isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Text("No tournaments found for this game."),
                ),
              ),

            const SizedBox(height: 80), // Bottom padding for FAB
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
      ),
    );
  }

  Widget _buildGameChip(
    String label,
    bool isActive, {
    required VoidCallback onPressed,
  }) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isActive ? primaryColor : const Color(0xFFE0D4FC),
          foregroundColor: isActive ? Colors.white : Colors.black87,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
