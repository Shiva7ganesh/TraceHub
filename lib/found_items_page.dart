import 'package:flutter/material.dart';
import 'package:lostandfound/found_item_details_page.dart'; // Import your FoundItemDetailsPage widget here

class FoundItemsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Found Items'),
      ),
      body: ListView.builder(
        itemCount: 10, // Change this to the actual number of found items
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              // Navigate to detailed view of the selected found item
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => FoundItemDetailsPage(itemIndex: index)),
              );
            },
            child: Card(
              elevation: 3.0,
              margin: EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Placeholder(), // Placeholder for image
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'Found Item ${index + 1}',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      'Description of found item ${index + 1}',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
