import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logger/logger.dart';

void main() {
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
  bool _isLoading = false; // Stato del loader

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

      final storedUsername = await _storage.read(key: 'username');
      final storedPassword = await _storage.read(key: 'password');
      _logger.i('Dati registrati: Username=$storedUsername, Password=$storedPassword');

      setState(() {
        _errorMessage = 'Registrazione avvenuta con successo! Ora effettua il login.';
      });
    } catch (e) {
      _logger.e('Errore durante la registrazione: $e');
      setState(() {
        _errorMessage = 'Si è verificato un errore durante la registrazione.';
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

      _logger.d('Tentativo di login: Username=$username, Password=$password');
      _logger.d('Credenziali salvate: Username=$storedUsername, Password=$storedPassword');

      if (storedUsername == username && storedPassword == password) {
        _logger.i('Login riuscito. Navigazione verso la home.');

        if (!mounted) return; // Controlla che il widget sia montato
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MyHomePage(title: 'Benvenuto!')),
        );
      } else {
        _logger.w('Login fallito. Nome utente o password errati.');
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
        _isLoading = false; // Ferma il loader
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
                  onPressed: _isLoading ? null : _login,
                  child: const Text('Login'),
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: _isLoading ? null : _register,
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

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    Logger().i('Rendering MyHomePage'); // Verifica il rendering della HomePage
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: Text('Benvenuto! Le tue statistiche personali saranno qui.'),
      ),
    );
  }
}
