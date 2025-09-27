import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // Stores the converted amount to be displayed on the screen.
  String _convertedAmount = '0.0';
  // Stores the exchange rate data fetched from the API.
  Map<String, dynamic> _rates = {};

  // Stores the selected currencies from the dropdown menus.
  String? _fromCurrency = 'TWD';
  String? _toCurrency = 'JPY';
  // Controls the text field to get the user's input.
  TextEditingController _amountController = TextEditingController();

  // A list of currencies for the dropdown menus.
  final List<String> currencies = ['TWD', 'USD', 'JPY', 'EUR', 'GBP', 'AUD'];

  // A function to fetch exchange rates from the API.
  Future<Map<String, dynamic>> getExchangeRates(String baseCurrency) async {
    final apiKey = '91e2b0abe3ab0afd743b1050';
    final baseUrl =
        'https://v6.exchangerate-api.com/v6/$apiKey/latest/$baseCurrency';

    final response = await http.get(Uri.parse(baseUrl));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data;
    } else {
      throw Exception('選択した通貨のレートが見つかりません');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('通貨換算ツール')),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: '金額を入力してください',
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  DropdownButton<String>(
                    value: _fromCurrency,
                    items: currencies.map<DropdownMenuItem<String>>((
                      String value,
                    ) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _fromCurrency = newValue;
                      });
                    },
                  ),
                  const Icon(Icons.arrow_forward),
                  DropdownButton<String>(
                    value: _toCurrency,
                    items: currencies.map<DropdownMenuItem<String>>((
                      String value,
                    ) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _toCurrency = newValue;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  try {
                    final data = await getExchangeRates(_fromCurrency!);

                    final rates = data['conversion_rates'];
                    if (rates != null && rates[_toCurrency] != null) {
                      final toRate = rates[_toCurrency];
                      final inputAmount =
                          double.tryParse(_amountController.text) ?? 0.0;
                      final convertedAmount = inputAmount * toRate;

                      setState(() {
                        _convertedAmount = convertedAmount.toStringAsFixed(2);
                        _rates = rates;
                      });
                    } else {
                      print('選択した通貨のレートが見つかりません');
                    }
                  } catch (e) {
                    print('エラー: $e');
                  }
                },
                child: const Text('換算'),
              ),
              const SizedBox(height: 20),
              Text(
                '換算結果: $_convertedAmount',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
