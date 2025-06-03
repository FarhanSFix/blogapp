import 'package:blogapp/constant.dart';
import 'package:blogapp/models/api_response.dart';
import 'package:blogapp/models/post.dart';
import 'package:blogapp/models/user.dart';
import 'package:blogapp/screens/comment_screen.dart';
import 'package:blogapp/screens/dm_screen.dart';
import 'package:blogapp/services/post_service.dart';
import 'package:blogapp/services/user_service.dart';
import 'package:flutter/material.dart';

import 'login.dart';
import 'post_form.dart';

class PostScreen extends StatefulWidget {
  @override
  _PostScreenState createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  List<dynamic> _postList = [];
  int userId = 0;
  bool _loading = true;
  String userName = '';
  TextEditingController _searchController = TextEditingController();
  List<dynamic> _filteredPostList = [];

  Future<void> retrievePosts() async {
    userId = await getUserId();
    ApiResponse response = await getPosts();

    if (response.error == null) {
      setState(() {
        _postList = response.data as List<dynamic>;
        _filteredPostList = _postList;
        _loading = false;
      });
    } else if (response.error == unauthorized) {
      logout().then(
        (value) => {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => Login()),
            (route) => false,
          ),
        },
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('${response.error}')));
    }
  }

  void _handleDeletePost(int postId) async {
    ApiResponse response = await deletePost(postId);
    if (response.error == null) {
      retrievePosts();
    } else if (response.error == unauthorized) {
      logout().then(
        (value) => {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => Login()),
            (route) => false,
          ),
        },
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('${response.error}')));
    }
  }

  // post like dislik
  void _handlePostLikeDislike(int postId) async {
    ApiResponse response = await likeUnlikePost(postId);

    if (response.error == null) {
      retrievePosts();
    } else if (response.error == unauthorized) {
      logout().then(
        (value) => {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => Login()),
            (route) => false,
          ),
        },
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('${response.error}')));
    }
  }

  void loadUser() async {
    ApiResponse response = await getUserDetail();
    if (response.error == null) {
      setState(() {
        userName = (response.data as User).name ?? '';
      });
    } else if (response.error == unauthorized) {
      logout().then(
        (value) => {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => Login()),
            (route) => false,
          ),
        },
      );
    }
  }

  @override
  void initState() {
    retrievePosts();
    super.initState();
    loadUser();
  }

  @override
  Widget build(BuildContext context) {
    return _loading
        ? Center(child: CircularProgressIndicator())
        : Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Scaffold(
              appBar: PreferredSize(
                preferredSize: Size(double.infinity, 100),
                child: Card(
                  elevation: 3,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Welcome, $userName!!",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => DmScreen(),
                                  ),
                                );
                              },
                              icon: Icon(Icons.chat, color: Colors.blue),
                            ),
                          ],
                        ),
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            onChanged: _filterPosts,
                            decoration: InputDecoration(
                              prefixIcon: Icon(Icons.search),
                              hintText: 'Search...',
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              body: RefreshIndicator(
                onRefresh: () {
                  return retrievePosts();
                },
                child: ListView.builder(
                  itemCount: _filteredPostList.length,
                  itemBuilder: (BuildContext context, int index) {
                    Post post = _filteredPostList[index];

                    return Container(
                      margin: EdgeInsets.only(bottom: 8, top: 8),
                      padding: EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            blurRadius: 1,
                            offset: Offset(2, 2),
                            color: Colors.black.withOpacity(0.5),
                          ),
                        ],
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 6),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 38,
                                      height: 38,
                                      decoration: BoxDecoration(
                                        image: post.user!.image != null
                                            ? DecorationImage(
                                                image: NetworkImage(
                                                  '${post.user!.image}',
                                                ),
                                              )
                                            : null,
                                        borderRadius: BorderRadius.circular(25),
                                        color: Colors.amber,
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    Text(
                                      '${post.user!.name}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 17,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              post.user!.id == userId
                                  ? PopupMenuButton(
                                      child: Padding(
                                        padding: EdgeInsets.only(right: 10),
                                        child: Icon(
                                          Icons.more_vert,
                                          color: Colors.black,
                                        ),
                                      ),
                                      itemBuilder: (context) => [
                                        PopupMenuItem(
                                          child: Text('Edit'),
                                          value: 'edit',
                                        ),
                                        PopupMenuItem(
                                          child: Text('Delete'),
                                          value: 'delete',
                                        ),
                                      ],
                                      onSelected: (val) {
                                        if (val == 'edit') {
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (context) => PostForm(
                                                title: 'Edit Post',
                                                post: post,
                                              ),
                                            ),
                                          );
                                        } else {
                                          _handleDeletePost(post.id ?? 0);
                                        }
                                      },
                                    )
                                  : SizedBox(),
                            ],
                          ),
                          SizedBox(height: 12),
                          Text('${post.body}'),
                          post.image != null
                              ? Container(
                                  width: MediaQuery.of(context).size.width,
                                  height: 180,
                                  margin: EdgeInsets.only(top: 5),
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                      image: NetworkImage('${post.image}'),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                )
                              : SizedBox(height: post.image != null ? 0 : 10),
                          Row(
                            children: [
                              kLikeAndComment(
                                post.likesCount ?? 0,
                                post.selfLiked == true
                                    ? Icons.favorite
                                    : Icons.favorite_outline,
                                post.selfLiked == true
                                    ? Colors.red
                                    : Colors.black54,
                                () {
                                  _handlePostLikeDislike(post.id ?? 0);
                                },
                              ),
                              Container(
                                height: 25,
                                width: 0.5,
                                color: Colors.black38,
                              ),
                              kLikeAndComment(
                                post.commentsCount ?? 0,
                                Icons.sms_outlined,
                                Colors.black54,
                                () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          CommentScreen(postId: post.id),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width,
                            height: 0.5,
                            color: Colors.black26,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          );
  }

  void _filterPosts(String query) {
    final filtered = _postList.where((post) {
      final postBody = post.body?.toLowerCase() ?? '';
      final userName = post.user?.name?.toLowerCase() ?? '';
      final q = query.toLowerCase();
      return postBody.contains(q) || userName.contains(q);
    }).toList();

    setState(() {
      _filteredPostList = filtered;
    });
  }
}
