import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/user_service.dart';
import '../models/user.dart' as user_model;

class HomePage extends StatelessWidget {
  final UserService _userService = UserService();
  HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home Page"),
        backgroundColor: Colors.amber.withAlpha(180),
      ),
      body: StreamBuilder<user_model.User?>(
        stream: _userService.getCurrentUserStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return const Center(child: Text('Error loading user data'));
          }
          final user = snapshot.data!;
          return Center(child: Text('Welcome, ${user.username}')); //home body
        },
      ),
      drawer: LeftDrawer(),
    );
  }
}

class LeftDrawer extends StatelessWidget {
  final UserService _userService = UserService();

  LeftDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    // final user = FirebaseAuth.instance.currentUser;

    return Drawer(
      child: StreamBuilder<user_model.User?>(
        stream: _userService.getCurrentUserStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return const ListTile(title: Text('Error loading user'));
          }
          final user = snapshot.data!;

          return ListView(
            padding: EdgeInsets.zero,
            children: [
              UserAccountsDrawerHeader(
                accountName: Text(
                  user.username,
                  style: TextStyle(color: Colors.black),
                ),
                accountEmail: Text(
                  user.email,
                  style: TextStyle(color: Colors.black),
                ),
                currentAccountPicture: Icon(
                  Icons.account_circle_outlined,
                  size: 72,
                  color: Colors.indigo,
                  weight: 0.2,
                ),
                otherAccountsPictures: [
                  Icon(Icons.bookmark_border, color: Colors.black),
                ],
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.white, Colors.amber],
                  ),
                  // color: Colors.greenAccent,
                ),
              ),
              ListTile(
                leading: const Icon(Icons.home),
                title: const Text('Home'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.settings),
                title: const Text('Settings'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/settings');
                },
              ),
              ListTile(
                leading: const Icon(Icons.question_answer),
                title: const Text('Humor test'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/humorTest');
                },
              ),
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Logout'),
                onTap: () {
                  FirebaseAuth.instance.signOut();
                  Navigator.pop(context);
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
