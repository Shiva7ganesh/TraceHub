import 'package:flutter/material.dart';

class LostItemDetailsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lost Item Details'),
      ),
      body: const Center(
        child: Text('Detailed view of the selected lost item'),
      ),
    );
  }
}
