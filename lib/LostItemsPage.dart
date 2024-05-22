import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:simple_speed_dial/simple_speed_dial.dart';
import 'package:lostandfound/AddFoundItemPage.dart'; // Import your AddFoundItemPage widget here
import 'package:lostandfound/AddLostItemPage.dart'; // Import your AddLostItemPage widget here
import 'package:lostandfound/FoundItemDetailsPage.dart';
import 'package:lostandfound/LostItemDetailsPage.dart';

class LostItemsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lost Items'),
        automaticallyImplyLeading: false,
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('items')
            .where('Itemtype', isEqualTo: 'Lost')
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var item = snapshot.data!.docs[index];
              var itemName = item['itemName'] ?? 'No Name';
              var itemDescription = item['description'] ?? 'No Description';
              var images = item['images'] ?? [];
              var imageUrl = images.isNotEmpty ? images[0] : null;

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LostItemDetailsPage(item: item)),
                  );
                },
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        AspectRatio(
                          aspectRatio: 1, // Square aspect ratio
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.grey, // Change the color here
                            ),
                            child: Stack(
                              children: [
                                if (imageUrl != null)
                                  Image.network(
                                    imageUrl,
                                    fit: BoxFit.cover,
                                    loadingBuilder: (context, child, loadingProgress) {
                                      return AnimatedSwitcher(
                                        duration: Duration(milliseconds: 300),
                                        child: loadingProgress == null
                                            ? child
                                            : Center(
                                          child: CircularProgressIndicator(),
                                        ),
                                      );
                                    },
                                  ),
                                if (imageUrl == null)
                                  Center(
                                    child: Text(
                                      'Image not available',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 16.0),
                        Row(
                          children: [
                            SizedBox(width: 5),
                            Expanded(
                              child: Text(
                                itemName ?? '',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8.0),
                        Text(
                          itemDescription ?? '',
                          style: TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: SpeedDial(
        child: const Icon(Icons.add),
        speedDialChildren: <SpeedDialChild>[
          SpeedDialChild(
            child: const Icon(Icons.add),
            label: 'Add Item Found',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddFoundItemPage()),
              );
            },
          ),
          SpeedDialChild(
            child: const Icon(Icons.remove),
            label: 'Add Item Lost',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddLostItemPage()),
              );
            },
          ),
        ],
        closedForegroundColor: Colors.black,
        openForegroundColor: Colors.white,
        closedBackgroundColor: Colors.white,
        openBackgroundColor: Colors.black,
      ),
    );
  }
}