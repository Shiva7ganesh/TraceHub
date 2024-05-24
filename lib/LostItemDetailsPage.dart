import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LostItemDetailsPage extends StatelessWidget {
  final QueryDocumentSnapshot item;

  const LostItemDetailsPage({Key? key, required this.item}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Retrieve date and time from the item data
    Timestamp? timestamp = item['dateTimeLost'] as Timestamp?;
    DateTime? dateTimeLost = timestamp?.toDate();
    final User? currentUser = FirebaseAuth.instance.currentUser;
    final bool isOwner = currentUser?.uid == item['userId'];

    return Scaffold(
      appBar: AppBar(
        title: Text('Lost Item Details'),
        actions: [
          if (isOwner)
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
                  await FirebaseFirestore.instance.runTransaction((Transaction myTransaction) async {
                    myTransaction.delete(item.reference);
                  });
                  Navigator.of(context).pop();
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
              height: 400, // Increase the image container height
              color: Colors.grey, // Set container color to grey
              child: item['images'] != null && item['images'].isNotEmpty
                  ? ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: item['images'].length,
                separatorBuilder: (context, index) => SizedBox(width: 10), // Add a small gap between the images
                itemBuilder: (context, index) {
                  return Container(
                    width: 400, // Set both width and height to maintain a square shape
                    height: 400, // Set both width and height to maintain a square shape
                    child: Image.network(
                      item['images'][index] as String,
                      fit: BoxFit.cover,
                    ),
                  );
                },
              )
                  : Center(
                child: Text(
                  'Image not available',
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
            // Place lost
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Place Lost: ',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 5),
                  Text(
                    item['placeLost'] ?? 'No Place Lost',
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
                    'Contact Information: ',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 5),
                  Text(
                    item['contactInfo'] ?? 'No Contact Information',
                    style: TextStyle(fontSize: 18),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),
            // Date and time lost
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Date and Time Lost: ',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 5),
                  Text(
                    // Format the date and time manually
                    dateTimeLost != null
                        ? '${_formatTwoDigits(dateTimeLost.day)}-${_formatTwoDigits(dateTimeLost.month)}-${dateTimeLost.year} '
                        '${_formatTwoDigits(dateTimeLost.hour > 12 ? dateTimeLost.hour - 12 : dateTimeLost.hour)}:'
                        '${_formatTwoDigits(dateTimeLost.minute)} '
                        '${dateTimeLost.hour >= 12 ? 'PM' : 'AM'}'
                        : 'No Date and Time Lost',
                    style: TextStyle(fontSize: 18),
                  ),
                ],
              ),
            ),
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
}