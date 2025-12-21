import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:turnaplay_mobile/modules/tournament_registration/models/team_entry.dart';
import '../util.dart';

class EditTeamNameForm extends StatefulWidget {
  final Team team; // passed from previous page
  const EditTeamNameForm({super.key, required this.team});

  @override
  State<EditTeamNameForm> createState() => _EditTeamNameFormState();
}

class _EditTeamNameFormState extends State<EditTeamNameForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _teamNameController = TextEditingController();
  bool _isSubmitting = false;

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final payload = {
      'team_id': widget.team.teamId,
      'team_name': _teamNameController.text,
    };

    setState(() => _isSubmitting = true);
    final responseBody = await sendPost(
      context.read(),
      'api/team/update/',
      payload,
    );
    if (responseBody != null && mounted) {
      Navigator.pop(context, _teamNameController.text);
    }
    setState(() => _isSubmitting = false);
  }

  @override
  void initState() {
    super.initState();
    _teamNameController.text = widget.team.teamName;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Team')),
      body: Padding(
        padding: EdgeInsetsGeometry.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Team name
              TextFormField(
                controller: _teamNameController,
                decoration: const InputDecoration(labelText: 'Team Name'),
                validator: (val) => val == null || val.isEmpty
                    ? 'Please enter a team name'
                    : null,
              ),
              const SizedBox(height: 24),
              // Submit button
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submitForm,
                child: _isSubmitting
                    ? const CircularProgressIndicator()
                    : const Text('Edit Team Name'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
