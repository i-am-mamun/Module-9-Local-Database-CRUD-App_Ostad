import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../database/database_helper.dart';
import '../models/contact.dart';
import '../theme/app_theme.dart';
import '../widgets/delete_confirmation_dialog.dart';
import 'add_edit_contact_screen.dart';

class ContactDetailsScreen extends StatefulWidget {
  final Contact contact;

  const ContactDetailsScreen({super.key, required this.contact});

  @override
  State<ContactDetailsScreen> createState() => _ContactDetailsScreenState();
}

class _ContactDetailsScreenState extends State<ContactDetailsScreen> {
  late Contact _contact;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _contact = widget.contact;
  }

  Future<void> _refreshContact() async {
    if (_contact.id == null) return;
    setState(() => _isLoading = true);
    final updated = await DatabaseHelper.instance.getContactById(_contact.id!);
    if (mounted) {
      if (updated != null) {
        setState(() {
          _contact = updated;
          _isLoading = false;
        });
      } else {
        // Contact was deleted elsewhere
        Navigator.of(context).pop(true);
      }
    }
  }

  Future<void> _toggleFavorite() async {
    if (_contact.id == null) return;
    final newStatus = !_contact.isFavorite;
    await DatabaseHelper.instance.toggleFavorite(_contact.id!, newStatus);
    setState(() {
      _contact = _contact.copyWith(isFavorite: newStatus);
    });

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          newStatus
              ? 'Added ${_contact.name} to favorites'
              : 'Removed ${_contact.name} from favorites',
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _deleteContact() async {
    final confirmed = await DeleteConfirmationDialog.show(context, _contact.name);
    if (confirmed == true && mounted) {
      if (_contact.id != null) {
        await DatabaseHelper.instance.deleteContact(_contact.id!);
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Contact "${_contact.name}" deleted'),
          backgroundColor: AppTheme.dangerColor,
        ),
      );
      Navigator.of(context).pop(true);
    }
  }

  Future<void> _navigateToEdit() async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => AddEditContactScreen(contact: _contact),
      ),
    );
    if (result == true) {
      await _refreshContact();
    }
  }

  void _copyToClipboard(String label, String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label copied to clipboard'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  String _getInitials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts[0].isEmpty) return '?';
    if (parts.length == 1) {
      return parts[0].substring(0, parts[0].length >= 2 ? 2 : 1).toUpperCase();
    }
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final avatarColor = AppTheme.getAvatarColor(_contact.name);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Contact Details'),
        actions: [
          IconButton(
            icon: Icon(
              _contact.isFavorite ? Icons.star_rounded : Icons.star_outline_rounded,
              color: _contact.isFavorite ? AppTheme.favoriteColor : AppTheme.textSecondary,
              size: 26,
            ),
            tooltip: _contact.isFavorite ? 'Remove favorite' : 'Add favorite',
            onPressed: _toggleFavorite,
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit contact',
            onPressed: _navigateToEdit,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppTheme.dangerColor),
            tooltip: 'Delete contact',
            onPressed: _deleteContact,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: Column(
                  children: [
                    // Profile Header Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppTheme.borderColor),
                      ),
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 48,
                            backgroundColor: avatarColor.withValues(alpha: 0.15),
                            child: Text(
                              _getInitials(_contact.name),
                              style: TextStyle(
                                color: avatarColor,
                                fontWeight: FontWeight.w700,
                                fontSize: 34,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _contact.name,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryLight,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  'ID: ${_contact.id ?? "N/A"}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.primaryColor,
                                  ),
                                ),
                              ),
                              if (_contact.isFavorite) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppTheme.favoriteColor.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.star_rounded, size: 14, color: AppTheme.favoriteColor),
                                      SizedBox(width: 4),
                                      Text(
                                        'Favorite',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: AppTheme.favoriteColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Information Section Header
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'CONTACT INFORMATION',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Phone Tile
                    _buildInfoCard(
                      icon: Icons.phone_outlined,
                      label: 'Phone Number',
                      value: _contact.phone,
                      onCopy: () => _copyToClipboard('Phone number', _contact.phone),
                    ),
                    const SizedBox(height: 10),

                    // Email Tile
                    _buildInfoCard(
                      icon: Icons.email_outlined,
                      label: 'Email Address',
                      value: _contact.email,
                      onCopy: () => _copyToClipboard('Email address', _contact.email),
                    ),
                    const SizedBox(height: 10),

                    // Address Tile
                    _buildInfoCard(
                      icon: Icons.location_on_outlined,
                      label: 'Address',
                      value: _contact.address,
                      onCopy: () => _copyToClipboard('Address', _contact.address),
                    ),
                    const SizedBox(height: 24),

                    // Action Buttons (Edit & Delete)
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _navigateToEdit,
                            icon: const Icon(Icons.edit_outlined, size: 18),
                            label: const Text('Edit Contact'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _deleteContact,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.dangerColor,
                              foregroundColor: Colors.white,
                            ),
                            icon: const Icon(Icons.delete_outline, size: 18),
                            label: const Text('Delete'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
    required VoidCallback onCopy,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.primaryLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppTheme.primaryColor, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.copy_rounded, size: 18, color: AppTheme.textSecondary),
            tooltip: 'Copy',
            onPressed: onCopy,
          ),
        ],
      ),
    );
  }
}
