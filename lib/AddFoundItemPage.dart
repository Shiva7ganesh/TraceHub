import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class AddFoundItemPage extends StatefulWidget {
  @override
  _AddFoundItemPageState createState() => _AddFoundItemPageState();
}

class _AddFoundItemPageState extends State<AddFoundItemPage> {
  String itemName = '';
  String description = '';
  String placeFound = '';
  String contactInfo = '';
  List<File> _pickedImages = [];

  // Function to handle adding an image
  Future<void> _addImage() async {
    final picker = ImagePicker();

    try {
      // Pick multiple images from the gallery
      List<XFile>? pickedImages = await picker.pickMultiImage();

      // If no images were picked, return
      if (pickedImages == null || pickedImages.isEmpty) {
        return;
      }

      setState(() {
        // Convert XFile to File and add to the list
        _pickedImages.addAll(pickedImages.map((image) => File(image.path)));
      });
    } catch (e) {
      print('Error picking images: $e');
    }
  }

  // Function to handle taking a picture from the camera
  Future<void> _takePicture() async {
    final picker = ImagePicker();

    try {
      // Take a picture from the camera
      XFile? pickedImage = await picker.pickImage(source: ImageSource.camera);

      // If no image was picked, return
      if (pickedImage == null) {
        return;
      }

      setState(() {
        // Convert XFile to File and add to the list
        _pickedImages.add(File(pickedImage.path));
      });
    } catch (e) {
      print('Error taking picture: $e');
    }
  }

  // Function to handle submitting the post
  void _submitPost() {
    // Implement logic to submit the post with provided details
    // You can access the picked images from _pickedImages list
    // and other form fields (itemName, description, placeFound, contactInfo)
    // Use this data to upload to Firebase Storage or any other desired location.
    // Example: _pickedImages.forEach((image) => uploadImage(image));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Found Item'),
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
                  child: _pickedImages.isNotEmpty
                      ? ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _pickedImages.length,
                    itemBuilder: (context, index) {
                      return Container(
                        margin: EdgeInsets.all(4.0),
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: FileImage(_pickedImages[index]),
                            fit: BoxFit.cover,
                          ),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      );
                    },
                  )
                      : Icon(
                    Icons.add_photo_alternate,
                    size: 48.0,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: _addImage,
                  child: Text('Add from Gallery'),
                ),
                ElevatedButton(
                  onPressed: _takePicture,
                  child: Text('Take a Picture'),
                ),
              ],
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
