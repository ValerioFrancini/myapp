import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('it', null);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'eddainonfumare',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: '🛠✨'),
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
  final Map<String, int> _dailyCounts = {};
  final PageController _pageController = PageController(initialPage: 0);

  DateTime _currentWeek = _getMondayOfThisWeek();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _checkForNewDay();
  }

  static DateTime _getMondayOfThisWeek() {
    final now = DateTime.now();
    return now.subtract(Duration(days: now.weekday - 1)); // Lunedì della settimana corrente
  }

  void _updateWeek(int offset) {
    setState(() {
      _currentWeek = _currentWeek.add(Duration(days: 7 * offset));
    });
  }

  void _goToCurrentWeek() {
    setState(() {
      _currentPage = 0;
      _currentWeek = _getMondayOfThisWeek();
    });
    _pageController.animateToPage(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _saveCountForToday() {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    _dailyCounts[today] = _counter;
  }

  void _checkForNewDay() {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    if (!_dailyCounts.containsKey(today)) {
      setState(() {
        _counter = 0;
        _saveCountForToday();
      });
    }
  }

  List<BarChartGroupData> _getWeekData(DateTime weekStart) {
    List<BarChartGroupData> data = [];
    for (int i = 0; i < 7; i++) {
      final day = weekStart.add(Duration(days: i));
      final dayKey = DateFormat('yyyy-MM-dd').format(day);
      final count = _dailyCounts[dayKey] ?? 0;
      data.add(BarChartGroupData(
        x: i,
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
        actions: [
          IconButton(
            onPressed: _goToCurrentWeek,
            tooltip: 'Torna alla settimana corrente',
            icon: const Icon(Icons.today),
          ),
        ],
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            const SizedBox(height: 20),
            // PageView per lo swipe tra settimane
            SizedBox(
              height: 240, // Altezza complessiva della card ridotta
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  final offset = index - _currentPage;
                  _updateWeek(offset);
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  final weekStart = _currentWeek.add(Duration(days: 7 * index));
                  final weekTitle =
                      '${DateFormat('dd MMM', 'it').format(weekStart)} - ${DateFormat('dd MMM', 'it').format(weekStart.add(const Duration(days: 6)))}';

                  return Card(
                    elevation: 4,
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Text(
                            weekTitle,
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Container(
                          height: 170, // Altezza grafico ridotta
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: _getWeekData(weekStart).isNotEmpty
                              ? BarChart(
                                  BarChartData(
                                    barGroups: _getWeekData(weekStart),
                                    borderData: FlBorderData(show: false),
                                    gridData: FlGridData(show: false),
                                    titlesData: FlTitlesData(
                                      bottomTitles: AxisTitles(
                                        sideTitles: SideTitles(
                                          showTitles: true,
                                          getTitlesWidget: (value, _) {
                                            final day =
                                                weekStart.add(Duration(days: value.toInt()));
                                            return Text(
                                              DateFormat('EEE', 'it').format(day),
                                              style: const TextStyle(fontSize: 10),
                                            );
                                          },
                                        ),
                                      ),
                                      leftTitles: AxisTitles(
                                        sideTitles: SideTitles(showTitles: false),
                                      ),
                                    ),
                                  ),
                                )
                              : const Center(
                                  child: Text('Nessun dato disponibile'),
                                ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            const Text('Oggi stai a fuma così:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FloatingActionButton(
                  onPressed: _decrementCounter,
                  tooltip: 'Decrementa',
                  child: const Icon(Icons.remove),
                ),
                const SizedBox(width: 10),
                FloatingActionButton(
                  onPressed: _incrementCounter,
                  tooltip: 'Incrementa',
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
