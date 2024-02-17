import 'package:flutter/material.dart';
import 'package:lostandfound/LostItemDetailsPage.dart'; // Import your LostItemDetailsPage widget here

class LostItemsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lost Items'),
      ),
      body: ListView.builder(
        itemCount: 10, // Change this to the actual number of lost items
        itemBuilder: (context, index) {
          // Replace this with your actual lost item widget
          return ListTile(
            title: Text('Lost Item ${index + 1}'),
            subtitle: Text('Description of lost item ${index + 1}'),
            leading: Icon(Icons.search),
            onTap: () {
              // Navigate to detailed view of the selected lost item
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LostItemDetailsPage()),
              );
            },
          );
        },
      ),
    );
  }
}
