import 'package:flutter/material.dart';
import 'package:playbus/admin/petInfo_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:playbus/admin/profile_screen.dart';

import 'home_screen.dart';


class selectScreen extends StatelessWidget {
  selectScreen({Key? key}) : super(key: key);

  final user = FirebaseAuth.instance.currentUser!;

  void signUserOut() {
    FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(user.email! + " 로그인"),
      ),
      body: Container(
        color: Colors.deepPurpleAccent,
        child: Align(
          alignment: Alignment.center,
          child: GridView.count(
            crossAxisCount: 2,
            children: [
              _buildCard(
                icon: Icons.content_paste,
                title: '등록번호',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => MainScreen()),
                  );
                },
              ),
              _buildCard(
                icon: Icons.event,
                title: '직접 입력',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => PetInfoForm()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: EdgeInsets.all(16),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        splashColor: Colors.grey,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: Colors.black),
            SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
