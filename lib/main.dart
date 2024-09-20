import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: WhiteScreen(),
    );
  }
}

class WhiteScreen extends StatefulWidget {
  @override
  _WhiteScreenState createState() => _WhiteScreenState();
}

class _WhiteScreenState extends State<WhiteScreen> {
  List<Map<String, dynamic>> drinks = []; // List to store drinks

  void _showAddDrinkDialog() {
    String drinkName = '';
    String mlCount = '';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Drink'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(labelText: 'Drink Name'),
                onChanged: (value) {
                  drinkName = value;
                },
              ),
              TextField(
                decoration: InputDecoration(labelText: 'ML Count'),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  mlCount = value;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: Text('Add Drink'),
              onPressed: () {
                if (drinkName.isNotEmpty && mlCount.isNotEmpty) {
                  setState(() {
                    drinks.add({
                      'name': drinkName,
                      'ml': int.tryParse(mlCount) ?? 0,
                    });
                  });
                  Navigator.of(context).pop(); // Close dialog
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmationDialog(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Drink'),
          content: Text('Are you sure you want to delete this drink?'),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Delete'),
              onPressed: () {
                setState(() {
                  drinks.removeAt(index);
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  int get totalMl {
    return drinks.fold(0, (sum, drink) => sum + (drink['ml'] as int));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('WaterMinder'),
      ),
      body: Column(
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Text(
                'Total ML: $totalMl',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: drinks.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(drinks[index]['name']),
                  subtitle: Text('${drinks[index]['ml']} ml'),
                  trailing: IconButton(
                    icon: Icon(Icons.close, color: Colors.red),
                    onPressed: () => _showDeleteConfirmationDialog(index),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDrinkDialog,
        child: Icon(Icons.add),
        backgroundColor: Colors.blue,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
