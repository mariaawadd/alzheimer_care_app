import 'package:flutter/material.dart';

class CaregiverHome extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Caregiver Dashboard")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Welcome, Caregiver!", style: TextStyle(fontSize: 20)),
            SizedBox(height: 20),
            ElevatedButton(onPressed: () {}, child: Text("Add Patient Task")),
            ElevatedButton(onPressed: () {}, child: Text("View Patient Location")),
          ],
        ),
      ),
    );
  }
}