import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:turnaplay_mobile/modules/tournaments/models/TournamentEntry.dart';
import 'package:turnaplay_mobile/modules/tournaments/models/TournamentFormatEntry.dart';
import 'package:turnaplay_mobile/modules/tournaments/models/GameEntry.dart';
import 'package:turnaplay_mobile/modules/tournaments/screens/tournament_list.dart';
import 'package:turnaplay_mobile/settings.dart';

class TournamentForm extends StatefulWidget {
  final Tournament? tournament;

  const TournamentForm({super.key, this.tournament});

  @override
  State<TournamentForm> createState() => _TournamentFormState();
}

class _TournamentFormState extends State<TournamentForm> {
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
  final Color primaryColor = const Color(0xFF494598);

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    final request = context.read<CookieRequest>();
    try {
      // Fetch Games
      final gamesResponse = await request.get('$HOST/api/tournaments/games/');

      // Fetch Formats
      final formatsResponse = await request.get(
        '$HOST/api/tournaments/formats/',
      );

      if (!mounted) return;

      setState(() {
        if (gamesResponse != null) {
          if (gamesResponse is List) {
            _games = gamesResponse.map((x) => Game.fromJson(x)).toList();
          } else {
            final gameEntry = GameEntry.fromJson(gamesResponse);
            _games = gameEntry.game;
          }
        }

        if (formatsResponse != null) {
          if (formatsResponse is List) {
            _formats = formatsResponse
                .map((x) => TournamentFormat.fromJson(x))
                .toList();
          } else {
            final formatEntry = TournamentFormatEntry.fromJson(formatsResponse);
            _formats = formatEntry.tournamentFormat;
          }
        }

        // Initialize for Edit Mode
        if (widget.tournament != null) {
          final t = widget.tournament!;
          _tournamentName = t.tournamentName;
          _description = t.description;
          _tournamentDate = t.tournamentDate;
          _prizePool = t.prizePool;
          _banner = t.banner ?? "";
          _teamMaximumCount = t.teamMaximumCount;
          
          // Set Game and Format
          // We need gameId. If not in tournament object directly, we might need to find it via format
          if (t.gameId != null) {
             _selectedGameId = t.gameId;
             _filterFormats(_selectedGameId!, updateState: false);
             _selectedFormatId = t.tournamentFormatId;
          } else {
             // Try to find format to get gameId if needed
             try {
                final format = _formats.firstWhere((f) => f.id == t.tournamentFormatId);
                _selectedGameId = format.gameId;
                 _filterFormats(_selectedGameId!, updateState: false);
                _selectedFormatId = t.tournamentFormatId;
             } catch (e) {
                // Format not found
             }
          }
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

  void _filterFormats(String gameId, {bool updateState = true}) {
    final filtered = _formats
          .where((format) => format.gameId == gameId)
          .toList();
    
    if (updateState) {
        setState(() {
        _selectedGameId = gameId;
        _selectedFormatId = null; // Reset selected format
        _filteredFormats = filtered;
        });
    } else {
        _filteredFormats = filtered;
    }
  }

  InputDecoration _buildInputDecoration(
    String hintText, {
    Widget? prefixIcon,
    BoxConstraints? prefixIconConstraints,
    Widget? prefix,
    String? prefixText,
    TextStyle? prefixStyle,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(color: Colors.grey),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: primaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.red),
      ),
      prefixIcon: prefixIcon,
      prefixIconConstraints: prefixIconConstraints,
      prefix: prefix,
      prefixText: prefixText,
      prefixStyle: prefixStyle,
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, top: 4.0),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    final isEdit = widget.tournament != null;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          isEdit ? 'Edit Tournament' : 'Create Tournament',
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: primaryColor))
          : Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Game Dropdown
                    _buildLabel('Game'),
                    DropdownButtonFormField<String>(
                      decoration: _buildInputDecoration('Select a game'),
                      value: _selectedGameId,
                      icon: const Icon(Icons.keyboard_arrow_down),
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
                    _buildLabel('Tournament Format'),
                    DropdownButtonFormField<String>(
                      decoration: _buildInputDecoration('Choose Game First'),
                      value: _selectedFormatId,
                      icon: const Icon(Icons.keyboard_arrow_down),
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
                    _buildLabel('Tournament Name'),
                    TextFormField(
                      initialValue: _tournamentName,
                      style: const TextStyle(color: Colors.black),
                      decoration: _buildInputDecoration(
                        'e.g. Winter Championship 2025',
                      ),
                      onChanged: (String? value) {
                         _tournamentName = value!;
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
                    _buildLabel('Description'),
                    TextFormField(
                      initialValue: _description,
                      style: const TextStyle(color: Colors.black),
                      decoration: _buildInputDecoration(
                        'Brief details about the event...',
                      ),
                      maxLines: 4,
                      onChanged: (String? value) {
                         _description = value!;
                      },
                      validator: (String? value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter description';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // 5. Start Date
                    _buildLabel('Start Date'),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _tournamentDate == null
                                ? 'No Date Chosen'
                                : "${_tournamentDate!.toLocal()}".split(' ')[0],
                            style: TextStyle(
                              color: _tournamentDate == null
                                  ? Colors.grey
                                  : Colors.black,
                              fontSize: 16,
                            ),
                          ),
                          TextButton(
                            onPressed: () async {
                              final DateTime? picked = await showDatePicker(
                                context: context,
                                initialDate: _tournamentDate ?? DateTime.now(),
                                firstDate: DateTime.now(),
                                lastDate: DateTime(2101),
                                builder: (context, child) {
                                  return Theme(
                                    data: Theme.of(context).copyWith(
                                      colorScheme: ColorScheme.light(
                                        primary: primaryColor,
                                      ),
                                    ),
                                    child: child!,
                                  );
                                },
                              );
                              if (picked != null && picked != _tournamentDate) {
                                setState(() {
                                  _tournamentDate = picked;
                                });
                              }
                            },
                            style: TextButton.styleFrom(
                              foregroundColor: primaryColor,
                              side: BorderSide(color: primaryColor),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text('Select Date'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 6. Prize Pool
                    _buildLabel('Prize Pool'),
                    TextFormField(
                      initialValue: _prizePool == 0 ? null : _prizePool.toString(),
                      style: const TextStyle(color: Colors.black),
                      decoration: _buildInputDecoration(
                        '0',
                        prefixIcon: const Padding(
                          padding: EdgeInsets.only(left: 16, right: 8),
                          child: Text(
                            "Rp",
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        prefixIconConstraints: const BoxConstraints(
                          minWidth: 0,
                          minHeight: 0,
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (String? value) {
                          _prizePool = int.tryParse(value!) ?? 0;
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
                    _buildLabel('Banner URL'),
                    TextFormField(
                      initialValue: _banner,
                      style: const TextStyle(color: Colors.black),
                      decoration: _buildInputDecoration(
                        'example.com/image.png',
                        prefixIcon: const Padding(
                          padding: EdgeInsets.only(left: 16, right: 4),
                          child: Text(
                            "https://",
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                        prefixIconConstraints: const BoxConstraints(
                          minWidth: 0,
                          minHeight: 0,
                        ),
                      ),
                      onChanged: (String? value) {
                          _banner = value!;
                      },
                    ),
                    const SizedBox(height: 16),

                    // 8. Max Team Count
                    _buildLabel('Max Team Count'),
                    TextFormField(
                      initialValue: _teamMaximumCount.toString(),
                      style: const TextStyle(color: Colors.black),
                      decoration: _buildInputDecoration('e.g. 16'),
                      keyboardType: TextInputType.number,
                      onChanged: (String? value) {
                          _teamMaximumCount = int.tryParse(value!) ?? 1;
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
                    const SizedBox(height: 32),

                    // Create/Edit Button
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
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

                            final url = isEdit
                                ? "http://localhost:8000/api/tournaments/edit-tournament/${widget.tournament!.id}/"
                                : "http://localhost:8000/api/tournaments/create-tournament/";
                            
                            final response = await request.post(
                              "$HOST/api/tournaments/create-tournament/",
                              {
                                'tournament_name': _tournamentName,
                                'description': _description,
                                'tournament_date':
                                    "${_tournamentDate!.year}-${_tournamentDate!.month.toString().padLeft(2, '0')}-${_tournamentDate!.day.toString().padLeft(2, '0')}",
                                'prize_pool': _prizePool.toString(),
                                'banner': _banner,
                                'team_maximum_count': _teamMaximumCount
                                    .toString(),
                                'tournament_format': _selectedFormatId,
                              },
                            );

                            if (context.mounted) {
                              if (response['status'] == 'success') {
                                ScaffoldMessenger.of(context).showSnackBar(
                                   SnackBar(
                                    content: Text(
                                      isEdit ? "Tournament updated successfully!" : "Tournament created successfully!",
                                    ),
                                  ),
                                );
                                Navigator.pop(context, true);
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      response['message'] ??
                                          (isEdit ? "Failed to update tournament" : "Failed to create tournament"),
                                    ),
                                  ),
                                );
                              }
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 2,
                        ),
                        child: Text(
                          isEdit ? 'Save Changes' : 'Create Tournament',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
    );
  }
}
