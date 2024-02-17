import 'package:flutter/material.dart';

class AddFoundItemPage extends StatefulWidget {
  @override
  _AddFoundItemPageState createState() => _AddFoundItemPageState();
}

class _AddFoundItemPageState extends State<AddFoundItemPage> {
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
        title: Text('Add Found Item'), // Set the title for adding a found item
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
