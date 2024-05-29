import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:insta_assets_picker/insta_assets_picker.dart';
import 'package:intl/intl.dart';

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
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  String? organizationId;
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _fetchOrganizationId();
  }

  Future<void> _fetchOrganizationId() async {
    String? orgId = await getOrganizationId();
    setState(() {
      organizationId = orgId;
    });
  }

  Future<void> _addImage() async {
    try {
      final pickedAssets = await InstaAssetPicker.pickAssets(
        context,
        title: 'Select images',
        maxAssets: 2,
        onCompleted: (Stream<InstaAssetsExportDetails> stream) async {
          await for (InstaAssetsExportDetails details in stream) {
            setState(() {
              _pickedImages.addAll(details.croppedFiles);
            });
            if (_pickedImages.length > 1) {
              _pickedImages.removeAt(0);
            }
          }
          Navigator.pop(context);
        },
      );
      if (pickedAssets == null || pickedAssets.isEmpty) {
        return;
      }
      for (int i = 0; i < _pickedImages.length; i++) {
        File compressedImage = await _compressImage(_pickedImages[i]);
        _pickedImages[i] = compressedImage;
      }
    } catch (e) {
      print('Error picking images: $e');
    }
  }

  Future<File> _compressImage(File image) async {
    // Check the size of the image
    int maxSizeInBytes = 500 * 1024; // 500 KB
    int fileSizeInBytes = await image.length();
    if (fileSizeInBytes <= maxSizeInBytes) {
      // If image is already below 500KB, return original image
      return image;
    }

    // Compress the image
    Uint8List? compressedImageBytes = await FlutterImageCompress.compressWithFile(
      image.path,
      quality: 70, // Adjust the quality as needed
    );

    if (compressedImageBytes == null) {
      // Compression failed, return original image
      return image;
    }

    // Save the compressed image to a new file
    File compressedImage = File('${image.path}_compressed.jpg');
    await compressedImage.writeAsBytes(compressedImageBytes);

    return compressedImage;
  }

  Future<void> _takePicture() async {
    final picker = ImagePicker();

    try {
      final pickedImage = await picker.pickImage(source: ImageSource.camera);
      if (pickedImage == null) {
        return;
      }

      final imageCropper = ImageCropper();

      final croppedImage = await imageCropper.cropImage(
        sourcePath: pickedImage.path,
        aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
        compressQuality: 30,
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

      final Items = FirebaseFirestore.instance.collection('items');

      final currentUser = FirebaseAuth.instance.currentUser;
      final userId = currentUser?.uid;

      // Allow dateTimeFound to be null if neither date nor time is selected
      DateTime? combinedDateTime;
      if (selectedDate != null || selectedTime != null) {
        combinedDateTime = DateTime(
          selectedDate?.year ?? DateTime.now().year,
          selectedDate?.month ?? DateTime.now().month,
          selectedDate?.day ?? DateTime.now().day,
          selectedTime?.hour ?? 0,
          selectedTime?.minute ?? 0,
        );
      }

      await Items.add({
        'itemName': itemName,
        'description': description,
        'placeFound': placeFound,
        'contactInfo': contactInfo,
        'images': imageUrls,
        'userId': userId,
        'organizationId': 'CMRIT',
        'timestamp': FieldValue.serverTimestamp(),
        'dateTimeFound': combinedDateTime,
        'Itemtype': 'Found', // Store combined DateTime in Firestore
      });

      _clearForm();

      showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: Text('Submitted Successfully'),
          content: Text('Your found item has been submitted successfully.\nElectronics or jewelry? Please give them to the faculty or AO.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => MyHomePage()),
                      (Route<dynamic> route) => false,
                );
              },
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

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null && pickedDate != selectedDate) {
      setState(() {
        selectedDate = pickedDate;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime != null && pickedTime != selectedTime) {
      setState(() {
        selectedTime = pickedTime;
      });
    }
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
                  height: 300,
                  color: Colors.grey.withOpacity(0.5),
                  child: Center(
                    child: _pickedImages.isNotEmpty
                        ? ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _pickedImages.length,
                      itemBuilder: (context, index) {
                        return Container(
                          margin: EdgeInsets.all(4.0),
                          width: 300,
                          height: 300,
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
                    labelText: 'Contact Info (Mobile No or e.g., Given to AO)'),
                onChanged: (value) {
                  setState(() {
                    contactInfo = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Contact information is required';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              ListTile(
                title: Text(
                  'Date Found',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(selectedDate == null
                    ? 'Select Date'
                    : DateFormat('yyyy-MM-dd').format(selectedDate!)),
                onTap: () => _selectDate(context),
              ),
              ListTile(
                title: Text(
                  'Time Found',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(selectedTime == null
                    ? 'Select Time'
                    : selectedTime!.format(context)),
                onTap: () => _selectTime(context),
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

Future<String?> getOrganizationId() async {
  try {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      DocumentSnapshot userSnapshot =
      await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

      if (userSnapshot.exists) {
        Map<String, dynamic>? userData = userSnapshot.data() as Map<String, dynamic>?;

        if (userData != null && userData.containsKey('organizationId')) {
          return userData['organization'];
        }
      }
    }
  } catch (e) {
    print('Error getting organization ID: $e');
  }

  return null;
}