import 'package:flutter/material.dart';
import 'package:simple_speed_dial/simple_speed_dial.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'AddFoundItemPage.dart';
import 'AddLostItemPage.dart';
import 'FoundItemDetailsPage.dart';

class FoundItemsPage extends StatefulWidget {
  @override
  _FoundItemsPageState createState() => _FoundItemsPageState();
}

class _FoundItemsPageState extends State<FoundItemsPage> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Found Items'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: ItemSearchDelegate(),
              ).then((query) {
                if (query != null && query.isNotEmpty) {
                  setState(() {
                    _searchQuery = query;
                  });
                }
              });
            },
          ),
        ],
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('items')
            .where('Itemtype', isEqualTo: 'Found')
            .orderBy('timestamp', descending: true) // Ensure proper sorting
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          var filteredDocs = snapshot.data!.docs.where((item) {
            return item['itemName']
                .toString()
                .toLowerCase()
                .contains(_searchQuery.toLowerCase());
          }).toList();

          if (filteredDocs.isEmpty) {
            return Center(child: Text('No posts found'));
          }

          return ListView.builder(
            itemCount: filteredDocs.length,
            itemBuilder: (context, index) {
              var item = filteredDocs[index];
              var itemName = item['itemName'];
              var itemDescription = item['description'];
              var imageUrl = item['images'] != null && item['images'].isNotEmpty
                  ? item['images'][0]
                  : null;

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => FoundItemDetailsPage(item: item)),
                  );
                },
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        AspectRatio(
                          aspectRatio: 1,
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.grey,
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
                                      'Image Not Available',
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
                        Text(
                          itemName ?? '',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
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

class ItemSearchDelegate extends SearchDelegate<String> {
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: AnimatedIcon(
        icon: AnimatedIcons.menu_arrow,
        progress: transitionAnimation,
      ),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    close(context, query);
    return Container();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return Container();
  }
}
