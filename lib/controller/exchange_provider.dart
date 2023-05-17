import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ExchangeData extends ChangeNotifier {
  bool loading = false;
  Map<String, dynamic> rates = {};
  Map<String, double> wallet = {
    "EUR": 23.4,
    "JPY": 2100,
    "USD": 35.9
  };
  String targetCurrency = "EUR";
  bool _internet = true;
  bool _fail = false;

  double get result => getConversion();
  String get target => targetCurrency;
  bool get internet => _internet;
  bool get fail => _fail;
  List<String> get currencies => getCurrencies();
  List<double> get values => getValues();

  double getConversion() {
    double res = 0.0;

    for (String key in wallet.keys.toList()) {
      res += wallet[key]! / rates[key]!;
    }

    return res;
  }

  List<String> getCurrencies() {
    return wallet.keys.toList();
  }

  List<double> getValues() {
    List<double> values = [];

    for (String key in wallet.keys.toList()) {
      values.add(wallet[key]! / rates[key]);
    }

    return values;
  }

  void updateTarget(String currency) async {
    targetCurrency = currency;
    await updateConnectivity();
    await getRates();
    notifyListeners();
  }

  void updateWallet(Map<String, double> wallet) {
    this.wallet = wallet;
    getRates();
    notifyListeners();
  }

  Future<void> getRates() async{
    loading = true;
    if (_internet) {
      rates = await getRatesData(targetCurrency, wallet.keys.toList());
    }
    else {
      Map<String, dynamic>? check = await readPrefs(targetCurrency, wallet);
      if (check == null) {
        _fail = true;
      }
      else {
        rates = check;
      }
    }
    loading = false;
    notifyListeners();
  }

  Future<void> updateConnectivity() async {
    var result = await (Connectivity().checkConnectivity());
    if (result == ConnectivityResult.none) {
      _internet = false;
    }
    else {
      _internet = true;
      _fail = false;
    }
    notifyListeners();
  }
}

Future<Map<String, dynamic>?> readPrefs(String base, Map<String, double> wallet) async {
  Map<String, dynamic>? res = {};
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  for (String currency in wallet.keys.toList()) {
    final double? rate = await prefs.getDouble("$base-$currency");
    if (rate == null) {
      return null;
    }
    else {
      res[currency] = rate;
    }
  }
  return res;
}

Future<void> saveRates(String base, Map<String, dynamic> rates) async{
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  for (String currency in rates.keys.toList()) {
    if (currency == base) {
      await prefs.setDouble("$base-$currency", 1.0);
    }
    else {
      await prefs.setDouble("$base-$currency", rates[currency]);
    }
  }
}

Future<Map<String, dynamic>> getRatesData(String base, List<String> symbols) async {
  Map<String, dynamic> rates = {};

  String symbolsString = "";
  for (String symbol in symbols) {
    symbolsString = "$symbolsString,$symbol";
  }
  symbolsString = symbolsString.substring(1);
  String apikey = "lDRqpAZlcKarKpsq7O9yAsF7L9lLhI0Y";
  try {
    final response = await http.get(
      Uri.parse("https://api.apilayer.com/fixer/latest?symbols=$symbolsString&base=$base&apikey=$apikey")
    );
    if (response.statusCode == 200) {
      final item = json.decode(response.body);
      if (item["success"]) {
        rates = item["rates"];
        await saveRates(base, rates);
      }
      else {
        log("error");
      }
    } else {
      log("error code");
    }
  } catch (e) {
    log(e.toString());
  }
  return rates;
}