import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:steadypunpipi_vhack/models/breakdown_item.dart';
import 'package:steadypunpipi_vhack/models/transaction_model.dart';
import 'package:steadypunpipi_vhack/screens/dashboard/breakdown_detail.dart';
import 'package:steadypunpipi_vhack/widgets/dashboard_widgets/fallback_chart.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

Widget buildBreakdownTab({
  required BuildContext context,
  required String title,
  required List<BreakdownItem> data,
  required String unit,
  required Color valueColor,
  required String type,
  required List<TransactionModel> transactions,
}) {
  return data.isEmpty
      ? FallbackChart()
      : SingleChildScrollView(
          child: Column(
            children: [
              BreakdownChart(title: title, data: data),
              Align(
                alignment: Alignment.center,
                child: GestureDetector(
                  onTap: () => _showBreakdownSheet(
                      context, data, valueColor, unit, type, transactions),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.touch_app, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        "Click here to see detailed breakdown",
                        style: TextStyle(
                            color: Colors.grey.shade600, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
}

void _showBreakdownSheet(
    BuildContext context,
    List<BreakdownItem> data,
    Color valueColor,
    String unit,
    String type,
    List<TransactionModel> transactions) {
  double totalValue = data.fold(0, (sum, item) => sum + item.value);

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.5,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        builder: (context, scrollController) {
          return ListView.builder(
            controller: scrollController,
            itemCount: data.length,
            itemBuilder: (context, index) {
              final item = data[index];
              double percentage =
                  totalValue == 0 ? 0 : (item.value / totalValue);

              return Column(
                children: [
                  if (index == 0)
                    Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                      child: Text(
                        "Select a category to explore all related transactions.",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.quicksand(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  _buildBreakdownItem(
                      context: context,
                      item: item,
                      category: item.category,
                      value: item.value,
                      percentage: percentage,
                      unit: unit,
                      valueColor: valueColor,
                      type: type,
                      transactions: transactions)
                ],
              );
            },
          );
        },
      );
    },
  );
}

class BreakdownChart extends StatelessWidget {
  final String title;
  final List<BreakdownItem> data;

  const BreakdownChart({
    super.key,
    required this.title,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    double total = data.fold(0, (sum, item) => sum + item.value);
    bool isCO2 = title.toLowerCase().contains("co₂");

    return SizedBox(
      height: 280,
      child: SfCircularChart(
        title: ChartTitle(
          text: title,
          textStyle: GoogleFonts.quicksand(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        legend: Legend(
          isVisible: true,
          overflowMode: LegendItemOverflowMode.wrap,
          position: LegendPosition.bottom,
        ),
        series: <CircularSeries>[
          PieSeries<BreakdownItem, String>(
            dataSource: data,
            xValueMapper: (item, _) => item.category,
            yValueMapper: (BreakdownItem item, _) => item.value,
            dataLabelMapper: (BreakdownItem item, _) {
              final valueStr = isCO2
                  ? "${item.value.toStringAsFixed(1)} kg"
                  : "RM ${item.value.toStringAsFixed(2)}";
              final percent = ((item.value / total) * 100).toStringAsFixed(0);
              return "$valueStr\n$percent%";
            },
            dataLabelSettings: const DataLabelSettings(
              isVisible: true,
              labelPosition: ChartDataLabelPosition.outside,
              connectorLineSettings: ConnectorLineSettings(width: 1),
              textStyle: TextStyle(fontSize: 11),
              overflowMode: OverflowMode.shift,
            ),
          ),
        ],
      ),
    );
  }
}

Widget _buildBreakdownItem({
  required String category,
  required double value,
  required double percentage,
  required String unit,
  required Color valueColor,
  required BuildContext context,
  required BreakdownItem item,
  required String type,
  required List<TransactionModel> transactions,
}) {
  String formattedValue;
  Color textColor;

  if (type == "Expense") {
    formattedValue = "- RM ${value.toStringAsFixed(2)}";
    textColor = Colors.red;
  } else if (type == "Income") {
    formattedValue = "+ RM ${value.toStringAsFixed(2)}";
    textColor = Colors.green;
  } else {
    formattedValue = "+ ${value.toStringAsFixed(2)} kg CO₂";
    textColor = Colors.blueGrey;
  }

  return GestureDetector(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BreakdownDetailPage(
            category: item.category,
            type: type,
            transactions: transactions,
          ),
        ),
      );
    },
    child: Container(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Row(
        children: [
          // Icon
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 6,
                  offset: Offset(2, 2),
                ),
              ],
            ),
            padding: EdgeInsets.all(6),
            child: Container(
              padding: EdgeInsets.all(6),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: valueColor,
              ),
              child: Icon(
                getCategoryIcon(category),
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Category Name + Percentage Bar
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category,
                  style: GoogleFonts.quicksand(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: percentage,
                    backgroundColor: Colors.grey[200],
                    color: valueColor,
                    minHeight: 8,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // Amount
          SizedBox(
            width: 100,
            child: Text(
              formattedValue,
              textAlign: TextAlign.right,
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          SizedBox(width: 10),
          Icon(Icons.chevron_right)
        ],
      ),
    ),
  );
}

IconData getCategoryIcon(String category) {
  switch (category.toLowerCase()) {
    case "food":
      return Icons.fastfood;
    case "transport":
      return Icons.directions_bus;
    case "shopping":
      return Icons.shopping_bag;
    case "entertainment":
      return Icons.movie;
    case "salary":
      return Icons.account_balance_wallet;
    case "carbon footprint":
      return Icons.cloud;
    case "electricity":
      return Icons.electric_bolt;
    case "water":
      return Icons.water_drop;
    case "freelance":
      return Icons.work_outline;
    case "bills":
      return Icons.receipt_long;
    case "investments":
      return Icons.trending_up;
    default:
      return Icons.category;
  }
}
