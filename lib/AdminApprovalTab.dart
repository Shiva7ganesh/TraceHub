import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:lostandfound/FoundItemDetailsPage.dart';
import 'package:lostandfound/LostItemDetailsPage.dart';
import 'package:lostandfound/app_state.dart';

class AdminApprovalTab extends StatefulWidget {// Initialize Google Sign-In

  Future<Map<String, dynamic>?> _fetchUserData(String userId) async {
    try {
      DocumentSnapshot userDoc =
      await FirebaseFirestore.instance.collection('users').doc(userId).get();
      if (userDoc.exists) {
        return userDoc.data() as Map<String, dynamic>?;
      } else {
        return null;
      }
    } catch (e) {
      print('Error fetching user data: $e');
      return null;
    }
  }
  _AdminApprovalTabState createState() => _AdminApprovalTabState();
}

class _AdminApprovalTabState extends State<AdminApprovalTab> {
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;
    return Scaffold(
        appBar: AppBar(
          title: Text('Pending Approvals'),
          automaticallyImplyLeading: false,
          actions: [
            user != null
                ? TextButton.icon(
              icon: Icon(Icons.logout, color: Colors.black),
              label: Text('Logout', style: TextStyle(color: Colors.black)),
              onPressed: () async {
                await _googleSignIn.signOut(); // Sign out from Google
                await FirebaseAuth.instance.signOut();
                Navigator.pushReplacementNamed(
                    context, '/login'); // Adjust the route to your home or login page
              },
            )
                : IconButton(
              icon: Icon(Icons.login),
              onPressed: () {
                Navigator.pushNamed(context, '/login'); // Adjust the route to your login page
              },
            ),
          ],
        ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('temporaryItems')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          var filteredDocs = snapshot.data!.docs.where((item) {
            return item['itemName']
                .toString()
                .toLowerCase()
                .contains(_searchQuery.toLowerCase());
          }).toList();

          if (filteredDocs.isEmpty) {
            return Center(child: Text('No posts found'));
          }

          return ListView.builder(
            itemCount: filteredDocs.length,
            itemBuilder: (context, index) {
              var item = filteredDocs[index];
              var itemName = item['itemName'] ?? 'No Name';
              var itemDescription = item['description'] ?? 'No Description';
              var images = item['images'] ?? [];
              var imageUrl = images.isNotEmpty ? images[0] : null;

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        if (item['Itemtype'] == 'Found') {
                          return FoundItemDetailsPage(item: item, isAdmin: AppState().isAdmin,);
                        } else {
                          return LostItemDetailsPage(item: item, isAdmin: AppState().isAdmin,);
                        }
                      },
                    ),
                  );
                  // Add any additional details navigation if needed
                },
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        AspectRatio(
                          aspectRatio: 1,
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.grey,
                            ),
                            child: Stack(
                              children: [
                                if (imageUrl != null)
                                  Image.network(
                                    imageUrl,
                                    fit: BoxFit.cover,
                                    loadingBuilder: (context, child, loadingProgress) {
                                      return AnimatedSwitcher(
                                        duration: Duration(milliseconds: 300),
                                        child: loadingProgress == null
                                            ? child
                                            : Center(
                                          child: CircularProgressIndicator(),
                                        ),
                                      );
                                    },
                                  ),
                                if (imageUrl == null)
                                  Center(
                                    child: Text(
                                      'Image Not Available',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 16.0),
                        Text(
                          itemName,
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        SizedBox(height: 8.0),
                        Text(
                          itemDescription,
                          style: TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                        SizedBox(height: 8.0),
                        Center(
                          child:ElevatedButton(
                            onPressed: () {
                              approveItem(item.id, item.data() as Map<String, dynamic>);
                            },
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black,
                                foregroundColor: Colors.white,
                                alignment: Alignment.center,
                            ),
                            child: Text('Approve'),
                        ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void approveItem(String itemId, Map<String, dynamic> itemData) {
    FirebaseFirestore.instance.collection('itemscollection').add(itemData).then((value) {
      FirebaseFirestore.instance.collection('temporaryItems').doc(itemId).delete();
    }).catchError((error) {
      // Handle error
    });
  }
}

class ItemSearchDelegate extends SearchDelegate<String> {
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: AnimatedIcon(
        icon: AnimatedIcons.menu_arrow,
        progress: transitionAnimation,
      ),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      close(context, query);
    });
    return Container();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return Container();
  }
}
