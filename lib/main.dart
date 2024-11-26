import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:logger/logger.dart';

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
      home: const LoginScreen(),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _storage = const FlutterSecureStorage();
  final _logger = Logger();

  String? _errorMessage;
  bool _isLoading = false;

  Future<void> _register() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      setState(() {
        _errorMessage = 'Entrambi i campi sono obbligatori.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _storage.write(key: 'username', value: username);
      await _storage.write(key: 'password', value: password);

      _logger.i('Registrazione completata: Username=$username');
      setState(() {
        _errorMessage = 'Registrazione avvenuta con successo!';
      });
    } catch (e) {
      _logger.e('Errore durante la registrazione: $e');
      setState(() {
        _errorMessage = 'Errore durante la registrazione.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _login() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      setState(() {
        _errorMessage = 'Entrambi i campi sono obbligatori.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final storedUsername = await _storage.read(key: 'username');
      final storedPassword = await _storage.read(key: 'password');

      _logger.d('Tentativo di login: Username=$username');
      if (storedUsername == username && storedPassword == password) {
        _logger.i('Login riuscito.');

        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const HomePage(title: '🛠✨'),
          ),
        );
      } else {
        setState(() {
          _errorMessage = 'Nome utente o password errati.';
        });
      }
    } catch (e) {
      _logger.e('Errore durante il login: $e');
      setState(() {
        _errorMessage = 'Si è verificato un errore. Riprova.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Benvenuto in eddainonfumare!',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: 'Nome utente',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              if (_errorMessage != null)
                Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              const SizedBox(height: 20),
              if (_isLoading)
                const CircularProgressIndicator()
              else ...[
                ElevatedButton(
                  onPressed: _login,
                  child: const Text('Login'),
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: _register,
                  child: const Text('Non hai un account? Registrati'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});

  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _counter = 0;
  final Map<String, int> _dailyCounts = {};
  final PageController _pageController = PageController(initialPage: 0);

  DateTime _currentWeek = _getMondayOfThisWeek();
  int _currentPage = 0;

  static DateTime _getMondayOfThisWeek() {
    final now = DateTime.now();
    return now.subtract(Duration(days: now.weekday - 1));
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

  List<BarChartGroupData> _getWeekData(DateTime weekStart) {
    return List.generate(7, (i) {
      final day = weekStart.add(Duration(days: i));
      final dayKey = DateFormat('yyyy-MM-dd').format(day);
      final count = _dailyCounts[dayKey] ?? 0;
      return BarChartGroupData(
        x: i,
        barRods: [
          BarChartRodData(
            toY: count.toDouble(),
            width: 16,
            color: Colors.deepPurple,
          ),
        ],
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            onPressed: _goToCurrentWeek,
            tooltip: 'Torna alla settimana corrente',
            icon: const Icon(Icons.today),
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          SizedBox(
            height: 240,
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
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          weekTitle,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Container(
                        height: 120,
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: BarChart(
                          BarChartData(
                            barGroups: _getWeekData(weekStart),
                            borderData: FlBorderData(show: false),
                            gridData: FlGridData(show: false),
                            titlesData: FlTitlesData(
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (value, _) {
                                    final day = weekStart.add(Duration(days: value.toInt()));
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
    );
  }
}
