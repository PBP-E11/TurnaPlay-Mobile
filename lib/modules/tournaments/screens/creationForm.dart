import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:turnaplay_mobile/modules/tournaments/models/TournamentFormatEntry.dart';
import 'package:turnaplay_mobile/modules/tournaments/models/GameEntry.dart';

class TournamentCreationForm extends StatefulWidget {
  const TournamentCreationForm({super.key});

  @override
  State<TournamentCreationForm> createState() => _TournamentCreationFormState();
}

class _TournamentCreationFormState extends State<TournamentCreationForm> {
  final _formKey = GlobalKey<FormState>();

  String _tournamentName = "";
  String _description = "";
  DateTime? _tournamentDate;
  int _prizePool = 0;
  String _banner = "";
  int _teamMaximumCount = 1;
  String? _selectedFormatId;
  String? _selectedGameId;

  List<TournamentFormat> _formats = [];
  List<TournamentFormat> _filteredFormats = [];
  List<Game> _games = [];
  
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    final request = context.read<CookieRequest>();
    try {
      // Fetch Games
      final gamesResponse = await request.get(
        'http://127.0.0.1:8000/tournaments/api/games/',
      );
      
      // Fetch Formats
      final formatsResponse = await request.get(
        'http://127.0.0.1:8000/tournaments/api/formats/',
      );

      setState(() {
        if (gamesResponse != null) {
          final gameEntry = GameEntry.fromJson(gamesResponse);
          _games = gameEntry.game;
        }

        if (formatsResponse != null) {
          final formatEntry = TournamentFormatEntry.fromJson(formatsResponse);
          _formats = formatEntry.tournamentFormat;
        }
        
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Error fetching data: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _filterFormats(String gameId) {
    setState(() {
      _selectedGameId = gameId;
      _selectedFormatId = null; // Reset selected format
      _filteredFormats = _formats.where((format) => format.gameId == gameId).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return Scaffold(
      appBar: AppBar(title: const Text('Create Tournament')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Game Dropdown
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Game',
                        border: OutlineInputBorder(),
                      ),
                      value: _selectedGameId,
                      items: _games.map((Game game) {
                        return DropdownMenuItem<String>(
                          value: game.id,
                          child: Text(game.name),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          _filterFormats(newValue);
                        }
                      },
                      validator: (String? value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a game';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // 2. Tournament Format Dropdown
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Tournament Format',
                        border: OutlineInputBorder(),
                      ),
                      value: _selectedFormatId,
                      items: _filteredFormats.map((TournamentFormat format) {
                        return DropdownMenuItem<String>(
                          value: format.id,
                          child: Text(format.name),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedFormatId = newValue;
                        });
                      },
                      validator: (String? value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a format';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // 3. Tournament Name
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Tournament Name',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (String? value) {
                        setState(() {
                          _tournamentName = value!;
                        });
                      },
                      validator: (String? value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter tournament name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // 4. Description
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                      onChanged: (String? value) {
                        setState(() {
                          _description = value!;
                        });
                      },
                      validator: (String? value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter description';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // 5. Date Picker
                    Row(
                      children: [
                        Text(
                          _tournamentDate == null
                              ? 'No Date Chosen'
                              : "${_tournamentDate!.toLocal()}".split(' ')[0],
                        ),
                        const SizedBox(width: 20),
                        ElevatedButton(
                          onPressed: () async {
                            final DateTime? picked = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime.now(),
                              lastDate: DateTime(2101),
                            );
                            if (picked != null && picked != _tournamentDate) {
                              setState(() {
                                _tournamentDate = picked;
                              });
                            }
                          },
                          child: const Text('Select Date'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // 6. Prize Pool
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Prize Pool',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (String? value) {
                        setState(() {
                          _prizePool = int.tryParse(value!) ?? 0;
                        });
                      },
                      validator: (String? value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter prize pool';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // 7. Banner URL
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Banner URL',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (String? value) {
                        setState(() {
                          _banner = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    // 8. Max Team Count
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Max Team Count',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (String? value) {
                        setState(() {
                          _teamMaximumCount = int.tryParse(value!) ?? 1;
                        });
                      },
                      validator: (String? value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter max team count';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          if (_tournamentDate == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Please select a date"),
                              ),
                            );
                            return;
                          }

                          final response = await request.postJson(
                            "http://127.0.0.1:8000/tournaments/create-flutter/",
                            <String, dynamic>{
                              'tournament_name': _tournamentName,
                              'description': _description,
                              'tournament_date':
                                  "${_tournamentDate!.year}-${_tournamentDate!.month.toString().padLeft(2, '0')}-${_tournamentDate!.day.toString().padLeft(2, '0')}",
                              'prize_pool': _prizePool,
                              'banner': _banner,
                              'team_maximum_count': _teamMaximumCount,
                              'tournament_format': _selectedFormatId,
                            },
                          );

                          if (context.mounted) {
                            if (response['status'] == 'success') {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    "Tournament created successfully!",
                                  ),
                                ),
                              );
                              Navigator.pop(context);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    response['message'] ??
                                        "Failed to create tournament",
                                  ),
                                ),
                              );
                            }
                          }
                        }
                      },
                      child: const Text('Create Tournament'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}