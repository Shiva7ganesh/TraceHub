import 'package:flutter/material.dart';

class LostItemDetailsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lost Item Details'),
      ),
      body: Center(
        child: Text('Detailed view of the selected lost item'),
      ),
    );
  }
}
