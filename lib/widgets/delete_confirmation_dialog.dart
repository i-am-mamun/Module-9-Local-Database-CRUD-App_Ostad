import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class DeleteConfirmationDialog extends StatelessWidget {
  final String contactName;

  const DeleteConfirmationDialog({
    super.key,
    required this.contactName,
  });

  static Future<bool?> show(BuildContext context, String contactName) {
    return showDialog<bool>(
      context: context,
      builder: (context) => DeleteConfirmationDialog(contactName: contactName),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: AppTheme.dangerColor),
          SizedBox(width: 8),
          Text(
            'Delete Contact',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
      content: Text(
        'Are you sure you want to delete "$contactName"? This action cannot be undone.',
        style: const TextStyle(
          color: AppTheme.textSecondary,
          fontSize: 14,
          height: 1.4,
        ),
      ),
      actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text(
            'Cancel',
            style: TextStyle(color: AppTheme.textSecondary),
          ),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.dangerColor,
            foregroundColor: Colors.white,
          ),
          child: const Text('Delete'),
        ),
      ],
    );
  }
}
