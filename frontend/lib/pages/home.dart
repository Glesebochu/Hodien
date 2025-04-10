import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home Page"),
        backgroundColor: Colors.amber.withAlpha(180),
      ),
      body: Center(child: const Text("Welcome to the Home Page!")),
      drawer: const LeftDrawer(),
    );
  }
}

class LeftDrawer extends StatelessWidget {
  const LeftDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(
              user?.displayName ?? "User",
              style: TextStyle(color: Colors.black),
            ),
            accountEmail: Text(
              user?.email ?? "",
              style: TextStyle(color: Colors.black),
            ),
            currentAccountPicture: Icon(
              Icons.account_circle_outlined,
              size: 72,
              color: Colors.indigo,
              weight: 0.2, // Adjust the weight to make it thinner
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
      ),
    );
  }
}
