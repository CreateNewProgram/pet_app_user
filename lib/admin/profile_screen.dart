import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:playbus/admin/gps_screen.dart';
import 'friendboard_screen.dart';
import 'home_screen.dart';

const seedColor = Color(0xff00ffff);

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int _selected = 0;

  final currentUser = FirebaseAuth.instance.currentUser!;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurpleAccent,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selected,
        elevation: 0,
        onTap: (selected) {
          setState(() {
            _selected = selected;
          });
          switch (_selected) {
            case 0:
              Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => MainScreen()),
              );
              break;
            case 1:
              break;
            case 2:
            // 런 페이지
              break;
            case 3:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MapScreen()),
              );
              break;
            case 4:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => friendboardPage()),
              );
              break;
          }
        },
        selectedItemColor: Theme.of(context).colorScheme.onPrimaryContainer,
        unselectedItemColor: Theme.of(context).colorScheme.onPrimaryContainer,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              label: "",
              backgroundColor: Colors.transparent),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              label: "",
              backgroundColor: Colors.transparent),
          BottomNavigationBarItem(
              icon: Icon(Icons.directions_run),
              label: "",
              backgroundColor: Colors.transparent),
          BottomNavigationBarItem(
              icon: Icon(Icons.assistant_navigation),
              label: "",
              backgroundColor: Colors.transparent),
          BottomNavigationBarItem(
              icon: Icon(Icons.newspaper_outlined),
              label: "",
              backgroundColor: Colors.transparent),
        ],
      ),
      body: ListView(
        children: [
          const SizedBox(height: 50,),
          const Icon(
            Icons.person,
            size: 72,
          ),
          SizedBox(height: 10),
          // user email
          Text(
            currentUser.email!,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }
}