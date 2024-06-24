import 'package:flutter/material.dart';
import 'package:sheraccerp/util/jobcard_lists.dart';

class StandByItems extends StatefulWidget {
  const StandByItems({super.key});

  @override
  State<StandByItems> createState() => _StandByItemsState();
}

class _StandByItemsState extends State<StandByItems> {
  final TextEditingController _standbyitems = TextEditingController();
 
  @override
  void dispose() {
    _standbyitems.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Stand By Items',
          style: TextStyle(fontSize: 14),
        ),
      ),
      body: 
      Column(
        children: <Widget>[SizedBox(height: 30,),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _standbyitems,
              decoration: InputDecoration(border: OutlineInputBorder(),
                labelText: 'Enter a standby item',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    setState(() {
                      enteredValues.add(_standbyitems.text);
                      _standbyitems.clear();
                    });
                  },
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: enteredValues.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text('${index + 1} . ${enteredValues[index]}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      InkWell(
                        onTap: () {
                          setState(() {
                            _showEditDialog(index);
                          });
                        },
                        child: Container(
                            height: 35,
                            width: 35,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              color: Colors.indigo,
                            ),
                            child: const Icon(
                              Icons.edit,
                              color: Colors.white,
                            )),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      InkWell(
                        onTap: () {
                          setState(() {
                            enteredValues.removeAt(index);
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Item deleted')),
                          );
                        },
                        child: Container(
                            height: 35,
                            width: 35,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              color: Colors.red,
                            ),
                            child: const Icon(
                              Icons.delete_outline,
                              color: Colors.white,
                            )),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String newValue = enteredValues[index];
        return AlertDialog(
          title: const Text('Edit Item'),
          content: TextField(
            controller: TextEditingController(text: newValue),
            onChanged: (value) {
              newValue = value;
            },
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Save'),
              onPressed: () {
                setState(() {
                  enteredValues[index] = newValue;
                });
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Item Edited')),
                );
              },
            ),
          ],
        );
      },
    );
  }
}
