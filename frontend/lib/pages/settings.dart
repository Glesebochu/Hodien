import 'package:flutter/material.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;
import 'package:frontend/services/user_service.dart';
import 'package:frontend/models/user.dart' as user_model;
import 'package:firebase_auth/firebase_auth.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _userService = UserService();
  bool _isLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.amber.withAlpha(180),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: StreamBuilder<user_model.User?>(
          stream: _userService.getCurrentUserStream(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError || !snapshot.hasData) {
              return const Center(child: Text('Error loading user data'));
            }
            final user = snapshot.data!;
            _usernameController.text = user.username;
            _emailController.text = user.email;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Section
                shadcn.Card(
                  // elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        shadcn.Avatar(
                          size: 80,
                          initials: user.username[0].toUpperCase(),
                        ),
                        const SizedBox(height: 16),
                        shadcn.Form(
                          child: shadcn.FormField(
                            key: const shadcn.InputKey(#profile),
                            label: const Text('Username'),
                            validator: shadcn.ConditionalValidator((
                              value,
                            ) async {
                              // simulate a network delay for example purpose
                              await Future.delayed(const Duration(seconds: 1));
                              return ![
                                'sunarya-thito',
                                'septogeddon',
                                'admin',
                              ].contains(value);
                            }, message: 'Username already taken'),
                            child: Column(
                              children: [
                                const shadcn.TextField(
                                  placeholder: Text('Enter your username'),
                                  initialValue: 'sunarya-thito',
                                  features: [shadcn.InputFeature.revalidate()],
                                ),

                                const SizedBox(height: 16.0),

                                shadcn.FormErrorBuilder(
                                  builder: (context, errors, child) {
                                    return shadcn.PrimaryButton(
                                      onPressed:
                                          _isLoading
                                              ? null
                                              : () => _updateUsername(context),
                                      child:
                                          _isLoading
                                              ? const SizedBox(
                                                width: 20,
                                                height: 20,
                                                child:
                                                    CircularProgressIndicator(
                                                      strokeWidth: 2,
                                                    ),
                                              )
                                              : const Text('Update Username'),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                const SizedBox(height: 24),

                // Account Section
                shadcn.Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Account',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),

                        shadcn.Form(
                          child: shadcn.FormField(
                            key: const shadcn.InputKey(#account),
                            label: const Text('Email'),
                            validator: shadcn.ConditionalValidator((
                              value,
                            ) async {
                              // simulate a network delay for example purpose
                              await Future.delayed(const Duration(seconds: 1));
                              return ![
                                'sunarya-thito',
                                'septogeddon',
                                'admin',
                              ].contains(value);
                            }, message: 'Email already taken'),
                            child: Column(
                              children: [
                                const shadcn.TextField(
                                  placeholder: Text('Enter your Email'),
                                  initialValue: 'John@example.com',
                                  features: [shadcn.InputFeature.revalidate()],
                                ),

                                const SizedBox(height: 16.0),

                                shadcn.TextField(
                                  controller: _currentPasswordController,
                                  placeholder: Text('Enter your password'),
                                  features: [
                                    shadcn.InputFeature.clear(),
                                    shadcn.InputFeature.passwordToggle(
                                      mode: shadcn.PasswordPeekMode.hold,
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 16),

                                shadcn.FormErrorBuilder(
                                  builder: (context, errors, child) {
                                    return shadcn.PrimaryButton(
                                      onPressed:
                                          _isLoading
                                              ? null
                                              : () => _updateEmail(context),
                                      child:
                                          _isLoading
                                              ? const SizedBox(
                                                width: 20,
                                                height: 20,
                                                child:
                                                    CircularProgressIndicator(
                                                      strokeWidth: 2,
                                                    ),
                                              )
                                              : const Text('Update Email'),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Password Section
                shadcn.Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Password',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),

                        shadcn.Form(
                          child: shadcn.FormField(
                            key: const shadcn.InputKey(#password),
                            label: const Text('Password'),
                            // validator: shadcn.ConditionalValidator((
                            //   value,
                            // ) async {
                            //   // simulate a network delay for example purpose
                            //   await Future.delayed(const Duration(seconds: 1));
                            //   return ![
                            //     'sunarya-thito',
                            //     'septogeddon',
                            //     'admin',
                            //   ].contains(value);
                            // }, message: 'Email already taken'),
                            child: Column(
                              children: [
                                // const shadcn.TextField(
                                //   placeholder: Text('Current Password'),
                                //   initialValue: 'John@example.com',
                                //   features: [shadcn.InputFeature.revalidate()],
                                // ),

                                // const SizedBox (height: 16.0),
                                shadcn.TextField(
                                  controller: _currentPasswordController,
                                  placeholder: Text('Current password'),
                                  features: [
                                    shadcn.InputFeature.clear(),
                                    shadcn.InputFeature.passwordToggle(
                                      mode: shadcn.PasswordPeekMode.hold,
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 16),

                                shadcn.TextField(
                                  controller: _newPasswordController,
                                  placeholder: Text('New password'),
                                  features: [
                                    shadcn.InputFeature.clear(),
                                    shadcn.InputFeature.passwordToggle(
                                      mode: shadcn.PasswordPeekMode.hold,
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 16),

                                shadcn.FormErrorBuilder(
                                  builder: (context, errors, child) {
                                    return shadcn.PrimaryButton(
                                      onPressed:
                                          _isLoading
                                              ? null
                                              : () => _updatePassword(context),
                                      child:
                                          _isLoading
                                              ? const SizedBox(
                                                width: 20,
                                                height: 20,
                                                child:
                                                    CircularProgressIndicator(
                                                      strokeWidth: 2,
                                                    ),
                                              )
                                              : const Text('Change Password'),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Additional Actions
                shadcn.Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        shadcn.OutlineButton(
                          onPressed: () async {
                            await FirebaseAuth.instance.signOut();
                            // Navigation handled by authStateChanges
                          },
                          child: const Text('Logout'),
                        ),
                        const SizedBox(height: 16),

                        // Danger Zone
                        shadcn.Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              crossAxisAlignment: CrossAxisAlignment.stretch,

                              // crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Danger Zone',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Align(
                                  alignment: Alignment.bottomCenter,
                                  child: shadcn.DestructiveButton(
                                    onPressed:
                                        _isLoading
                                            ? null
                                            : () => _deleteAccount(context),
                                    child: const Text('Delete Account'),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _updateUsername(BuildContext context) async {
    final newUsername = _usernameController.text.trim();
    if (newUsername.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Username cannot be empty')));
      return;
    }
    setState(() => _isLoading = true);
    try {
      final currentUser = await _userService.getCurrentUser();
      if (currentUser != null) {
        final updatedUser = user_model.User(
          userId: currentUser.userId,
          username: newUsername,
          email: currentUser.email,
          status: currentUser.status,
        );
        await _userService.updateUser(updatedUser);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Username updated successfully')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to update username: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateEmail(BuildContext context) async {
    final newEmail = _emailController.text.trim();
    final currentPassword = _currentPasswordController.text;
    if (newEmail.isEmpty || currentPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }
    setState(() => _isLoading = true);
    try {
      await _userService.updateEmail(newEmail, currentPassword);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email updated successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to update email: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updatePassword(BuildContext context) async {
    final currentPassword = _currentPasswordController.text;
    final newPassword = _newPasswordController.text;
    if (currentPassword.isEmpty || newPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }
    setState(() => _isLoading = true);
    try {
      await _userService.updatePassword(currentPassword, newPassword);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password updated successfully')),
      );
      _currentPasswordController.clear();
      _newPasswordController.clear();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to update password: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteAccount(BuildContext context) async {
    final passwordController = TextEditingController();
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => shadcn.AlertDialog(
            title: const Text('Delete Account'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Enter your password to confirm:'),
                const SizedBox(height: 8),
                shadcn.TextField(
                  controller: _currentPasswordController,
                  placeholder: Text('Enter your password'),
                  features: [
                    shadcn.InputFeature.clear(),
                    shadcn.InputFeature.passwordToggle(
                      mode: shadcn.PasswordPeekMode.hold,
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              shadcn.SecondaryButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              shadcn.SecondaryButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Delete'),
              ),
            ],
          ),
    );

    if (confirm != true) return;

    setState(() => _isLoading = true);
    try {
      await _userService.deleteAccount(passwordController.text);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Account deleted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to delete account: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }
}
