import 'package:flutter/material.dart';

class AddLostItemPage extends StatefulWidget {
  @override
  _AddLostItemPageState createState() => _AddLostItemPageState();
}

class _AddLostItemPageState extends State<AddLostItemPage> {
  String itemName = '';
  String description = '';
  String placeFound = '';
  String contactInfo = '';

  // Function to handle adding an image
  void _addImage() {
    // Implement logic to add an image from camera or files
  }

  // Function to handle submitting the post
  void _submitPost() {
    // Implement logic to submit the post with provided details
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Lost Item'), // Set the title for adding a lost item
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GestureDetector(
              onTap: _addImage,
              child: Container(
                width: double.infinity,
                height: 200,
                color: Colors.grey.withOpacity(0.5),
                child: Center(
                  child: Icon(
                    Icons.add_photo_alternate,
                    size: 48.0,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            SizedBox(height: 16.0),
            TextFormField(
              decoration: InputDecoration(labelText: 'Item Name'),
              onChanged: (value) {
                setState(() {
                  itemName = value;
                });
              },
            ),
            SizedBox(height: 16.0),
            TextFormField(
              decoration: InputDecoration(labelText: 'Description'),
              onChanged: (value) {
                setState(() {
                  description = value;
                });
              },
            ),
            SizedBox(height: 16.0),
            TextFormField(
              decoration: InputDecoration(labelText: 'Place Found'),
              onChanged: (value) {
                setState(() {
                  placeFound = value;
                });
              },
            ),
            SizedBox(height: 16.0),
            TextFormField(
              decoration: InputDecoration(labelText: 'Contact Information'),
              onChanged: (value) {
                setState(() {
                  contactInfo = value;
                });
              },
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _submitPost,
              child: Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}