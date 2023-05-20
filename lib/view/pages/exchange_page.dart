import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../utils/constants.dart';
import '../widgets/Header.dart';
import '../widgets/bar_graph/bar_graph.dart';
import '../widgets/pie_chart/pie_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ExchangePage extends StatefulWidget {
  const ExchangePage({super.key});

  @override
  State<ExchangePage> createState() => _ExchangePage();
}

class _ExchangePage extends State<ExchangePage> {
  // TODO: receive these things from provider

  // warns that the used rates are old
  bool noInternet = false;

  // warns that there was no internet and no old conversion rates
  bool fail = false;

  // values for graphs
  List<double> values = [];
  List<String> currencies = [];


  late SharedPreferences _prefs;
  Future<void> _startPreferences() async{
    _prefs = await SharedPreferences.getInstance();
  }


  updateCurrencies() async{
    await _startPreferences();
    late List<String> cur = [];
    late List<double> am = [];

    for (String currency in codeToName.keys){
      final amount = _prefs.getDouble(currency);
      if(amount != null && amount > 0){
        cur.add(currency);
        am.add(amount);
      }
    }
    setState(() {
      currencies = cur;
      values = am;
     });
  }

  @override
  void initState() {
    super.initState();
    updateCurrencies();
  }

  @override
  void setState(VoidCallback fn) {
    super.setState(fn);
  }


  double total = 0;
  String currencyToTransfer = "EUR";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Header("Wallet Conversion"),
      body: getBody(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        onTap: (index) {
          if (index == 0) {
            Navigator.of(context).pushNamed("/wallet");
          }
        },
        backgroundColor: ColorPallet.lightPink,
        selectedItemColor: ColorPallet.darkPink,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.account_balance_wallet, color: Colors.black),
              activeIcon: Icon(
                Icons.account_balance_wallet,
                color: ColorPallet.darkPink,
              ),
              label: "Wallet"),
          BottomNavigationBarItem(
              icon: Icon(Icons.currency_exchange, color: Colors.black),
              activeIcon: Icon(
                Icons.currency_exchange,
                color: ColorPallet.darkPink,
              ),
              label: "Exchange")
        ],
      ),
    );
  }

  Widget getDropDown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Choose result currency:",
          style: TextStyle(
              color: ColorPallet.darkPink,
              fontSize: 25,
              fontWeight: FontWeight.bold),
        ),
        const SizedBox(
          height: 5,
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
              color: ColorPallet.lightPink,
              borderRadius: BorderRadius.circular(10.0)),
          child: DropdownButton<String>(
            isExpanded: true,
            value: currencyToTransfer,
            icon: const Icon(
              Icons.arrow_drop_down,
              color: Colors.black,
              size: 30,
            ),
            style: const TextStyle(color: Colors.black),
            onChanged: (String? value) {
              setState(() {
                currencyToTransfer = value!;
                // TODO: missing exchange logic
              });
            },
            items:
                codeToName.keys.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(
                  "${codeToName[value]} ($value)",
                  style: const TextStyle(color: Colors.black, fontSize: 20),
                ),
              );
            }).toList(),
          ),
        )
      ],
    );
  }

  Widget getTotal() {
    var format = NumberFormat.simpleCurrency(locale: "pt");

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const Text(
          "Total:",
          style: TextStyle(
              color: ColorPallet.darkPink,
              fontWeight: FontWeight.bold,
              fontSize: 25),
        ),
        const SizedBox(
          width: 5,
        ),
        Text(
          "${format.simpleCurrencySymbol(currencyToTransfer)} ${total.toString()} ($currencyToTransfer)",
          style: const TextStyle(fontSize: 25),
        )
      ],
    );
  }

  Widget getErrorScreen() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        color: ColorPallet.darkPink,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: const [
          Text(
            "Error",
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 30),
            textAlign: TextAlign.center,
          ),
          SizedBox(
            height: 10,
          ),
          Text(
            "You have no internet connection, and the rates for the currencies in your wallet have not been stored in the app in previous uses.",
            style: TextStyle(color: Colors.white, fontSize: 25),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget getWarning() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: const [
        SizedBox(
          height: 15,
        ),
        Text(
          "Warning",
          style: TextStyle(
              color: ColorPallet.darkPink,
              fontWeight: FontWeight.bold,
              fontSize: 30),
          textAlign: TextAlign.center,
        ),
        SizedBox(
          height: 10,
        ),
        Text(
          "You have no internet connection, the rates stored from your last use of the app are being used and might not be up to date.",
          style: TextStyle(color: ColorPallet.darkPink, fontSize: 25),
          textAlign: TextAlign.center,
        ),
        SizedBox(
          height: 30,
        ),
      ],
    );
  }

  Widget getBarGraph() {
    return Container(
      margin: const EdgeInsets.fromLTRB(0, 10, 0, 40),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text(
          "Wallet Breakdown:",
          style: TextStyle(
              color: ColorPallet.darkPink,
              fontWeight: FontWeight.bold,
              fontSize: 25),
        ),
        const SizedBox(
          height: 40,
        ),
        SizedBox(
            width: MediaQuery.of(context).size.width,
            height: 300,
            child: BarGraphWidget(currency: currencies, amount: values))
      ]),
    );
  }

  Widget getPieGraph() {
    return PieChartWidget(currency: currencies, amount: values, convertedCurrency: currencyToTransfer,);
  }

  Widget getBody() {
    if (fail) {
      return Container(
        margin: const EdgeInsets.all(10),
        child: Column(
          children: [
            getDropDown(),
            const SizedBox(height: 15),
            getErrorScreen(),
          ],
        ),
      );
    }

    return Container(
        margin: const EdgeInsets.all(10),
        child: SingleChildScrollView(
          child: Column(
            children: [
              getDropDown(),
              const SizedBox(
                height: 15,
              ),
              if (noInternet) getWarning(),
              getTotal(),
              if (currencies.isNotEmpty) getBarGraph(),
              if (currencies.isNotEmpty) getPieGraph()
            ],
          ),
        ));
  }
}
