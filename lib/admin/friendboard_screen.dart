import 'dart:io';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:playbus/admin/profile_screen.dart';
import 'package:playbus/admin/workboard_screen.dart';

import '../components/like_button.dart';
import '../components/my_textfield.dart';
import 'gps_screen.dart';
import 'home_screen.dart';

const seedColor = Color(0xff00ffff);

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
    final pickedImage =
    await ImagePicker().getImage(source: ImageSource.gallery);
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
        final Reference storageReference = FirebaseStorage.instance
            .ref()
            .child('gs://pet-app-c6d12.appspot.com/friend/$imageName');
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
          'Comments': [],
          'ImageURL': _image != null
              ? 'gs://pet-app-c6d12.appspot.com/friend/$imageName'
              : null,
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
        automaticallyImplyLeading:
        false, // Hide the back button
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.topRight,
              colors: [
                Colors.deepPurpleAccent,
                Colors.grey
              ], // Adjust colors as needed
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
        selectedItemColor:
        Theme.of(context).colorScheme.onPrimaryContainer,
        unselectedItemColor:
        Theme.of(context).colorScheme.onPrimaryContainer,
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
                        messsage: post['Message'],
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

class WallPost extends StatefulWidget {
  final String messsage;
  final String user;
  final String postId;
  final List<String> likes;
  final String imageUrl;

  const WallPost({
    Key? key,
    required this.messsage,
    required this.user,
    required this.postId,
    required this.likes,
    required this.imageUrl,
  }) : super(key: key);

  @override
  State<WallPost> createState() => _WallPostState();
}

class _WallPostState extends State<WallPost> {
  final currentUser = FirebaseAuth.instance.currentUser!;
  bool isLiked = false;
  List<Map<String, dynamic>> comments = [];

  void postComment(String commentText) {
    if (commentText.isNotEmpty) {
      DocumentReference postRef =
      FirebaseFirestore.instance.collection("friend Posts").doc(widget.postId);

      try {
        postRef.update({
          'Comments': FieldValue.arrayUnion([
            {
              'user': currentUser.email,
              'commentText': commentText,
              'timestamp': Timestamp.now(),
            }
          ])
        });
      } catch (e) {
        print('댓글 업데이트 오류: $e');
      }
    }
  }

  @override
  void initState() {
    super.initState();
    isLiked = widget.likes.contains(currentUser.email);
  }

  void toggleLike() {
    setState(() {
      isLiked = !isLiked;
    });

    DocumentReference postRef =
    FirebaseFirestore.instance.collection("friend Posts").doc(widget.postId);

    try {
      if (isLiked) {
        postRef.update({
          'Likes': FieldValue.arrayUnion([currentUser.email])
        });
      } else {
        postRef.update({
          'Likes': FieldValue.arrayRemove([currentUser.email])
        });
      }
    } catch (e) {
      print('Error updating likes: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      margin: EdgeInsets.only(top: 25, left: 25, right: 25),
      padding: EdgeInsets.all(25),
      child: Column(
        children: [
          Row(
            children: [
              const SizedBox(width: 5),
              LikeButton(isLiked: isLiked, onTap: toggleLike),
              const SizedBox(width: 5),
              Text(
                widget.likes.length.toString(),
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(width: 20),
              Text(
                widget.user,
                style: TextStyle(color: Colors.grey[500]),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(widget.messsage),
          const SizedBox(height: 20),
          InkWell(
            onTap: () {
              showDialog(
                context: context,
                builder: (context) {
                  TextEditingController commentController = TextEditingController();
                  return AlertDialog(
                    title: Text('댓글 입력'),
                    content: TextField(
                      controller: commentController,
                      decoration: InputDecoration(hintText: '댓글을 입력하세요'),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text('취소'),
                      ),
                      TextButton(
                        onPressed: () {
                          // 댓글을 게시하고 Firebase를 업데이트합니다.
                          postComment(commentController.text);
                          // 댓글 목록을 업데이트하고 화면을 다시 그립니다.
                          setState(() {
                            comments.add({
                              'user': currentUser.email,
                              'commentText': commentController.text,
                              'timestamp': Timestamp.now(),
                            });
                          });
                          Navigator.pop(context);
                        },
                        child: Text('입력'),
                      ),
                    ],
                  );
                },
              );
            },
            child: Icon(
              Icons.comment,
              color: Colors.grey,
            ),
          ),
          // 댓글 목록을 표시하는 부분 추가
          Column(
            children: comments.map((comment) {
              return ListTile(
                title: Text(comment['user']),
                subtitle: Text(comment['commentText']),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}