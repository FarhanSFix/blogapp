import 'dart:io';

import 'package:blogapp/constant.dart';
import 'package:blogapp/models/api_response.dart';
import 'package:blogapp/models/post.dart';
import 'package:blogapp/services/post_service.dart';
import 'package:blogapp/services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'login.dart';

class PostForm extends StatefulWidget {
  final Post? post;
  final String? title;

  PostForm({this.post, this.title});

  @override
  _PostFormState createState() => _PostFormState();
}

class _PostFormState extends State<PostForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _txtControllerBody = TextEditingController();
  bool _loading = false;
  File? _imageFile;
  final _picker = ImagePicker();

  Future getImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  void _createPost() async {
    String? image = _imageFile == null ? null : getStringImage(_imageFile);
    ApiResponse response = await createPost(_txtControllerBody.text, image);

    if (response.error == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await Future.delayed(Duration(milliseconds: 200));
        Navigator.of(context).pop();
      });
    } else if (response.error == unauthorized) {
      logout().then((value) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => Login()),
            (route) => false,
          );
        });
      });
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('${response.error}')));
      });
      setState(() {
        _loading = false;
      });
    }
  }

  // edit post
  void _editPost(int postId) async {
    ApiResponse response = await editPost(postId, _txtControllerBody.text);

    if (response.error == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await Future.delayed(Duration(milliseconds: 200));
        Navigator.of(context).pop();
      });
    } else if (response.error == unauthorized) {
      logout().then((value) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => Login()),
            (route) => false,
          );
        });
      });
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('${response.error}')));
      });
      setState(() {
        _loading = false;
      });
    }
  }

  Future<bool> _onWillPop() async {
    if (_txtControllerBody.text.isNotEmpty || _imageFile != null) {
      bool? confirm = await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text("Batal membuat postingan?"),
          content: Text("Perubahan Anda akan hilang."),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Container(
                height: 40,
                width: 80,
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    "Tidak",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                await Future.delayed(Duration(milliseconds: 200));
                Navigator.of(context).pop(true);
              },
              child: Container(
                height: 40,
                width: 80,
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    "Ya",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
      return confirm == true;
    }
    return true;
  }

  @override
  void initState() {
    if (widget.post != null) {
      _txtControllerBody.text = widget.post!.body ?? '';
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(title: Text('${widget.title}')),
        body: _loading
            ? Center(child: CircularProgressIndicator())
            : ListView(
                children: [
                  widget.post != null
                      ? SizedBox()
                      : Container(
                          width: MediaQuery.of(context).size.width,
                          height: 200,
                          decoration: BoxDecoration(
                            image: _imageFile == null
                                ? null
                                : DecorationImage(
                                    image: FileImage(_imageFile ?? File('')),
                                    fit: BoxFit.cover,
                                  ),
                          ),
                          child: Center(
                            child: IconButton(
                              icon: Icon(
                                Icons.image,
                                size: 50,
                                color: Colors.black38,
                              ),
                              onPressed: () {
                                getImage();
                              },
                            ),
                          ),
                        ),
                  Form(
                    key: _formKey,
                    child: Padding(
                      padding: EdgeInsets.all(8),
                      child: TextFormField(
                        controller: _txtControllerBody,
                        keyboardType: TextInputType.multiline,
                        maxLines: 9,
                        validator: (val) =>
                            val!.isEmpty ? 'Post body is required' : null,
                        decoration: InputDecoration(
                          hintText: "Post body...",
                          border: OutlineInputBorder(
                            borderSide: BorderSide(
                              width: 1,
                              color: Colors.black38,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: kTextButton('Post', () {
                      if (_formKey.currentState!.validate()) {
                        setState(() {
                          _loading = !_loading;
                        });
                        if (widget.post == null) {
                          _createPost();
                        } else {
                          _editPost(widget.post!.id ?? 0);
                        }
                      }
                    }),
                  ),
                ],
              ),
      ),
    );
  }
}
