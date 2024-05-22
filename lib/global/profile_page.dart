import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfilePage extends StatelessWidget {
  final String userId;

  ProfilePage({required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 20),
          Text(
            'Lost Items:',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: LostFoundItemsList(userId: userId, itemType: 'lost'),
          ),
          SizedBox(height: 20),
          Text(
            'Found Items:',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: LostFoundItemsList(userId: userId, itemType: 'found'),
          ),
        ],
      ),
    );
  }
}

class LostFoundItemsList extends StatelessWidget {
  final String userId;
  final String itemType;

  LostFoundItemsList({required this.userId, required this.itemType});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('lost_found_items')
          .where('userId', isEqualTo: userId)
          .where('type', isEqualTo: itemType)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        List<DocumentSnapshot> items = snapshot.data!.docs;

        if (items.isEmpty) {
          return Center(
            child: Text('No $itemType items found.'),
          );
        }

        return ListView.builder(
          itemCount: items.length,
          itemBuilder: (context, index) {
            var item = items[index].data() as Map<String, dynamic>;
            return ListTile(
              title: Text(item['title']),
              subtitle: Text(item['description']),
              // Add more details if needed
            );
          },
        );
      },
    );
  }
}
