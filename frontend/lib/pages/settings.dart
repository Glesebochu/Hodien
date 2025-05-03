import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;
import '../services/user_service.dart';
import '../models/user.dart' as app_models;

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _userService = UserService();
  late Future<app_models.User?> _userFuture;

  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmDeletePasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _userFuture = _userService.getCurrentUser();
  }

  void _reloadUser() {
    setState(() {
      _userFuture = _userService.getCurrentUser();
    });
  }

  Future<void> _handleEditProfile() async {
    final username = _usernameController.text.trim();
    // final email = _emailController.text.trim();
    final res = await _userService.updateProfileInfo(
      newUsername: username,
      // newEmail: email,
    );

    if (res == "success") {
      _showSuccessDialog('Profile updated successfully!');
      _reloadUser();
    } else {
      _showErrorDialog(res);
    }
  }

  Future<void> _handlePasswordChange() async {
    final current = _currentPasswordController.text;
    final newPass = _newPasswordController.text;
    final res = await _userService.updatePassword(
      currentPassword: current,
      newPassword: newPass,
    );

    if (res == "success") {
      _showSuccessDialog('Password changed successfully!');
      _currentPasswordController.clear();
      _newPasswordController.clear();
    } else {
      _showErrorDialog(res);
    }
  }

  Future<void> _handleDeleteAccount() async {
    final confirmed = await _confirmDeleteDialog();
    if (!confirmed) return;

    final password = _confirmDeletePasswordController.text;
    final res = await _userService.deleteAccount(password);

    if (res == "success") {
      if (context.mounted) Navigator.of(context).pushReplacementNamed('/');
    } else {
      _showErrorDialog(res);
    }
  }

  Future<void> _handleLogout() async {
    FirebaseAuth.instance.signOut();
    Navigator.pop(context);
    // await _userService.logout();
    // if (context.mounted) Navigator.of(context).pushReplacementNamed('/');
  }

  Future<void> _showSuccessDialog(String message) async {
    return showDialog(
      context: context,
      builder:
          (context) => Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: shadcn.AlertDialog(
                title: shadcn.Text(
                  'Success',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                content: Text(message),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('OK'),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  Future<void> _showErrorDialog(String message) async {
    return showDialog(
      context: context,
      builder:
          (context) => Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: shadcn.AlertDialog(
                title: shadcn.Text(
                  'Error',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                content: Text(message),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('OK'),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  Future<bool> _confirmDeleteDialog() async {
    return await showDialog(
          context: context,
          builder:
              (context) => Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: shadcn.AlertDialog(
                    title: const Text('Are you sure?'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        shadcn.TextField(
                          controller: _confirmDeletePasswordController,
                          obscureText: true,
                          placeholder: const Text('Enter your Password'),
                          features: const [
                            shadcn.InputFeature.clear(),
                            shadcn.InputFeature.passwordToggle(
                              mode: shadcn.PasswordPeekMode.toggle,
                            ),
                          ],
                          // decoration: const InputDecoration(
                          //   labelText: 'Enter your password',
                          // ),
                        ),
                        const SizedBox(height: 12),
                        const Text('This action cannot be undone.'),
                      ],
                    ),
                    actions: [
                      shadcn.PrimaryButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel'),
                      ),
                      shadcn.DestructiveButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Delete'),
                      ),
                    ],
                  ),
                  // shadcn.AlertDialog(
                  //   title: shadcn.Text(
                  //     'Success',
                  //     style: const TextStyle(fontWeight: FontWeight.bold),
                  //   ),
                  //   content: Text("message"),
                  //   actions: [
                  //     TextButton(
                  //       onPressed: () => Navigator.pop(context),
                  //       child: const Text('OK'),
                  //     ),
                  //   ],
                  // ),
                ),
              ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<app_models.User?>(
      future: _userFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final user = snapshot.data!;
        final initial = user.username[0].toUpperCase();

        _usernameController.text = user.username;
        _emailController.text = user.email;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Settings'),
            actions: [
              // shadcn.ThemeToggleButton(),
              const SizedBox(width: 12),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              children: [
                Column(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      child: Text(
                        initial,
                        style: const TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Hello, ${user.username}!',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(user.email, style: TextStyle(color: Colors.grey[600])),
                  ],
                ),

                const SizedBox(height: 16),
                shadcn.Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Edit Profile',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        shadcn.TextField(
                          controller: _usernameController,
                          placeholder: const Text('Username'),
                          features: const [shadcn.InputFeature.clear()],
                        ),
                        const SizedBox(height: 12),
                        // shadcn.TextField(
                        //   controller: _emailController,
                        //   placeholder: const Text('Email'),
                        //   features: const [shadcn.InputFeature.clear()],
                        // ),
                        // const SizedBox(height: 12),
                        shadcn.PrimaryButton(
                          onPressed: _handleEditProfile,
                          child: const Text('Update Info'),
                          // text: 'Save Changes',
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                shadcn.Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Change Password',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        shadcn.TextField(
                          controller: _currentPasswordController,
                          obscureText: true,
                          placeholder: const Text('Current Password'),
                          features: const [
                            shadcn.InputFeature.clear(),
                            shadcn.InputFeature.passwordToggle(
                              mode: shadcn.PasswordPeekMode.toggle,
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        shadcn.TextField(
                          controller: _newPasswordController,
                          obscureText: true,
                          placeholder: const Text('New Password'),
                          features: const [
                            shadcn.InputFeature.clear(),
                            shadcn.InputFeature.passwordToggle(
                              mode: shadcn.PasswordPeekMode.toggle,
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        shadcn.PrimaryButton(
                          onPressed: _handlePasswordChange,
                          child: const Text('Update profile'),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                shadcn.Card(
                  // color: Colors.red.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Account Actions',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          child: shadcn.OutlineButton(
                            onPressed: _handleLogout,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(Icons.logout),
                                SizedBox(width: 8),
                                Text('Logout'),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: shadcn.DestructiveButton(
                            onPressed: _handleDeleteAccount,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(Icons.delete),
                                SizedBox(width: 8),
                                Text('Delete Account'),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
