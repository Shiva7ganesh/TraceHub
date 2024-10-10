import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lostandfound/app_state.dart';

class FoundItemDetailsPage extends StatelessWidget {
  final QueryDocumentSnapshot item;
  final bool isAdmin; // New: Flag to determine if the user is an admin

  const FoundItemDetailsPage({Key? key, required this.item, required this.isAdmin}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Retrieve date and time from the item data
    Timestamp? timestamp = item['dateTimeFound'] as Timestamp?;
    DateTime? dateTimeFound = timestamp?.toDate();
    final User? currentUser = FirebaseAuth.instance.currentUser;
    final bool isOwner = currentUser?.uid == item['userId'];

    return Scaffold(
      appBar: AppBar(
        title: Text('Found Item Details'),
        actions: [
          // Show delete button only if the current user is the owner or an admin
          if (isOwner || isAdmin)
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: () async {
                final bool confirmed = await showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('Confirm Delete'),
                      content: Text('Are you sure you want to delete this Post?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          child: Text('Delete'),
                        ),
                      ],
                    );
                  },
                ) ?? false;

                if (confirmed) {
                  // Show loading indicator
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (BuildContext context) {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    },
                  );

                  try {
                    // Delete images from storage
                    List<dynamic> images = item['images'] ?? [];
                    for (String imageUrl in images) {
                      await _deleteImageFromStorage(imageUrl);
                    }

                    // Delete item from Firestore
                    await FirebaseFirestore.instance.runTransaction((Transaction myTransaction) async {
                      myTransaction.delete(item.reference);
                    });

                    Navigator.of(context).pop(); // Close the loading indicator
                    Navigator.of(context).pop(); // Go back to the previous screen

                    // Show confirmation message
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Post deleted successfully')),
                    );
                  } catch (e) {
                    Navigator.of(context).pop(); // Close the loading indicator
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error deleting post: $e')),
                    );
                  }
                }
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Item images
            Container(
              height: 400,
              color: Colors.grey,
              child: item['images'] != null && item['images'].isNotEmpty
                  ? ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: item['images'].length,
                separatorBuilder: (context, index) => SizedBox(width: 10),
                itemBuilder: (context, index) {
                  return Container(
                    width: 400,
                    height: 400,
                    child: Image.network(
                      item['images'][index] as String,
                      fit: BoxFit.cover,
                    ),
                  );
                },
              )
                  : Center(
                child: Text(
                  'Image Not Available',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            SizedBox(height: 20),
            // Item name
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Item Name: ',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue),
                      ),
                      SizedBox(width: 5),
                      Text(
                        item['itemName'] ?? 'No Item Name',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            // Description
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Description: ',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 5),
                  Text(
                    item['description'] ?? 'No Description',
                    style: TextStyle(fontSize: 18),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),
            // Place found
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Place Found: ',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 5),
                  Text(
                    item['placeFound'] ?? 'No Place Found',
                    style: TextStyle(fontSize: 18),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),
            // Contact information
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Collect From: ', // Updated label to 'Collect From'
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 5),
                  Text(
                    item['collectFrom'] ?? 'No Collect From Information', // Updated to use 'collectFrom' field
                    style: TextStyle(fontSize: 18),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),
            // Date and time found
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Date and Time Found: ',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 5),
                  Text(
                    // Format the date and time manually
                    dateTimeFound != null
                        ? '${_formatTwoDigits(dateTimeFound.day)}-${_formatTwoDigits(dateTimeFound.month)}-${dateTimeFound.year} '
                        '${_formatTwoDigits(dateTimeFound.hour > 12 ? dateTimeFound.hour - 12 : dateTimeFound.hour)}:'
                        '${_formatTwoDigits(dateTimeFound.minute)} '
                        '${dateTimeFound.hour >= 12 ? 'PM' : 'AM'}'
                        : 'Not Available',
                    style: TextStyle(fontSize: 18),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),
            // New: Display user name and roll number if the current user is an admin
            if (isAdmin)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Posted By: ',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 5),
                    FutureBuilder<DocumentSnapshot>(
                      future: FirebaseFirestore.instance.collection('users').doc(item['userId']).get(),
                      builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                        if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        }

                        if (snapshot.connectionState == ConnectionState.done) {
                          Map<String, dynamic>? data = snapshot.data?.data() as Map<String, dynamic>?;

                          if (data != null) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Name: ${data['username'] ?? 'No Name'}',
                                  style: TextStyle(fontSize: 18),
                                ),
                                SizedBox(height: 5),
                                Text(
                                  'Email: ${data['email'] ?? 'No Email'}',
                                  style: TextStyle(fontSize: 18),
                                ),
                                SizedBox(height: 15),
                              ],
                            );
                          }
                        }

                        return Text('Loading...');
                      },
                    ),
                  ],
                ),
              ),
            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  // Helper function to format digits with leading zeros
  String _formatTwoDigits(int n) {
    if (n >= 10) {
      return '$n';
    }
    return '0$n';
  }

  // Helper function to delete images from Firebase Storage
  Future<void> _deleteImageFromStorage(String imageUrl) async {
    try {
      final firebase_storage.Reference storageRef = firebase_storage.FirebaseStorage.instance.refFromURL(imageUrl);
      await storageRef.delete();
    } catch (e) {
      print('Error deleting image from storage: $e');
    }
  }
}
