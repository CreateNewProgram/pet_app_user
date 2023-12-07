import 'dart:io';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:playbus/admin/home_screen.dart';
import 'package:playbus/admin/profile_screen.dart';
import 'package:playbus/admin/gps_screen.dart';
import 'package:playbus/admin/workboard_screen.dart';
import '../components/friendboard_wallPosts.dart';
import '../components/my_textfield.dart';

const seedColor = Color(0xff00ffff);
const outPadding = 32.0;

class DynamicColorDemo extends StatelessWidget {
  const DynamicColorDemo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorSchemeSeed: seedColor,
        brightness: Brightness.dark,
        textTheme: GoogleFonts.notoSansNKoTextTheme(
          Theme.of(context).textTheme,
        ),
      ),
    );
  }
}

class friendboardPage extends StatefulWidget {
  const friendboardPage({Key? key}) : super(key: key);

  @override
  State<friendboardPage> createState() => _boardPageState();
}

class _boardPageState extends State<friendboardPage> {
  final currentUser = FirebaseAuth.instance.currentUser!;
  final textController = TextEditingController();
  File? _image;
  String? imageName;
  int _selected = 0;

  Future<void> _pickImage() async {
    final pickedImage = await ImagePicker().getImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        _image = File(pickedImage.path);
      });
    }
  }

  Future<void> _uploadImage() async {
    if (_image != null) {
      try {
        imageName = DateTime.now().millisecondsSinceEpoch.toString();
        final Reference storageReference = FirebaseStorage.instance.ref().child('gs://pet-app-c6d12.appspot.com/friend/$imageName');
        final UploadTask uploadTask = storageReference.putFile(_image!);
        await uploadTask.whenComplete(() {
          print('Image uploaded');
        });
      } catch (e) {
        print('Error uploading image: $e');
      }
    }
  }

  void signUserOut() {
    FirebaseAuth.instance.signOut();
  }

  void postMessage() {
    if (textController.text.isNotEmpty) {
      _uploadImage().then((_) {
        FirebaseFirestore.instance.collection("friend Posts").add({
          "UserEmail": currentUser.email,
          'Message': textController.text,
          'TimeStamp': Timestamp.now(),
          'Likes': [],
          'ImageURL': _image != null ? 'gs://pet-app-c6d12.appspot.com/friend/$imageName' : null,
        });

        setState(() {
          textController.clear();

          _image = null;
          imageName = null;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // Hide the back button
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.topRight,
              colors: [Colors.deepPurpleAccent, Colors.grey], // Adjust colors as needed
            ),
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: TextButton(
                onPressed: () {},
                child: Text('산책 친구'),
                style: TextButton.styleFrom(primary: Colors.black),
              ),
            ),
            Expanded(
              child: TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => workboardPage()),
                  );
                },
                child: Text('산책 알바'),
                style: TextButton.styleFrom(primary: Colors.black),
              ),
            ),
          ],
        ),
      ),
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
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfilePage()),
              );
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
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection("friend Posts")
                  .orderBy("TimeStamp", descending: false)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      final post = snapshot.data!.docs[index];
                      return WallPost(
                        message: post['Message'],
                        user: post['UserEmail'],
                        postId: post.id,
                        likes: List<String>.from(post['Likes'] ?? []),
                        imageUrl: post['ImageURL'] ?? '', // 이미지 URL을 가져와 전달
                      );
                    },
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                }
                return const Center(
                  child: CircularProgressIndicator(),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              children: [
                Expanded(
                  child: MyTextField(
                    controller: textController,
                    hintText: '입력하세요',
                    obscureText: false,
                  ),
                ),
                IconButton(
                  onPressed: postMessage,
                  icon: Icon(Icons.arrow_circle_up),
                ),
                IconButton(
                  onPressed: _pickImage,
                  icon: Icon(Icons.image),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}



