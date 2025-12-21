import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:turnaplay_mobile/modules/tournament_registration/models/team_entry.dart';
import '../util.dart';
import '../widgets/whatever.dart';

class EditTeamNameForm extends StatefulWidget {
  final Team team; // passed from previous page
  const EditTeamNameForm({super.key, required this.team});

  @override
  State<EditTeamNameForm> createState() => _EditTeamNameFormState();
}

class _EditTeamNameFormState extends State<EditTeamNameForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _teamNameController = TextEditingController();
  bool _isLoading = false;

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final payload = {
      'team_id': widget.team.teamId,
      'team_name': _teamNameController.text,
    };

    setState(() => _isLoading = true);
    final responseBody = await sendPost(
      context.read(),
      'api/team/update/',
      payload,
    );
    if (responseBody != null && mounted) {
      Navigator.pop(context, _teamNameController.text);
    }
    setState(() => _isLoading = false);
  }

  @override
  void initState() {
    super.initState();
    _teamNameController.text = widget.team.teamName;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator(color: primaryColor));
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Team Name')),
      body: Padding(
        padding: EdgeInsetsGeometry.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildLabel('Team Name'),

              TextFormField(
                controller: _teamNameController,
                decoration: buildInputDecoration('Team Name'),
                validator: (val) => val == null || val.isEmpty
                    ? 'Please enter a team name'
                    : null,
              ),

              buildElevatedButtonText(
                onPressed: _isLoading ? null : _submitForm,
                text: 'Edit Team Name',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
