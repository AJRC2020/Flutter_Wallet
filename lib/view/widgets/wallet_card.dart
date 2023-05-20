import 'package:assignment2/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WalletCard extends StatelessWidget {
  final String currency;
  final double value;
  late SharedPreferences _prefs;
  final Function setState;

  WalletCard({super.key, required this.currency, required this.value, required this.setState}){
    _startPreferences();
  }

  Future<void> _startPreferences() async{
    _prefs = await SharedPreferences.getInstance();
  }

  remove(String key) async{
    _prefs.remove(key);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: const EdgeInsets.all(10),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [Text(codeToName[currency] ?? "", style: const TextStyle(color: ColorPallet.darkPink),), getCard()]));
  }

  Widget getCard() {
    var format = NumberFormat.simpleCurrency(locale: "pt");
    return Card(
      color: ColorPallet.lightPink,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      key: Key(currency),
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "${format.simpleCurrencySymbol(currency)} ${value.toString()}",
              style: const TextStyle(fontSize: 20),
            ),
            Row(
            children: [Text(currency,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              IconButton(onPressed: ()=>{ remove(currency), setState()}, icon: const Icon(Icons.close, color: ColorPallet.darkPink,))])
          ],
        ),
      ),
    );
  }
}
