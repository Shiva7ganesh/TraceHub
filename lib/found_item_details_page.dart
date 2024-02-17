import 'package:flutter/material.dart';

class FoundItemDetailsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Found Item Details'),
      ),
      body: Center(
        child: Text('Detailed view of the selected found item'),
      ),
    );
  }
}
