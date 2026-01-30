import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:passwords_vault/utils/app_colours.dart';
import 'package:uuid/uuid.dart';
import 'dart:math';
import '../models/password_entry.dart';
import '../services/storage_service.dart';
import '../utils/app_constants.dart';

class AddPasswordScreen extends StatefulWidget {
  final String masterPassword;
  final PasswordEntry? entry;

  const AddPasswordScreen({
    super.key,
    required this.masterPassword,
    this.entry,
  });

  @override
  State<AddPasswordScreen> createState() => _AddPasswordScreenState();
}

class _AddPasswordScreenState extends State<AddPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _websiteController = TextEditingController();
  final _notesController = TextEditingController();

  String _selectedCategory = AppConstants.categories[0];
  bool _obscurePassword = true;
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    if (widget.entry != null) {
      _titleController.text = widget.entry!.title;
      _usernameController.text = widget.entry!.username;
      _passwordController.text = widget.entry!.password;
      _websiteController.text = widget.entry!.website ?? '';
      _notesController.text = widget.entry!.notes ?? '';
      _selectedCategory = widget.entry!.category;
      _isFavorite = widget.entry!.isFavorite;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _websiteController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  String _generatePassword() {
    const length = 16;
    const charset =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#\$%^&*()_+-=[]{}|;:,.<>?';
    final random = Random.secure();
    return List.generate(
      length,
      (_) => charset[random.nextInt(charset.length)],
    ).join();
  }

  Future<void> _savePassword() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      if (widget.entry != null) {
        final updated = widget.entry!.copyWith(
          title: _titleController.text.trim(),
          username: _usernameController.text.trim(),
          password: _passwordController.text,
          category: _selectedCategory,
          website: _websiteController.text.trim(),
          notes: _notesController.text.trim(),
          updatedAt: DateTime.now(),
          isFavorite: _isFavorite,
        );
        await StorageService.updatePassword(updated);
      } else {
        final entry = PasswordEntry(
          id: const Uuid().v4(),
          title: _titleController.text.trim(),
          username: _usernameController.text.trim(),
          password: _passwordController.text,
          category: _selectedCategory,
          website: _websiteController.text.trim(),
          notes: _notesController.text.trim(),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          isFavorite: _isFavorite,
        );
        await StorageService.addPassword(entry);
      }

      if (!mounted) return;

      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.entry != null ? '✓ Password updated!' : '✓ Password saved!',
          ),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _deletePassword() async {
    if (widget.entry != null) {
      await StorageService.deletePassword(widget.entry!.id);

      if (!mounted) return;

      Navigator.pop(context);
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✓ Password deleted!'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.entry != null;

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
              // Header
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(
                        Icons.arrow_back_rounded,
                        color: Colors.white,
                      ),
                      style: IconButton.styleFrom(
                        backgroundColor: AppColors.darkCard,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        isEditing ? 'Edit Password' : 'Add Password',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        setState(() => _isFavorite = !_isFavorite);
                      },
                      icon: Icon(
                        _isFavorite ? Icons.star : Icons.star_border,
                        color: _isFavorite ? Colors.amber : Colors.white,
                        size: 28,
                      ),
                      style: IconButton.styleFrom(
                        backgroundColor: AppColors.darkCard,
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.2, end: 0),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                              controller: _titleController,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                labelText: 'Title *',
                                labelStyle: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
                                ),
                                prefixIcon: const Icon(
                                  Icons.title,
                                  color: AppColors.primaryPink,
                                ),
                              ),
                              validator: (v) => v!.isEmpty ? 'Required' : null,
                            )
                            .animate()
                            .fadeIn(delay: 100.ms)
                            .slideX(begin: -0.2, end: 0),

                        const SizedBox(height: 20),

                        DropdownButtonFormField<String>(
                              value: _selectedCategory,
                              dropdownColor: AppColors.darkCard,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                labelText: 'Category *',
                                labelStyle: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
                                ),
                                prefixIcon: const Icon(
                                  Icons.category,
                                  color: AppColors.primaryOrange,
                                ),
                              ),
                              items: AppConstants.categories.map((cat) {
                                return DropdownMenuItem(
                                  value: cat,
                                  child: Row(
                                    children: [
                                      Icon(
                                        AppConstants.categoryIcons[cat],
                                        color: AppConstants.categoryColors[cat],
                                        size: 20,
                                      ),
                                      const SizedBox(width: 12),
                                      Text(cat),
                                    ],
                                  ),
                                );
                              }).toList(),
                              onChanged: (v) =>
                                  setState(() => _selectedCategory = v!),
                            )
                            .animate()
                            .fadeIn(delay: 150.ms)
                            .slideX(begin: -0.2, end: 0),

                        const SizedBox(height: 20),

                        TextFormField(
                              controller: _usernameController,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                labelText: 'Username / Email *',
                                labelStyle: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
                                ),
                                prefixIcon: const Icon(
                                  Icons.person,
                                  color: AppColors.primaryBlue,
                                ),
                              ),
                              validator: (v) => v!.isEmpty ? 'Required' : null,
                            )
                            .animate()
                            .fadeIn(delay: 200.ms)
                            .slideX(begin: -0.2, end: 0),

                        const SizedBox(height: 20),

                        TextFormField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                labelText: 'Password *',
                                labelStyle: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
                                ),
                                prefixIcon: const Icon(
                                  Icons.lock,
                                  color: AppColors.primaryGreen,
                                ),
                                suffixIcon: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      onPressed: () {
                                        setState(
                                          () => _obscurePassword =
                                              !_obscurePassword,
                                        );
                                      },
                                      icon: Icon(
                                        _obscurePassword
                                            ? Icons.visibility
                                            : Icons.visibility_off,
                                        color: Colors.white54,
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () {
                                        _passwordController.text =
                                            _generatePassword();
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              '✓ Strong password generated!',
                                            ),
                                            backgroundColor: Colors.green,
                                            duration: Duration(seconds: 2),
                                          ),
                                        );
                                      },
                                      icon: const Icon(
                                        Icons.refresh,
                                        color: AppColors.primaryGreen,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              validator: (v) {
                                if (v!.isEmpty) return 'Required';
                                if (v.length < 6) return 'Min 6 characters';
                                return null;
                              },
                            )
                            .animate()
                            .fadeIn(delay: 250.ms)
                            .slideX(begin: -0.2, end: 0),

                        const SizedBox(height: 20),

                        TextFormField(
                              controller: _websiteController,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                labelText: 'Website (Optional)',
                                labelStyle: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
                                ),
                                prefixIcon: const Icon(
                                  Icons.language,
                                  color: AppColors.primaryPurple,
                                ),
                              ),
                            )
                            .animate()
                            .fadeIn(delay: 300.ms)
                            .slideX(begin: -0.2, end: 0),

                        const SizedBox(height: 20),

                        TextFormField(
                              controller: _notesController,
                              maxLines: 3,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                labelText: 'Notes (Optional)',
                                labelStyle: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
                                ),
                                prefixIcon: const Icon(
                                  Icons.notes,
                                  color: AppColors.primaryOrange,
                                ),
                                alignLabelWithHint: true,
                              ),
                            )
                            .animate()
                            .fadeIn(delay: 350.ms)
                            .slideX(begin: -0.2, end: 0),

                        const SizedBox(height: 40),

                        Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                gradient: AppColors.primaryGradient,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primaryPurple.withOpacity(
                                      0.5,
                                    ),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: ElevatedButton(
                                onPressed: _savePassword,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  minimumSize: const Size(double.infinity, 60),
                                ),
                                child: Text(
                                  isEditing
                                      ? 'Update Password'
                                      : 'Save Password',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            )
                            .animate()
                            .fadeIn(delay: 400.ms)
                            .slideY(begin: 0.2, end: 0),

                        if (isEditing) ...[
                          const SizedBox(height: 20),
                          OutlinedButton.icon(
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      backgroundColor: AppColors.darkCard,
                                      title: const Text(
                                        'Delete Password?',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      content: const Text(
                                        'This action cannot be undone.',
                                        style: TextStyle(color: Colors.white70),
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context),
                                          child: const Text('Cancel'),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                            _deletePassword();
                                          },
                                          child: const Text(
                                            'Delete',
                                            style: TextStyle(color: Colors.red),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                label: const Text(
                                  'Delete Password',
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 16,
                                  ),
                                ),
                                style: OutlinedButton.styleFrom(
                                  minimumSize: const Size(double.infinity, 60),
                                  side: const BorderSide(
                                    color: Colors.red,
                                    width: 2,
                                  ),
                                ),
                              )
                              .animate()
                              .fadeIn(delay: 450.ms)
                              .slideY(begin: 0.2, end: 0),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
