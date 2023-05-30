import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Currency Converter',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(Duration(seconds: 2), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (BuildContext context) => CurrencyConverter()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      body: Center(
        child: Text(
          'Currency Converter',
          style: TextStyle(
            fontSize: 24,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class CurrencyConverter extends StatefulWidget {
  @override
  _CurrencyConverterState createState() => _CurrencyConverterState();
}

class _CurrencyConverterState extends State<CurrencyConverter> {
  final List<String> currencies = [
    'USD',
    'EUR',
    'GBP',
    'JPY',
    'CAD',
  ];

  String fromCurrency = 'USD';
  String toCurrency = 'EUR';
  double exchangeRate = 0.0;
  double convertedAmount = 0.0;

  TextEditingController amountController = TextEditingController();

  void getExchangeRate() async {
    String url = 'https://api.exchangerate-api.com/v4/latest/$fromCurrency';
    http.Response response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      Map<String, dynamic> data = jsonDecode(response.body);
      setState(() {
        exchangeRate = data['rates'][toCurrency];
        double amount = double.parse(amountController.text);
        convertedAmount = amount * exchangeRate;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Currency Converter'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Convert from:',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 8),
            DropdownButton<String>(
              value: fromCurrency,
              onChanged: (String? newValue) {
                setState(() {
                  fromCurrency = newValue!;
                });
              },
              items: currencies.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            SizedBox(height: 16),
            Text(
              'Convert to:',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 8),
            CupertinoPicker(
              itemExtent: 32,
              onSelectedItemChanged: (int index) {
                setState(() {
                  toCurrency = currencies[index];
                });
              },
              children: currencies.map<Widget>((String currency) {
                return Text(currency);
              }).toList(),
            ),
            SizedBox(height: 16),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Amount',
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                getExchangeRate();
              },
              child: Text('Convert'),
            ),
            SizedBox(height: 16),
            Text(
              'Converted Amount: $convertedAmount',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}