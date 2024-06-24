import 'package:flutter/material.dart';
import 'package:sheraccerp/util/jobcard_lists.dart';

class Complaints extends StatefulWidget {
  const Complaints({super.key});

  @override
  State<Complaints> createState() => _ComplaintsState();
}

class _ComplaintsState extends State<Complaints> {
  final TextEditingController _complaints = TextEditingController();
 
  @override
  void dispose() {
    _complaints.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Complaints',
          style: TextStyle(fontSize: 14),
        ),
      ),
      body: Column(
        children: <Widget>[
          SizedBox(
            height: 30,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _complaints,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Enter a Complaint',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    setState(() {
                      enteredComplaints.add(_complaints.text);
                      _complaints.clear();
                    });
                  },
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: enteredComplaints.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text('${index + 1} . ${enteredComplaints[index]}'),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
