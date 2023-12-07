import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'like_button.dart';

class WallPost extends StatefulWidget {
  final String message;
  final String user;
  final String postId;
  final List<String> likes;
  final String imageUrl; // 이미지 URL을 나타내는 필드

  const WallPost({
    Key? key,
    required this.message,
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

    if (isLiked) {
      postRef.update({
        'Likes': FieldValue.arrayUnion([currentUser.email])
      });
    } else {
      postRef.update({
        'Likes': FieldValue.arrayRemove([currentUser.email])
      });
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 이미지 표시
          widget.imageUrl.isNotEmpty
              ? Image.network(
            widget.imageUrl,
            width: double.infinity, // 이미지의 크기를 조절하세요
            height: 200,
            fit: BoxFit.cover,
          )
              : Container(),

          const SizedBox(height: 10),

          Row(
            children: [
              // Like 버튼
              LikeButton(isLiked: isLiked, onTap: toggleLike),
              const SizedBox(width: 5),
              // Like 수
              Text(

                widget.likes.length.toString(),
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // 메시지와 사용자 이메일
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.user,
                style: TextStyle(color: Colors.grey[500]),
              ),
              const SizedBox(height: 10),
              Text(widget.message),
            ],
          )
        ],
      ),
    );
  }
}
