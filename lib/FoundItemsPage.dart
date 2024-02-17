import 'package:flutter/material.dart';
import 'package:simple_speed_dial/simple_speed_dial.dart';
import 'AddFoundItemPage.dart'; // Import your AddFoundItemPage widget here
import 'AddLostItemPage.dart'; // Import your AddLostItemPage widget here
import 'package:lostandfound/FoundItemDetailsPage.dart';
import 'package:lostandfound/LostItemDetailsPage.dart';

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
              // Navigate to FoundItemDetailsPage
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