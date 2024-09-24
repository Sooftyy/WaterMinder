import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date formatting

// Import the language files
import 'lang/en.dart';
import 'lang/de.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WaterMinder',
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
  DateTime selectedDate = DateTime.now();
  Map<String, List<Map<String, dynamic>>> drinksPerDay = {};

  final TextEditingController drinkNameController = TextEditingController();
  final TextEditingController drinkMlController = TextEditingController();

  // State for language and date format
  String _currentLanguage = 'English'; // Default language
  String _currentDateFormat = 'MM.dd.yyyy'; // Default date format
  bool _isDrawerOpen = false;

  // Get localized strings based on the current language
  Map<String, String> _getLocalizedStrings() {
    if (_currentLanguage == 'English') {
      return en;
    } else {
      return de;
    }
  }

  String getFormattedDate(DateTime date) {
    return DateFormat(_currentDateFormat).format(date);
  }

  bool isToday() {
    return selectedDate.year == DateTime.now().year &&
        selectedDate.month == DateTime.now().month &&
        selectedDate.day == DateTime.now().day;
  }

  int getTotalMlForDate() {
    String formattedDate = getFormattedDate(selectedDate);
    if (drinksPerDay.containsKey(formattedDate)) {
      return drinksPerDay[formattedDate]!
          .fold(0, (sum, drink) => sum + (drink['ml'] as int));
    }
    return 0;
  }

  void addDrink(String name, int ml) {
    String formattedDate = getFormattedDate(selectedDate);
    setState(() {
      if (!drinksPerDay.containsKey(formattedDate)) {
        drinksPerDay[formattedDate] = [];
      }
      drinksPerDay[formattedDate]!.add({'name': name, 'ml': ml});
    });
  }

  void deleteDrink(int index) {
    String formattedDate = getFormattedDate(selectedDate);
    setState(() {
      drinksPerDay[formattedDate]!.removeAt(index);
    });
  }

  void previousDay() {
    setState(() {
      selectedDate = selectedDate.subtract(Duration(days: 1));
    });
  }

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
        title: Text('WaterMinder'),
        actions: [
          IconButton(
            icon: Icon(Icons.menu),
            onPressed: () {
              setState(() {
                _isDrawerOpen = !_isDrawerOpen;
              });
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: <Widget>[
              SizedBox(height: 20),

              // Date with Left and Right buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Left button
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                        ),
                        onPressed: previousDay,
                        child: Icon(Icons.arrow_left,
                            size: 30, color: Colors.blue),
                      ),
                    ),
                  ),

                  // Centered Date
                  Expanded(
                    child: Center(
                      child: Text(
                        formattedDate,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          decoration: isToday()
                              ? TextDecoration.underline
                              : TextDecoration.none,
                        ),
                      ),
                    ),
                  ),

                  // Right button
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                        ),
                        onPressed: nextDay,
                        child: Icon(Icons.arrow_right,
                            size: 30, color: Colors.blue),
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 20),

              // Total ML Count
              Text(
                '${_getLocalizedStrings()['total_ml']}: ${getTotalMlForDate()}',
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
                                title: Text(_getLocalizedStrings()['delete']!),
                                content: Text(_getLocalizedStrings()[
                                'confirm_delete_drink']!),
                                actions: [
                                  TextButton(
                                    child: Text(_getLocalizedStrings()[
                                    'cancel']!),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                  TextButton(
                                    child: Text(_getLocalizedStrings()[
                                    'delete']!),
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
                          title: Text(_getLocalizedStrings()['add_drink']!),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TextField(
                                controller: drinkNameController,
                                decoration: InputDecoration(
                                    labelText: _getLocalizedStrings()[
                                    'drink_name']!),
                              ),
                              TextField(
                                controller: drinkMlController,
                                decoration: InputDecoration(
                                    labelText:
                                    _getLocalizedStrings()['ml']!),
                                keyboardType: TextInputType.number,
                              ),
                            ],
                          ),
                          actions: [
                            TextButton(
                              child: Text(
                                  _getLocalizedStrings()['cancel']!),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                            TextButton(
                              child: Text(
                                  _getLocalizedStrings()['add']!),
                              onPressed: () {
                                String name =
                                    drinkNameController.text;
                                int ml = int.parse(
                                    drinkMlController.text);
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
                  child: Text(_getLocalizedStrings()['add_drink']!),
                ),
              ),
            ],
          ),

          // Sidebar
          if (_isDrawerOpen) _buildDrawer(),
        ],
      ),
    );
  }

  // Sidebar Drawer
  Widget _buildDrawer() {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        width: 250,
        color: Colors.grey[200],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              title: Text(_getLocalizedStrings()['language']!),
              onTap: () {
                setState(() {
                  _isDrawerOpen = false;
                  _showLanguageSelection();
                });
              },
            ),
            ListTile(
              title: Text(_getLocalizedStrings()['time_format']!),
              onTap: () {
                setState(() {
                  _isDrawerOpen = false;
                  _showTimeFormatSelection();
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  // Language Selection Dialog
  void _showLanguageSelection() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(_getLocalizedStrings()['select_language']!),
          content: DropdownButton<String>(
            value: _currentLanguage,
            items: [
              DropdownMenuItem(
                child: Text('English'),
                value: 'English',
              ),
              DropdownMenuItem(
                child: Text('German'),
                value: 'German',
              ),
            ],
            onChanged: (value) {
              setState(() {
                _currentLanguage = value!;
              });
              Navigator.of(context).pop();
            },
          ),
        );
      },
    );
  }

  // Time Format Selection Dialog
  void _showTimeFormatSelection() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(_getLocalizedStrings()['select_time_format']!),
          content: DropdownButton<String>(
            value: _currentDateFormat,
            items: [
              DropdownMenuItem(
                child: Text('MM.dd.yyyy'),
                value: 'MM.dd.yyyy',
              ),
              DropdownMenuItem(
                child: Text('dd.MM.yyyy'),
                value: 'dd.MM.yyyy',
              ),
            ],
            onChanged: (value) {
              setState(() {
                _currentDateFormat = value!;
              });
              Navigator.of(context).pop();
            },
          ),
        );
      },
    );
  }
}
