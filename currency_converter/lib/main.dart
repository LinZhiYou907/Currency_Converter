import 'package:flutter/material.dart'; // Material UI 套件，基本介面元件和主題
import 'package:http/http.dart' as http; // HTTP 請求套件，用於與 API 互動
import 'dart:convert'; // JSON 編碼和解碼套件

// 應用程式進入點
void main() {
  // 啟動應用程式並執行MyApp元件
  runApp(const MyApp());
}

// 主應用程式元件，使用 StatefulWidget 以便在介面上動態更新資料
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  // 建立並返回 _MyAppState 狀態的物件，用於管理應用程式的狀態
  State<MyApp> createState() => _MyAppState();
}

// _MyAppState 類別，負責管理應用程式的狀態和邏輯
class _MyAppState extends State<MyApp> {
  // 儲存轉換後的金額，初始值為 '0.0'
  String _convertedAmount = '0.0';
  // 增加錯誤提示，初始值為空字串
  String _errorMessage = '';
  // 儲存從 API 取得的匯率資料，初始為空的 Map儲值
  Map<String, dynamic> _rates = {};

  // 儲存下拉式選單的選擇值，預設為將TWD 轉換成 JPY
  String? _fromCurrency = 'TWD';
  String? _toCurrency = 'JPY';
  // 控制文字輸入框以獲取使用者輸入
  final TextEditingController _amountController = TextEditingController();

  // 定義匯率清單
  final List<String> currencies = ['TWD', 'USD', 'JPY', 'EUR', 'GBP', 'AUD'];

  // 獲取匯率的非同步函式，使用 HTTP GET 請求從 API 獲取資料
  Future<Map<String, dynamic>> getExchangeRates(String baseCurrency) async {
    final apiKey = '91e2b0abe3ab0afd743b1050';
    final baseUrl =
        'https://v6.exchangerate-api.com/v6/$apiKey/latest/$baseCurrency';

    // 發送 HTTP GET 請求並等待回應
    final response = await http.get(Uri.parse(baseUrl));

    // 如果回應狀態碼為 200，表示請求成功，解析 JSON 資料並返回
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      // 返回解碼後的資料
      return data;
    } else {
      // 如果請求失敗，拋出異常
      throw Exception('選択した通貨のレートが見つかりません');
    }
  }

  // 處理幣耶轉換邏輯
  void convertCurrency() async {
    // 呼叫 setState 函式更新狀態，清除錯誤訊息
    setState(() {
      _errorMessage = '';
    });

    try {
      // 等待 getExchangeRates 函式完成並獲取匯率資料
      final data = await getExchangeRates(_fromCurrency!);

      // 從返回的資料中提取轉換率
      final rates = data['conversion_rates'];
      // 檢查是否成功獲取轉換率
      if (rates != null && rates[_toCurrency] != null) {
        // 取得目標幣別的轉換率
        final toRate = rates[_toCurrency];
        // 解析使用者輸入的金額，若無法解析則預設為 0.0
        final inputAmount = double.tryParse(_amountController.text) ?? 0.0;
        // 計算轉換後的金額
        final convertedAmount = inputAmount * toRate;

        // 使用 setState 函式更新狀態，顯示轉換後的金額和匯率資料
        setState(() {
          // 將轉換後的金額格式化為兩位小數並更新狀態
          _convertedAmount = convertedAmount.toStringAsFixed(2);
          // 更新匯率資料(此程式碼目前未使用，但可供未來擴展)
          _rates = rates;
        });
      } else {
        // 如果找不到轉換率，設定錯誤訊息並更新頁面
        setState(() {
          _errorMessage = '選択した通貨のレートが見つかりません';
        });
      }
    } catch (e) {
      // 如果API請求失敗或發生其他錯誤，設定錯誤訊息並更新頁面
      setState(() {
        _errorMessage = 'インターネット問題が発生しました';
      });
    }
  }

  // 建立並返回應用程式的介面
  @override
  Widget build(BuildContext context) {
    // MaterialApp 是 Flutter 應用程式的根元件，提供了許多基本功能
    return MaterialApp(
      // Scaffold 提供了基本的頁面結構，如 AppBar、主體等
      home: Scaffold(
        // AppBar 顯示在應用程式頂部的應用程式標題欄
        appBar: AppBar(title: const Text('通貨換算アプリ')),
        // 主體部分
        body: Padding(
          // 內邊距
          padding: const EdgeInsets.all(16.0),
          // 使用 Column 佈局將子元件垂直排列
          child: Column(
            children: [
              // 文字輸入框，讓使用者輸入要轉換的金額
              TextField(
                // 將輸入框與 _amountController 連結>方便讀取內容
                controller: _amountController,
                // 數字鍵盤設定
                keyboardType: TextInputType.number,
                // 輸入框的裝飾，包含邊框和標籤
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: '金額を入力してください',
                ),
                // 當輸入框內容改變時觸發，呼叫 convertCurrency 函式進行轉換
                onChanged: (text) {
                  convertCurrency(); // 添加這個功能就可以輸入數字馬上得到結果
                },
              ),
              // SizedBox 用於增加元件之間的垂直間距
              const SizedBox(height: 10), // 增加錯誤訊息的間距
              // 條件判斷，如果有錯誤訊息則顯示
              if (_errorMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: Text(
                    _errorMessage,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              const SizedBox(height: 10),
              // 使用 Row 佈局將下拉選單水平排列
              Row(
                // 主軸對齊方式，將子元件均勻分佈
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  // 從哪個幣別轉換的下拉選單
                  DropdownButton<String>(
                    value: _fromCurrency,
                    // 根據currencies生成下拉選單的選項
                    items: currencies.map<DropdownMenuItem<String>>((
                      String value,
                    ) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    // 當選擇的值改變時觸發，更新狀態並呼叫 convertCurrency 函式
                    onChanged: (String? newValue) {
                      // 呼叫 setState 更新狀態重新繪製介面
                      setState(() {
                        // 更新選擇的幣別
                        _fromCurrency = newValue;
                        convertCurrency();
                      });
                    },
                  ),
                  // 兩個下拉選單之間的箭頭圖示
                  const Icon(Icons.arrow_forward),
                  // 轉換成哪個幣別的下拉選單
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
              // 帶有陰影的換算按鈕，點擊後呼叫 convertCurrency 函式進行轉換
              ElevatedButton(
                // 定義按下按鈕時執行的函式
                onPressed: () {
                  convertCurrency();
                },
                child: const Text('換算'),
              ),
              const SizedBox(height: 20),
              // Text 元件顯示轉換後的金額，使用大字體和粗體字型
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
