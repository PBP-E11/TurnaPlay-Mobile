import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:turnaplay_mobile/modules/tournaments/models/TournamentEntry.dart';
import 'package:turnaplay_mobile/modules/tournaments/screens/creationForm.dart';
import 'package:turnaplay_mobile/modules/tournaments/widgets/tournament_card.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final Color primaryColor = const Color(0xFF494598);
  final ScrollController _scrollController = ScrollController();
  bool _showButton = false;

  // Pagination State
  List<Tournament> _tournaments = [];
  int _page = 1;
  bool _isLoading = false;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    // Fetch initial data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchTournaments();
    });
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
    // FAB Logic
    if (_scrollController.offset > 100 && !_showButton) {
      setState(() {
        _showButton = true;
      });
    } else if (_scrollController.offset <= 100 && _showButton) {
      setState(() {
        _showButton = false;
      });
    }

    // Pagination Logic: Fetch when 200px from bottom
    if (_scrollController.position.extentAfter < 200) {
      _fetchTournaments();
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5), // Light grey background
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F5F5),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.search, color: Colors.black, size: 28),
          onPressed: () {},
        ),
        title: const Text(
          'TurnaPlay',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.account_circle_outlined,
              color: Colors.black,
              size: 28,
            ),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
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
                            onPressed: () {},
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
                  _buildGameChip("Mobile Legends", true),
                  _buildGameChip("PUBG", false),
                  _buildGameChip("Valorant", false),
                  _buildGameChip("Free Fire", false),
                  _buildGameChip("Dota 2", false),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Active Tournaments Header
            Padding(
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
                itemCount: _tournaments.length + (_isLoading ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == _tournaments.length) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }
                  return TournamentCard(tournament: _tournaments[index]);
                },
              ),
            ),

            // Empty State / Error Hint
            if (_tournaments.isEmpty && !_isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Text("No active tournaments found."),
                ),
              ),

            const SizedBox(height: 80), // Bottom padding for FAB
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: _showButton
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const TournamentCreationForm(),
                  ),
                );
              },
              backgroundColor: primaryColor,
              label: const Text(
                'Create Tournament',
                style: TextStyle(color: Colors.white),
              ),
              icon: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }

  Widget _buildGameChip(String label, bool isActive) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      child: ElevatedButton(
        onPressed: () {},
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
