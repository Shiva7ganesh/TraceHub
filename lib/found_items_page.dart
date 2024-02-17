import 'package:flutter/material.dart';
import 'package:lostandfound/found_item_details_page.dart'; // Import your FoundItemDetailsPage widget here

class FoundItemsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Found Items'),
      ),
      body: ListView.builder(
        itemCount: 10, // Change this to the actual number of found items
        itemBuilder: (context, index) {
          // Replace this with your actual found item widget
          return ListTile(
            title: Text('Found Item ${index + 1}'),
            subtitle: Text('Description of found item ${index + 1}'),
            leading: Icon(Icons.favorite),
            onTap: () {
              // Navigate to detailed view of the selected found item
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => FoundItemDetailsPage()),
              );
            },
          );
        },
      ),
    );
  }
}
