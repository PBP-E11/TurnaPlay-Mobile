import 'package:flutter/material.dart';

Future<bool?> showConfirmDelete(BuildContext context) {
  return showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text(
        'Delete account',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      content: const Text('Are you sure you want to delete this account?'),
      actionsPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          style: TextButton.styleFrom(foregroundColor: Colors.grey[700]),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(true),
          style: ElevatedButton.styleFrom(
            backgroundColor: Color.fromRGBO(255, 105, 0, 1),
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          child: const Text('Delete'),
        ),
      ],
    ),
  );
}
