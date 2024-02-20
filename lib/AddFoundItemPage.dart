import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:insta_assets_picker/insta_assets_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_cropper/image_cropper.dart';
// Import Insta Assets Picker

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

  Future<void> _addImage() async {
    try {
      final pickedAssets = await InstaAssetPicker.pickAssets(
        context,
        title: 'Select images',
        maxAssets: 10,
        onCompleted: (Stream<InstaAssetsExportDetails> stream) async {
          await for (InstaAssetsExportDetails details in stream) {
            setState(() {
              _pickedImages.addAll(details.croppedFiles);
            });
          }

          // Navigate back to the submit button page after selecting images
          Navigator.pop(context);
        },
      );
      if (pickedAssets == null || pickedAssets.isEmpty) {
        return;
      }
    } catch (e) {
      print('Error picking images: $e');
    }
  }

  Future<void> _takePicture() async {
    final picker = ImagePicker();

    try {
      final pickedImage = await picker.pickImage(source: ImageSource.camera);
      if (pickedImage == null) {
        return;
      }

      // Create an instance of ImageCropper
      final imageCropper = ImageCropper();

      // Crop the image
      final croppedImage = await imageCropper.cropImage(
        sourcePath: pickedImage.path,
        aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
        compressQuality: 100,
      );

      if (croppedImage != null) {
        setState(() {
          _pickedImages.add(File(croppedImage.path));
        });
      }
    } catch (e) {
      print('Error taking a picture: $e');
    }
  }



  Future<void> _submitPost() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final imageUrls = await _uploadImages();

      final foundItems = FirebaseFirestore.instance.collection('found_items');

      await foundItems.add({
        'itemName': itemName,
        'description': description,
        'placeFound': placeFound,
        'contactInfo': contactInfo,
        'images': imageUrls,
        'timestamp': FieldValue.serverTimestamp(),
      });

      _clearForm();

      showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: Text('Submitted Successfully'),
          content: Text('Your found item has been submitted successfully.'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => MyHomePage(),
                ),
              ),
              child: Text('OK'),
            ),
          ],
        ),
      );
    } catch (e) {
      print('Error submitting post: $e');
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content: Text('Failed to submit item. Please try again.'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK'),
            ),
          ],
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<List<String>> _uploadImages() async {
    final imageUrls = <String>[];

    try {
      for (final image in _pickedImages) {
        final imageName = DateTime.now().millisecondsSinceEpoch.toString();

        final ref = firebase_storage.FirebaseStorage.instance
            .ref()
            .child('images/$imageName');

        await ref.putFile(image);

        final imageUrl = await ref.getDownloadURL();

        imageUrls.add(imageUrl);
      }
    } catch (e) {
      print('Error uploading images: $e');
    }

    return imageUrls;
  }

  void _clearForm() {
    setState(() {
      itemName = '';
      description = '';
      placeFound = '';
      contactInfo = '';
      _pickedImages.clear();
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
                  height: 300, // Increased height of the container
                  color: Colors.grey.withOpacity(0.5),
                  child: Center(
                    child: _pickedImages.isNotEmpty
                        ? ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _pickedImages.length,
                      itemBuilder: (context, index) {
                        return Container(
                          margin: EdgeInsets.all(4.0),
                          width: 300, // Set both width and height to maintain a square shape
                          height: 300, // Set both width and height to maintain a square shape
                          child: Image.file(
                            _pickedImages[index],
                            fit: BoxFit.cover,
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