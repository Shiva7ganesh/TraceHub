import 'package:flutter/material.dart';
import 'found_item_details_page.dart'; // Import your FoundItemDetailsPage widget here
import 'AddPostPage.dart';
class FoundItemsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Found Items'), // Update the title here
      ),
      body: ListView.builder(
        itemCount: 10, // Change this to the actual number of found items
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => FoundItemDetailsPage()),
              );
            },
            child: Card(
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      width: double.infinity,
                      height: 200, // Increase the image size here
                      child: AspectRatio(
                        aspectRatio: 1, // Square image
                        child: Container(
                          color: Colors.grey, // Replace with your image widget or network image
                          // child: Image.asset('assets/image_placeholder.jpg', fit: BoxFit.cover),
                        ),
                      ),
                    ),
                    SizedBox(height: 16.0),
                    Text(
                      'Found Item ${index + 1}', // Update the text here
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    SizedBox(height: 8.0),
                    Text(
                      'Description of found item ${index + 1}', // Update the text here
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
        floatingActionButton: FloatingActionButton(
        onPressed: () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => AddPostPage()), // Navigate to AddPostPage
      );
      },
        child: Icon(Icons.add),
      ),
    );
  }
}
