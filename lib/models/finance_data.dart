class FinanceCO2Data {
  String label; // Day, Week, or Month
  double income;
  double expense;
  double co2; // Carbon footprint in kg

  FinanceCO2Data({
    required this.label,
    required this.income,
    required this.expense,
    required this.co2,
  });
}