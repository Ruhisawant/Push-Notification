import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class DetailsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Details')),
      body: Center(child: Text('Opened from Notification')),
    );
  }
}