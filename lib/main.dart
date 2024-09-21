import 'package:flutter/material.dart';
import 'package:intl/intl.dart';  // For date formatting

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Water Tracker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // Store current date
  DateTime selectedDate = DateTime.now();
  // Store drinks per day
  Map<String, List<Map<String, dynamic>>> drinksPerDay = {};

  // Controller for drink name and ml
  final TextEditingController drinkNameController = TextEditingController();
  final TextEditingController drinkMlController = TextEditingController();

  // Format the date
  String getFormattedDate(DateTime date) {
    return DateFormat('dd-MM-yyyy').format(date);
  }

  // Get the total ml for the current date
  int getTotalMlForDate() {
    String formattedDate = getFormattedDate(selectedDate);
    if (drinksPerDay.containsKey(formattedDate)) {
      return drinksPerDay[formattedDate]!
      .fold(0, (sum, drink) => sum + (drink['ml'] as int));
    }
    return 0;
  }

  // Add a drink
  void addDrink(String name, int ml) {
    String formattedDate = getFormattedDate(selectedDate);
    setState(() {
      if (!drinksPerDay.containsKey(formattedDate)) {
        drinksPerDay[formattedDate] = [];
      }
      drinksPerDay[formattedDate]!.add({'name': name, 'ml': ml});
    });
  }

  // Delete a drink
  void deleteDrink(int index) {
    String formattedDate = getFormattedDate(selectedDate);
    setState(() {
      drinksPerDay[formattedDate]!.removeAt(index);
    });
  }

  // Go to the previous day
  void previousDay() {
    setState(() {
      selectedDate = selectedDate.subtract(Duration(days: 1));
    });
  }

  // Go to the next day
  void nextDay() {
    setState(() {
      selectedDate = selectedDate.add(Duration(days: 1));
    });
  }

  @override
  Widget build(BuildContext context) {
    String formattedDate = getFormattedDate(selectedDate);
    List<Map<String, dynamic>> drinks = drinksPerDay[formattedDate] ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text('Water Tracker'),
      ),
      body: Column(
        children: <Widget>[
          SizedBox(height: 20),

          // Date with Left and Right buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: Icon(Icons.arrow_left),
                onPressed: previousDay,
              ),
              Text(
                formattedDate,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: Icon(Icons.arrow_right),
                onPressed: nextDay,
              ),
            ],
          ),

          SizedBox(height: 20),

          // Total ML Count
          Text(
            'Total ML: ${getTotalMlForDate()}',
            style: TextStyle(fontSize: 24),
          ),

          SizedBox(height: 20),

          // List of drinks
          Expanded(
            child: ListView.builder(
              itemCount: drinks.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(drinks[index]['name']),
                  subtitle: Text('${drinks[index]['ml']} ml'),
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text("Delete Drink"),
                            content: Text("Are you sure you want to delete this drink?"),
                            actions: [
                              TextButton(
                                child: Text("Cancel"),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                              TextButton(
                                child: Text("Delete"),
                                onPressed: () {
                                  deleteDrink(index);
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                );
              },
            ),
          ),

          // Add Drink Button
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text("Add Drink"),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextField(
                            controller: drinkNameController,
                            decoration: InputDecoration(labelText: 'Drink Name'),
                          ),
                          TextField(
                            controller: drinkMlController,
                            decoration: InputDecoration(labelText: 'ML'),
                            keyboardType: TextInputType.number,
                          ),
                        ],
                      ),
                      actions: [
                        TextButton(
                          child: Text("Cancel"),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                        TextButton(
                          child: Text("Add"),
                          onPressed: () {
                            String name = drinkNameController.text;
                            int ml = int.parse(drinkMlController.text);
                            addDrink(name, ml);
                            drinkNameController.clear();
                            drinkMlController.clear();
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    );
                  },
                );
              },
              child: Text('Add Drink'),
            ),
          ),
        ],
      ),
    );
  }
}
