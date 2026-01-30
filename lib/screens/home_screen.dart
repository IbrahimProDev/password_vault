// lib/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:passwords_vault/utils/app_colours.dart';
import 'package:passwords_vault/widget/password_card.dart';
import '../models/password_entry.dart';
import '../services/storage_service.dart';
import '../utils/app_constants.dart';
import 'add_password_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  final String masterPassword;

  const HomeScreen({super.key, required this.masterPassword});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<PasswordEntry> _passwords = [];
  List<PasswordEntry> _filteredPasswords = [];
  String _searchQuery = '';
  String _selectedCategory = 'All';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPasswords();
  }

  Future<void> _loadPasswords() async {
    setState(() => _isLoading = true);

    final passwords = await StorageService.getPasswords();

    if (mounted) {
      setState(() {
        _passwords = passwords;
        _filteredPasswords = passwords;
        _isLoading = false;
      });
    }
  }

  void _filterPasswords() {
    setState(() {
      _filteredPasswords = _passwords.where((entry) {
        final matchesSearch =
            entry.title.toLowerCase().contains(_searchQuery) ||
            entry.username.toLowerCase().contains(_searchQuery);

        final matchesCategory =
            _selectedCategory == 'All' || entry.category == _selectedCategory;

        return matchesSearch && matchesCategory;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.darkBg, Color(0xFF1B1E3C)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.shield_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),

                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'My Vault',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'Keep your passwords safe',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white54,
                            ),
                          ),
                        ],
                      ),
                    ),

                    IconButton(
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SettingsScreen(
                              masterPassword: widget.masterPassword,
                            ),
                          ),
                        );
                        _loadPasswords();
                      },
                      icon: const Icon(
                        Icons.settings_rounded,
                        color: Colors.white,
                      ),
                      style: IconButton.styleFrom(
                        backgroundColor: AppColors.darkCard,
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.2, end: 0),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TextField(
                  onChanged: (value) {
                    setState(() => _searchQuery = value.toLowerCase());
                    _filterPasswords();
                  },
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Search passwords...',
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                    prefixIcon: Icon(
                      Icons.search,
                      color: AppColors.primaryPink,
                    ),
                    filled: true,
                    fillColor: AppColors.darkCard,
                  ),
                ),
              ).animate().fadeIn(delay: 100.ms, duration: 400.ms),

              const SizedBox(height: 20),

              SizedBox(
                height: 50,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    _buildCategoryChip('All'),
                    ...AppConstants.categories.map(_buildCategoryChip),
                  ],
                ),
              ).animate().fadeIn(delay: 200.ms, duration: 400.ms),

              const SizedBox(height: 20),

              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primaryPurple,
                        ),
                      )
                    : _filteredPasswords.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.lock_open_rounded,
                              size: 100,
                              color: Colors.white.withOpacity(0.2),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              _searchQuery.isEmpty
                                  ? 'No passwords yet\nTap + to add one'
                                  : 'No passwords found',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white.withOpacity(0.5),
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadPasswords,
                        backgroundColor: AppColors.darkCard,
                        color: AppColors.primaryPurple,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: _filteredPasswords.length,
                          itemBuilder: (context, index) {
                            return PasswordCard(
                                  entry: _filteredPasswords[index],
                                  masterPassword: widget.masterPassword,
                                  onUpdate: _loadPasswords,
                                )
                                .animate()
                                .fadeIn(
                                  delay: (50 * index).ms,
                                  duration: 400.ms,
                                )
                                .slideX(begin: 0.2, end: 0);
                          },
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton:
          Container(
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryPurple.withOpacity(0.5),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: FloatingActionButton.extended(
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddPasswordScreen(
                          masterPassword: widget.masterPassword,
                        ),
                      ),
                    );
                    _loadPasswords();
                  },
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  icon: const Icon(Icons.add, size: 28),
                  label: const Text(
                    'Add Password',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              )
              .animate()
              .fadeIn(delay: 400.ms, duration: 400.ms)
              .scale(begin: const Offset(0.8, 0.8)),
    );
  }

  Widget _buildCategoryChip(String category) {
    final isSelected = _selectedCategory == category;
    final color = category == 'All'
        ? AppColors.primaryPurple
        : AppConstants.categoryColors[category]!;

    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: FilterChip(
        label: Text(category),
        selected: isSelected,
        onSelected: (selected) {
          setState(() => _selectedCategory = category);
          _filterPasswords();
        },
        backgroundColor: AppColors.darkCard,
        selectedColor: color.withOpacity(0.3),
        checkmarkColor: color,
        labelStyle: TextStyle(
          color: isSelected ? color : Colors.white70,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        side: BorderSide(
          color: isSelected ? color : Colors.transparent,
          width: 2,
        ),
      ),
    );
  }
}
