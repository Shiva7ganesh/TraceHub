import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:cloud_firestore/cloud_firestore.dart';

import 'MyHomePage.dart';

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
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>(); // Form key to manage form state

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
      print('Error taking a picture: $e');
    }
  }

  // Function to handle submitting the post
  Future<void> _submitPost() async {
    // Validate form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true; // Set loading state to true when submitting
    });

    try {
      // Upload images to Firebase Storage
      List<String> imageUrls = await _uploadImages();

      // Create a reference to the Firestore collection
      CollectionReference foundItems =
      FirebaseFirestore.instance.collection('found_items');

      // Add a new document with the provided data
      await foundItems.add({
        'itemName': itemName,
        'description': description,
        'placeFound': placeFound,
        'contactInfo': contactInfo,
        'images': imageUrls,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Clear form and imageUrls after successful submission
      _clearForm();

      // Show success message
      // Show success popup
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Submitted Successfully'),
            content: Text('Your found item has been submitted successfully.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  // Navigate to the home page
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MyHomePage(),
                    ),
                  );
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    } catch (e) {
      print('Error submitting post: $e');
      // Show error message if submission fails
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('Failed to submit item. Please try again.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    } finally {
      setState(() {
        _isLoading = false; // Set loading state to false after submission
      });
    }
  }

  // Function to upload images to Firebase Storage
  Future<List<String>> _uploadImages() async {
    List<String> imageUrls = [];

    try {
      for (File image in _pickedImages) {
        // Generate a unique filename
        String imageName = DateTime.now().millisecondsSinceEpoch.toString();

        // Get the reference for the image to be stored
        firebase_storage.Reference ref = firebase_storage
            .FirebaseStorage.instance
            .ref()
            .child('images/$imageName');

        // Upload the file to Firebase Storage
        await ref.putFile(image);

        // Get the download URL
        String imageUrl = await ref.getDownloadURL();

        // Add the URL to the list
        imageUrls.add(imageUrl);
      }
    } catch (e) {
      print('Error uploading images: $e');
    }

    return imageUrls;
  }

  // Function to clear the form and imageUrls
  void _clearForm() {
    setState(() {
      itemName = '';
      description = '';
      placeFound = '';
      contactInfo = '';
      _pickedImages = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Found Item'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
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
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Item name is required';
                  }
                  return null;
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
                decoration: InputDecoration(
                    labelText: 'Contact Information (Optional)'),
                onChanged: (value) {
                  setState(() {
                    contactInfo = value;
                  });
                },
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _isLoading ? null : _submitPost,
                child: _isLoading ? CircularProgressIndicator() : Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
