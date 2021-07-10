import 'package:flutter/material.dart';

class NewRoad extends StatefulWidget {
  const NewRoad({Key? key}) : super(key: key);

  @override
  _NewRoadState createState() => _NewRoadState();
}

class _NewRoadState extends State<NewRoad> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add a Road'),
      ),
      body: Padding(
        padding: EdgeInsets.all(8.0),
        child: Column(
          children: [
            SizedBox(
              height: 20.0,
            ),
            Text(
              'Please add the Road Name',
              style: TextStyle(
                fontSize: 15.0,
              ),
            ),
            SizedBox(
              height: 20.0,
            ),
            TextField(
              controller: _controller,
              onSubmitted: (value) {
                Navigator.pop(context, value);
              },
            )
          ],
        ),
      ),
    );
  }
}
