import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:turnaplay_mobile/modules/tournaments/models/TournamentEntry.dart';
import 'package:turnaplay_mobile/modules/tournaments/widgets/tournament_card.dart';
import 'package:turnaplay_mobile/settings.dart';

class TournamentSearchScreen extends StatefulWidget {
  const TournamentSearchScreen({super.key});

  @override
  State<TournamentSearchScreen> createState() => _TournamentSearchScreenState();
}

class _TournamentSearchScreenState extends State<TournamentSearchScreen> {
  final Color primaryColor = const Color(0xFF494598);
  final TextEditingController _searchController = TextEditingController();

  List<Tournament> _searchResults = [];
  bool _isLoading = false;
  bool _hasSearched = false;
  String? _errorMessage;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _searchTournaments(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _hasSearched = false;
        _errorMessage = null;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final request = context.read<CookieRequest>();

    try {
      final response = await request.get(
        '$HOST/api/tournaments/search/?q=${Uri.encodeComponent(query.trim())}',
      );

      debugPrint("Search Response: $response");

      if (response != null) {
        List<Tournament> results = [];

        if (response is Map<String, dynamic>) {
          if (response.containsKey('tournaments')) {
            results = List<Tournament>.from(
              response['tournaments'].map((x) => Tournament.fromJson(x)),
            );
          } else if (response.containsKey('tournament')) {
            // Fallback for alternative key
            results = List<Tournament>.from(
              response['tournament'].map((x) => Tournament.fromJson(x)),
            );
          }
        } else if (response is List) {
          results = response.map((x) => Tournament.fromJson(x)).toList();
        }

        if (context.mounted) {
          setState(() {
            _searchResults = results;
            _isLoading = false;
            _hasSearched = true;
          });
        }
      } else {
        if (context.mounted) {
          setState(() {
            _searchResults = [];
            _isLoading = false;
            _hasSearched = true;
          });
        }
      }
    } catch (e) {
      debugPrint("Error searching tournaments: $e");
      if (context.mounted) {
        setState(() {
          _isLoading = false;
          _hasSearched = true;
          _errorMessage = "Failed to search tournaments. Please try again.";
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F5F5),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Search tournament name...',
            hintStyle: TextStyle(color: Colors.grey[500]),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
          ),
          style: const TextStyle(color: Colors.black, fontSize: 16),
          textInputAction: TextInputAction.search,
          onSubmitted: _searchTournaments,
          onChanged: (value) {
            // Optionally implement debounced live search
            // For now, we search on submit only
          },
        ),
        actions: [
          if (_searchController.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear, color: Colors.black54),
              onPressed: () {
                _searchController.clear();
                setState(() {
                  _searchResults = [];
                  _hasSearched = false;
                  _errorMessage = null;
                });
              },
            ),
          IconButton(
            icon: Icon(Icons.search, color: primaryColor),
            onPressed: () => _searchTournaments(_searchController.text),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600], fontSize: 16),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => _searchTournaments(_searchController.text),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (!_hasSearched) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.search, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                'Search for tournaments by name',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600], fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }

    if (_searchResults.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                'No tournaments found for "${_searchController.text}"',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600], fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        return TournamentCard(
          tournament: _searchResults[index],
          onUpdate: () => _searchTournaments(_searchController.text),
        );
      },
    );
  }
}
