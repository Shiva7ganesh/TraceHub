import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart'; // Import Google Sign-In package
import 'package:lostandfound/AddFoundItemPage.dart';
import 'package:lostandfound/AddLostItemPage.dart';
import 'package:lostandfound/FoundItemDetailsPage.dart';
import 'package:lostandfound/LostItemDetailsPage.dart';
import 'package:lostandfound/app_state.dart';
import 'package:simple_speed_dial/simple_speed_dial.dart';

class UserProfilePage extends StatelessWidget {
  final GoogleSignIn _googleSignIn = GoogleSignIn(); // Initialize Google Sign-In

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

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
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
      body: user == null
          ? Center(
        child: Text('No user is signed in'),
      )
          : FutureBuilder<Map<String, dynamic>?>(
        future: _fetchUserData(user.uid),
        builder: (BuildContext context, AsyncSnapshot<Map<String, dynamic>?> snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          var userData = snapshot.data;
          var username = userData != null ? userData['username'] : 'No Username';

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Welcome,\n$username',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Your Posts:',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('itemscollection')
                      .where('userId', isEqualTo: user.uid)
                      .snapshots(),
                  builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }

                    var userItems = snapshot.data?.docs ?? [];

                    return ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: userItems.length,
                      itemBuilder: (context, index) {
                        var item = userItems[index];
                        var itemName = item['itemName'];
                        var itemDescription = item['description'];
                        var imageUrl = item['images'] != null && item['images'].isNotEmpty
                            ? item['images'][0]
                            : null;
                        var itemType = item['Itemtype'] == 'Found' ? 'Found item' : 'Lost item';

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
                                                'Image not available',
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
                                    itemType,
                                    style: TextStyle(fontSize: 16, color: Colors.grey),
                                  ),
                                  SizedBox(height: 8.0),
                                  Text(
                                    itemName ?? '',
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                                  ),
                                  SizedBox(height: 8.0),
                                  Text(
                                    itemDescription ?? '',
                                    style: TextStyle(color: Colors.grey, fontSize: 16),
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
              ],
            ),
          );
        },
      ),
      floatingActionButton: SpeedDial(
        child: const Icon(Icons.add),
        speedDialChildren: <SpeedDialChild>[
          SpeedDialChild(
            child: const Icon(Icons.add),
            label: 'Add Item Found',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddFoundItemPage()), // Navigate to AddFoundItemPage
              );
            },
          ),
          SpeedDialChild(
            child: const Icon(Icons.remove), // Change the icon to minus
            label: 'Add Item Lost',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddLostItemPage()), // Navigate to AddLostItemPage
              );
            },
          ),
        ],
        closedForegroundColor: Colors.black,
        openForegroundColor: Colors.white,
        closedBackgroundColor: Colors.white,
        openBackgroundColor: Colors.black,
      ),
    );
  }
}
