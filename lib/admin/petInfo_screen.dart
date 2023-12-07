import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:playbus/admin/home_screen.dart';

class PetInfoForm extends StatefulWidget {
  @override
  _PetInfoFormState createState() => _PetInfoFormState();
}

class _PetInfoFormState extends State<PetInfoForm> {
  final _formKey = GlobalKey<FormState>();

  // Variables to store form data
  String guardianName = '';
  String phoneNumber = '';
  String petName = '';
  String breed = '';
  String age = '';
  String gender = '';
  XFile? pickedImage;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);

    setState(() {
      pickedImage = pickedFile != null ? XFile(pickedFile.path) : null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('반려동물의 정보를 입력해주세요!'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildInputBox(
                labelText: '보호자 성함',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '보호자 성함을 입력해주세요';
                  }
                  return null;
                },
                onSaved: (value) {
                  guardianName = value!;
                },
              ),
              _buildInputBox(
                labelText: '전화번호',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '전화번호를 입력해주세요';
                  }
                  return null;
                },
                onSaved: (value) {
                  phoneNumber = value!;
                },
              ),
              _buildInputBox(
                labelText: '아이 이름',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '반려동물의 이름을 입력해주세요';
                  }
                  return null;
                },
                onSaved: (value) {
                  petName = value!;
                },
              ),
              _buildInputBox(
                labelText: '아이 품종',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '반려동물의 품종을 입력해주세요';
                  }
                  return null;
                },
                onSaved: (value) {
                  breed = value!;
                },
              ),
              _buildInputBox(
                labelText: '아이 나이',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '반려동물의 나이를 입력해주세요';
                  }
                  return null;
                },
                onSaved: (value) {
                  age = value!;
                },
              ),
              _buildInputBox(
                labelText: '아이 성별',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '반려동물의 성별을 입력해주세요';
                  }
                  return null;
                },
                onSaved: (value) {
                  gender = value!;
                },
              ),
              // Image picker
              ElevatedButton(
                onPressed: _pickImage,
                child: Text('사진 첨부'),
              ),
              if (pickedImage != null)
                Image.file(
                  File(pickedImage!.path),
                  height: 100,
                  width: 100,
                ),
              SizedBox(height: 18),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();

                    // Save data to Cloud Firestore
                    await _firestore.collection('petinfo').add({
                      'guardianName': guardianName,
                      'phoneNumber': phoneNumber,
                      'petName': petName,
                      'breed': breed,
                      'age': age,
                      'gender': gender,
                      'image': pickedImage?.path, // Store image path in Firestore
                    });

                    // Process the form data, for example, show a success message
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('저장 완료 !'),
                      ),
                    );

                    // Navigate to another page
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => MainScreen()),
                    );
                  }
                },
                child: Text('저장'),
              ),

            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputBox({
    required String labelText,
    required String? Function(String?)? validator,
    required void Function(String?)? onSaved,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: TextFormField(
        decoration: InputDecoration(
          labelText: labelText,
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        ),
        validator: validator,
        onSaved: onSaved,
      ),
    );
  }
}
