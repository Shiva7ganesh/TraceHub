import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:insta_assets_picker/insta_assets_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:intl/intl.dart';

import 'MyHomePage.dart';

class AddLostItemPage extends StatefulWidget {
  @override
  _AddLostItemPageState createState() => _AddLostItemPageState();
}

class _AddLostItemPageState extends State<AddLostItemPage> {
  String itemName = '';
  String description = '';
  String placeLost = '';
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
            if(_pickedImages.length>1)
              {
                _pickedImages.removeAt(0);
              }
          }
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

  Future<void> _submitPost() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (selectedDate == null || selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select both date and time.'),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final imageUrls = await _uploadImages();

      final items = FirebaseFirestore.instance.collection('items');

      final currentUser = FirebaseAuth.instance.currentUser;
      final userId = currentUser?.uid;

      DateTime combinedDateTime = DateTime(
        selectedDate!.year,
        selectedDate!.month,
        selectedDate!.day,
        selectedTime!.hour,
        selectedTime!.minute,
      );

      await items.add({
        'itemName': itemName,
        'description': description,
        'placeLost': placeLost,
        'contactInfo': contactInfo,
        'images': imageUrls,
        'userId': userId,
        'organizationId': 'CMRIT',
        'timestamp': FieldValue.serverTimestamp(),
        'dateTimeLost': combinedDateTime,
        'Itemtype': 'Lost',
      });

      _clearForm();

      showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: Text('Submitted Successfully'),
          content: Text('Your lost item has been submitted successfully.'),
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

        final compressedImage = await _compressImage(image);

        await ref.putFile(compressedImage);

        final imageUrl = await ref.getDownloadURL();

        imageUrls.add(imageUrl);
      }
    } catch (e) {
      print('Error uploading images: $e');
    }

    return imageUrls;
  }

  Future<File> _compressImage(File file) async {
    final filePath = file.absolute.path;
    final outPath = filePath.substring(0, filePath.lastIndexOf('.')) + '_compressed.jpg';

    final XFile? compressedXFile = await FlutterImageCompress.compressAndGetFile(
      filePath,
      outPath,
      quality: 85, // Adjust quality to maintain image size below 500KB
    );

    if (compressedXFile != null) {
      return File(compressedXFile.path);
    } else {
      return file;
    }
  }
  void _clearForm() {
    setState(() {
      itemName = '';
      description = '';
      placeLost = '';
      contactInfo = '';
      _pickedImages.clear();
      selectedDate = null;
      selectedTime = null;
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
        title: Text('Add Lost Item'),
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
              ElevatedButton(
                onPressed: _addImage,
                child: Text('Add from Gallery'),
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
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Description is required';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              TextFormField(
                decoration: InputDecoration(labelText: 'Place Lost'),
                onChanged: (value) {
                  setState(() {
                    placeLost = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Place lost is required';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              TextFormField(
                decoration: InputDecoration(labelText: 'Contact Information to Contact'),
                onChanged: (value) {
                  setState(() {
                    contactInfo = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Contact info is required';
                  }
                  else if( value.length != 10 || !RegExp(r'^[0-9]+$').hasMatch(value)){
                    return 'Enter Valid number';
                  }
                  return null;
                },
              ),
              ListTile(
                title: Text(
                  'Date Lost',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(selectedDate == null
                    ? 'Select Date'
                    : DateFormat.yMd().format(selectedDate!)),
                onTap: () => _selectDate(context),
              ),
              ListTile(
                title: Text(
                  'Time Lost',
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
