import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:math_expressions/math_expressions.dart';

void main() => runApp(const CalculatorApp());

class CalculatorApp extends StatelessWidget {
  const CalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.pink, // Set primary color to pink
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final List<String> _calculationHistory = [];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kalkulator'),
        backgroundColor: Colors.pink, // AppBar color changed to pink
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: IndexedStack(
            index: _selectedIndex,
            children: [
              Calculator(onCalculation: (result) {
                setState(() {
                  _calculationHistory.add(result);
                });
              }),
              CalculationHistory(calculationHistory: _calculationHistory),
              const UserProfileDisplay(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.calculate), label: 'Kalkulator'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Riwayat'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.pink[800], // BottomNavigationBar selected item color to pink
        onTap: _onItemTapped,
      ),
    );
  }
}

class Calculator extends StatefulWidget {
  final Function(String) onCalculation;

  const Calculator({super.key, required this.onCalculation});

  @override
  _CalculatorState createState() => _CalculatorState();
}

class _CalculatorState extends State<Calculator> {
  String _expression = '';
  String _display = '0';

  void _handleInput(String value) {
    setState(() {
      if (value == 'C') {
        _expression = '';
        _display = '0';
      } else if (value == 'Del') {
        _expression = _expression.isNotEmpty ? _expression.substring(0, _expression.length - 1) : '';
        _display = _expression.isEmpty ? '0' : _expression;
      } else if (value == '=') {
        try {
          Parser p = Parser();
          Expression exp = p.parse(_expression.replaceAll('×', '*').replaceAll('÷', '/'));
          ContextModel cm = ContextModel();
          double eval = exp.evaluate(EvaluationType.REAL, cm);

          // Display result as an integer if possible, or as a float with no commas
          if (eval == eval.toInt()) {
            _display = eval.toInt().toString(); // Display as an integer
          } else {
            _display = eval.toStringAsFixed(0); // Round and display as integer
          }

          widget.onCalculation('$_expression = $_display');
          _expression = _display;
        } catch (e) {
          _display = 'Error';
        }
      } else {
        _expression += value;
        _display = _expression;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.all(24),
              constraints: const BoxConstraints(maxWidth: 350),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Text(
                  _display,
                  style: const TextStyle(fontSize: 40, fontWeight: FontWeight.w300),
                ),
              ),
            ),
            ...['7 8 9 ÷', '4 5 6 ×', '1 2 3 -', 'C 0 Del +']
                .map((row) => Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: row.split(' ').map((text) => _buildButton(text)).toList(),
                    )),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(child: _buildButton('=')),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButton(String text, {Color color = Colors.pink}) { // Button color changed to pink
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        onPressed: () => _handleInput(text),
        child: Text(
          text,
          style: const TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}

class CalculationHistory extends StatelessWidget {
  final List<String> calculationHistory;

  const CalculationHistory({super.key, required this.calculationHistory});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: ListView.builder(
          itemCount: calculationHistory.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(calculationHistory[index]),
            );
          },
        ),
      ),
    );
  }
}

class UserProfileDisplay extends StatelessWidget {
  const UserProfileDisplay({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: const [
            Text('Profil Pengguna', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Text('Nama: Rudi'),
            Text('Email: user@example.com'),
          ],
        ),
      ),
    );
  }
}
