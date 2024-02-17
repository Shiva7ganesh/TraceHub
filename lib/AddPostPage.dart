import 'package:flutter/material.dart';
import 'package:lostandfound/AddFoundItemPage.dart'; // Import your AddLostItemPage widget here
import 'package:lostandfound/AddLostItemPage.dart'; // Import your AddFoundItemPage widget here

class AddPostPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Post'),
      ),
      body: Stack(
        children: [
          Positioned(
            bottom: 16.0,
            right: 16.0,
            child: GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text("Choose Post Type"),
                      content: SingleChildScrollView(
                        child: ListBody(
                          children: <Widget>[
                            GestureDetector(
                              child: Text("Lost Item"),
                              onTap: () {
                                Navigator.of(context).pop();
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => AddLostItemPage()),
                                );
                              },
                            ),
                            SizedBox(height: 20),
                            GestureDetector(
                              child: Text("Found Item"),
                              onTap: () {
                                Navigator.of(context).pop();
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => AddFoundItemPage()),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
              child: Container(
                width: 60.0,
                height: 60.0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.blue,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      spreadRadius: 2.0,
                      blurRadius: 5.0,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.add_box,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}