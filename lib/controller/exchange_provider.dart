import 'package:flutter/cupertino.dart';
import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;

class ExchangeData extends ChangeNotifier {
  bool loading = false;
  Map<String, double> rates = {};
  Map<String, double> wallet = {
    "EUR": 23.4,
    "JPY": 2100,
    "USD": 35.9
  };
  String targetCurrency = "EUR";

  double get result => getConversion();
  String get target => targetCurrency;

  double getConversion() {
    getRates();

    double res = 0.0;

    for (String key in wallet!.keys.toList()) {
      res += wallet![key]! / rates![key]!;
    }

    return res;
  }

  void updateTarget(String currency) {
    targetCurrency = currency;
    //getRates();
    notifyListeners();
  }

  void updateWallet(Map<String, double> wallet) {
    this.wallet = wallet;
    //getRates();
    notifyListeners();
  }

  void getRates() async{
    loading = true;
    rates = await getRatesData(targetCurrency, wallet.keys.toList());
    loading = false;
    notifyListeners();
  }
}


Future<Map<String, double>> getRatesData(String base, List<String> symbols) async {
  Map<String, double> rates = {};

  String symbolsString = "";
  for (String symbol in symbols) {
    symbolsString = "$symbolsString,$symbol";
  }
  symbolsString = symbolsString.substring(1);
  String apikey = "dAcvgFrStQ1JgqYQJg8rFGEDPndWqs6h";
  try {
    log("https://data.fixer.io/api/latest?symbols=$symbolsString&base=$base");
    final response = await http.get(
      Uri.parse("https://data.fixer.io/api/latest?symbols=$symbolsString&base=$base"),
      headers: {
        "apikey": apikey
      }
    );
    log(response.body);
    if (response.statusCode == 200) {
      final item = json.decode(response.body);
      if (item["success"]) {
        rates = item["rates"];
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