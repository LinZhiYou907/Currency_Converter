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
  // 儲存轉換後的金額，並在介面上顯示
  String _convertedAmount = '0.0';
  // 增加錯誤提示
  String _errorMessage = '';
  // 儲存從 API 取得的匯率資料
  Map<String, dynamic> _rates = {};

  // 儲存下拉式選單的選擇值
  String? _fromCurrency = 'TWD';
  String? _toCurrency = 'JPY';
  // 控制文字輸入框以獲取使用者輸入
  final TextEditingController _amountController = TextEditingController();

  // 匯率清單
  final List<String> currencies = ['TWD', 'USD', 'JPY', 'EUR', 'GBP', 'AUD'];

  // 獲取匯率的非同步函式
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

  // 轉換邏輯
  void convertCurrency() async {
    // 清除錯誤訊息
    setState(() {
      _errorMessage = '';
    });

    try {
      final data = await getExchangeRates(_fromCurrency!);

      final rates = data['conversion_rates'];
      if (rates != null && rates[_toCurrency] != null) {
        final toRate = rates[_toCurrency];
        final inputAmount = double.tryParse(_amountController.text) ?? 0.0;
        final convertedAmount = inputAmount * toRate;

        setState(() {
          _convertedAmount = convertedAmount.toStringAsFixed(2);
          _rates = rates;
        });
      } else {
        setState(() {
          _errorMessage = '選択した通貨のレートが見つかりません';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'インターネット問題が発生しました';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('通貨換算アプリ')),
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
                onChanged: (text) {
                  convertCurrency(); // 添加這個功能就可以輸入數字馬上得到結果
                },
              ),
              const SizedBox(height: 10), // 增加錯誤訊息的間距
              if (_errorMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: Text(
                    _errorMessage,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              const SizedBox(height: 10),
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
                        convertCurrency();
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
                        convertCurrency();
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  convertCurrency();
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
