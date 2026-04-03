import 'package:flutter/material.dart';

class PatientHome extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Hello!", style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold)),
            SizedBox(height: 40),
            // A huge button for emergency or help
            Container(
              width: 200,
              height: 200,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red, shape: CircleBorder()),
                onPressed: () {},
                child: Text("HELP", style: TextStyle(color: Colors.white, fontSize: 30)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}