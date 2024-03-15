import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class FoundItemDetailsPage extends StatelessWidget {
  final QueryDocumentSnapshot item;

  const FoundItemDetailsPage({Key? key, required this.item}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Found Item Details'),
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
          ],
        ),
      ),
    );
  }
}