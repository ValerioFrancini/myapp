import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart'; // For locale initialization

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensure Flutter is initialized
  await initializeDateFormatting('it', null); // Initialize locale for Italian
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Stocazzo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'davvero si fanno così i soldi? :/'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  final Map<String, int> _dailyCounts = {}; // Keeps track of daily cigarette counts
  bool _isExpanded = false; // Toggles the card expansion state

  // Method to get the current formatted date
  String getCurrentDate() {
    final now = DateTime.now();
    final formatter = DateFormat('EEEE, dd MMMM yyyy', 'it'); // Format in Italian
    return formatter.format(now);
  }

  // Save the count for the current day
  void _saveCountForToday() {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now()); // Use ISO format for keys
    _dailyCounts[today] = _counter;
  }

  // Get the data for the last 7 days
  List<BarChartGroupData> _getLast7DaysData() {
    final now = DateTime.now();
    List<BarChartGroupData> data = [];
    for (int i = 6; i >= 0; i--) {
      final day = now.subtract(Duration(days: i));
      final dayKey = DateFormat('yyyy-MM-dd').format(day);
      final count = _dailyCounts[dayKey] ?? 0;
      data.add(BarChartGroupData(
        x: 6 - i,
        barRods: [
          BarChartRodData(
            toY: count.toDouble(),
            width: 16,
            color: Colors.deepPurple,
          ),
        ],
      ));
    }
    return data;
  }

  void _incrementCounter() {
    setState(() {
      _counter++;
      _saveCountForToday();
    });
  }

  void _decrementCounter() {
    setState(() {
      if (_counter > 0) {
        _counter--;
        _saveCountForToday();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start, // Align content at the top
          children: <Widget>[
            const SizedBox(height: 20), // Space at the top
            GestureDetector(
              onTap: () {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              },
              child: Card(
                elevation: 4, // Adds shadow to the card
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), // Margin around the card
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0), // Padding inside the card
                      child: Text(
                        getCurrentDate(),
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ), // Style the date text
                        textAlign: TextAlign.center,
                      ),
                    ),
                    if (_isExpanded) // Show chart when expanded
                      Container(
                        height: 200,
                        padding: const EdgeInsets.all(16.0),
                        child: BarChart(
                         BarChartData(
  barGroups: _getLast7DaysData(),
  borderData: FlBorderData(show: false),
  gridData: FlGridData(show: false),
  titlesData: FlTitlesData(
    bottomTitles: AxisTitles(
      sideTitles: SideTitles(
        showTitles: true,
        getTitlesWidget: (value, _) {
          final now = DateTime.now().subtract(Duration(days: 6 - value.toInt()));
          return Text(
            DateFormat('EEE', 'it').format(now), // Short day name
            style: const TextStyle(fontSize: 10),
          );
        },
      ),
    ),
    leftTitles: AxisTitles(
      sideTitles: SideTitles(showTitles: false),
    ),
  ),
)
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 90), // Space between the card and the next text
            const Text(
              'Stai a fuma così:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 20), // Space between counter and buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FloatingActionButton(
                  onPressed: _decrementCounter,
                  tooltip: 'Decrement',
                  child: const Icon(Icons.remove),
                ),
                const SizedBox(width: 10), // Space between buttons
                FloatingActionButton(
                  onPressed: _incrementCounter,
                  tooltip: 'Increment',
                  child: const Icon(Icons.add),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
