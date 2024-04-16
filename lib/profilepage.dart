import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late User _user; // Variable to hold the authenticated user

  @override
  void initState() {
    super.initState();
    _getUser(); // Call function to get the authenticated user
  }

  Future<void> _getUser() async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User? user = auth.currentUser;
    if (user != null) {
      setState(() {
        _user = user;
      });
    } else {
      // Handle case when user is not authenticated
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        automaticallyImplyLeading: false,
      ),
      body: _user != null
          ? _buildProfile()
          : Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildProfile() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Your existing profile information widgets here...

        Divider(), // Add a divider between profile and posts

        StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('lost_items')
              .where('userId', isEqualTo: _user.uid)
              .snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            return _buildItemsList(snapshot.data!.docs);
          },
        ),

        StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('found_items')
              .where('userId', isEqualTo: _user.uid)
              .snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            return _buildItemsList(snapshot.data!.docs);
          },
        ),
      ],
    );
  }

  Widget _buildItemsList(List<DocumentSnapshot> items) {
    return Expanded(
      child: ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) {
          var item = items[index];
          return _buildItemCard(item);
        },
      ),
    );
  }

  Widget _buildItemCard(DocumentSnapshot item) {
    var itemName = item['itemName'];
    var itemDescription = item['description'];
    var imageUrl = item['images'] != null && item['images'].isNotEmpty
        ? item['images'][0]
        : null; // Assuming images are stored as an array

    return GestureDetector(
      onTap: () {
        // Navigate to ItemDetailsPage
        // You can implement this based on your requirements
      },
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              AspectRatio(
                aspectRatio: 1, // Square aspect ratio
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey, // Change the color here
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
  }
}
