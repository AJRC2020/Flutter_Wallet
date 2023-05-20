import 'individual_bar.dart';

class BarData {
  final List<String> currency;
  final List<double> amount;

  List<IndividualBar> barData = [];

  BarData(this.currency, this.amount);

  void initializeBarData() {
    for (var i = 0; i <amount.length; i++) {
      barData.add(IndividualBar(i, double.parse(amount[i].toStringAsFixed(5))));
    }
  }
}
