import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/contact.dart';
import '../theme/app_theme.dart';
import '../widgets/contact_card.dart';
import '../widgets/delete_confirmation_dialog.dart';
import '../widgets/empty_state.dart';
import 'add_edit_contact_screen.dart';
import 'contact_details_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Contact> _contacts = [];
  bool _isLoading = true;
  bool _showFavoritesOnly = false;
  int _totalCount = 0;
  int _favoritesCount = 0;

  @override
  void initState() {
    super.initState();
    _loadContacts();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    _filterContacts();
  }

  Future<void> _loadContacts() async {
    setState(() => _isLoading = true);

    final all = await DatabaseHelper.instance.getAllContacts();
    final favs = await DatabaseHelper.instance.getFavoriteContacts();

    if (!mounted) return;

    _totalCount = all.length;
    _favoritesCount = favs.length;

    await _filterContacts();
  }

  Future<void> _filterContacts() async {
    final query = _searchController.text.trim();
    List<Contact> result;

    if (query.isEmpty) {
      if (_showFavoritesOnly) {
        result = await DatabaseHelper.instance.getFavoriteContacts();
      } else {
        result = await DatabaseHelper.instance.getAllContacts();
      }
    } else {
      result = await DatabaseHelper.instance.searchContacts(
        query,
        favoritesOnly: _showFavoritesOnly,
      );
    }

    if (!mounted) return;
    setState(() {
      _contacts = result;
      _isLoading = false;
    });
  }

  Future<void> _toggleFavorite(Contact contact) async {
    if (contact.id == null) return;
    final newStatus = !contact.isFavorite;
    await DatabaseHelper.instance.toggleFavorite(contact.id!, newStatus);
    await _loadContacts();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          newStatus
              ? 'Added "${contact.name}" to favorites'
              : 'Removed "${contact.name}" from favorites',
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _deleteContact(Contact contact) async {
    final confirmed = await DeleteConfirmationDialog.show(context, contact.name);
    if (confirmed == true && mounted) {
      if (contact.id != null) {
        await DatabaseHelper.instance.deleteContact(contact.id!);
      }
      await _loadContacts();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Contact "${contact.name}" deleted'),
          backgroundColor: AppTheme.dangerColor,
        ),
      );
    }
  }

  Future<void> _navigateToAddContact() async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => const AddEditContactScreen(),
      ),
    );
    if (result == true) {
      await _loadContacts();
    }
  }

  Future<void> _navigateToEditContact(Contact contact) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => AddEditContactScreen(contact: contact),
      ),
    );
    if (result == true) {
      await _loadContacts();
    }
  }

  Future<void> _navigateToDetails(Contact contact) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => ContactDetailsScreen(contact: contact),
      ),
    );
    if (result == true) {
      await _loadContacts();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.contacts_rounded, color: AppTheme.primaryColor),
            SizedBox(width: 10),
            Text('Contacts'),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search Bar & Filter Row
            Container(
              color: AppTheme.surfaceColor,
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
              child: Column(
                children: [
                  // Search TextField
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search contacts by name...',
                      prefixIcon: const Icon(Icons.search, color: AppTheme.textSecondary),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 20),
                              onPressed: () {
                                _searchController.clear();
                              },
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Filter Chips (All vs Favorites)
                  Row(
                    children: [
                      FilterChip(
                        selected: !_showFavoritesOnly,
                        label: Text('All Contacts ($_totalCount)'),
                        labelStyle: TextStyle(
                          fontSize: 13,
                          fontWeight: !_showFavoritesOnly ? FontWeight.w600 : FontWeight.w500,
                          color: !_showFavoritesOnly ? AppTheme.primaryColor : AppTheme.textSecondary,
                        ),
                        selectedColor: AppTheme.primaryLight,
                        backgroundColor: Colors.white,
                        side: BorderSide(
                          color: !_showFavoritesOnly ? AppTheme.primaryColor : AppTheme.borderColor,
                        ),
                        showCheckmark: false,
                        onSelected: (selected) {
                          if (_showFavoritesOnly) {
                            setState(() => _showFavoritesOnly = false);
                            _filterContacts();
                          }
                        },
                      ),
                      const SizedBox(width: 8),
                      FilterChip(
                        selected: _showFavoritesOnly,
                        avatar: Icon(
                          _showFavoritesOnly ? Icons.star_rounded : Icons.star_outline_rounded,
                          size: 16,
                          color: _showFavoritesOnly ? AppTheme.favoriteColor : AppTheme.textSecondary,
                        ),
                        label: Text('Favorites ($_favoritesCount)'),
                        labelStyle: TextStyle(
                          fontSize: 13,
                          fontWeight: _showFavoritesOnly ? FontWeight.w600 : FontWeight.w500,
                          color: _showFavoritesOnly ? AppTheme.favoriteColor : AppTheme.textSecondary,
                        ),
                        selectedColor: AppTheme.favoriteColor.withValues(alpha: 0.15),
                        backgroundColor: Colors.white,
                        side: BorderSide(
                          color: _showFavoritesOnly ? AppTheme.favoriteColor : AppTheme.borderColor,
                        ),
                        showCheckmark: false,
                        onSelected: (selected) {
                          if (!_showFavoritesOnly) {
                            setState(() => _showFavoritesOnly = true);
                            _filterContacts();
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Contacts List / Empty State / Loader
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : RefreshIndicator(
                      onRefresh: _loadContacts,
                      child: _buildContactList(),
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Add new contact',
        onPressed: _navigateToAddContact,
        child: const Icon(Icons.person_add_alt_1_rounded),
      ),
    );
  }

  Widget _buildContactList() {
    if (_contacts.isEmpty) {
      if (_searchController.text.isNotEmpty) {
        return EmptyState(
          icon: Icons.search_off_rounded,
          title: 'No Contacts Found',
          message: 'No contacts match "${_searchController.text}".\nTry searching with a different name.',
        );
      } else if (_showFavoritesOnly) {
        return const EmptyState(
          icon: Icons.star_border_rounded,
          title: 'No Favorite Contacts',
          message: 'You have not added any contacts to your favorites yet.\nTap the star icon on any contact to add it here.',
        );
      } else {
        return EmptyState(
          icon: Icons.people_outline_rounded,
          title: 'No Contacts Yet',
          message: 'Your contact list is currently empty.\nStart by adding your first contact!',
          actionLabel: 'Add Contact',
          onAction: _navigateToAddContact,
        );
      }
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(top: 8, bottom: 88),
      itemCount: _contacts.length,
      itemBuilder: (context, index) {
        final contact = _contacts[index];
        return ContactCard(
          contact: contact,
          onTap: () => _navigateToDetails(contact),
          onFavoriteToggle: () => _toggleFavorite(contact),
          onEdit: () => _navigateToEditContact(contact),
          onDelete: () => _deleteContact(contact),
        );
      },
    );
  }
}
