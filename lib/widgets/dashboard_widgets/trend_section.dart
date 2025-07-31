import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:steadypunpipi_vhack/models/finance_data.dart';
import 'package:steadypunpipi_vhack/widgets/dashboard_widgets/expandable_card.dart';
import 'package:steadypunpipi_vhack/widgets/dashboard_widgets/fallback_chart.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class TrendSection extends StatelessWidget {
  final List<FinanceCO2Data> data;
  final String title;

  const TrendSection({super.key, required this.data, required this.title});

  @override
  Widget build(BuildContext context) {
    return ExpandableCard(
      title: "Trend",
      subtitle: "Spot patterns, stay ahead",
      icon: Icons.show_chart_outlined,
      tabs: const [
        Tab(text: "Income vs Expense"),
        Tab(text: "Expense & CO₂"),
      ],
      tabViews: [
        FinanceBarChart(data: data, title: title),
        ExpenseCO2Chart(data: data, title: title),
      ],
    );
  }
}

class FinanceBarChart extends StatelessWidget {
  final List<FinanceCO2Data> data;
  final String title; // Title can be "Daily", "Weekly", or "Monthly"

  FinanceBarChart({required this.data, required this.title});

  @override
  Widget build(BuildContext context) {
    return data.isEmpty
        ? FallbackChart()
        : SfCartesianChart(
            title: ChartTitle(
              text: '$title Income vs Expense',
              textStyle: GoogleFonts.quicksand(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            legend: Legend(
              isVisible: true,
              position: LegendPosition.bottom,
              textStyle: GoogleFonts.quicksand(
                fontSize: 12,
                color: Colors.black87,
              ),
            ),
            primaryXAxis: CategoryAxis(
              title: AxisTitle(
                text: title,
                textStyle: GoogleFonts.quicksand(
                  fontSize: 12,
                  color: Colors.grey[700],
                ),
              ),
            ),
            primaryYAxis: NumericAxis(
              title: AxisTitle(
                text: 'Amount (RM)',
                textStyle: GoogleFonts.quicksand(
                  fontSize: 12,
                  color: Colors.grey[700],
                ),
              ),
            ),
            series: <CartesianSeries>[
              // Income Bars
              ColumnSeries<FinanceCO2Data, String>(
                name: 'Income',
                dataSource: data,
                xValueMapper: (FinanceCO2Data finance, _) => finance.label,
                yValueMapper: (FinanceCO2Data finance, _) => finance.income,
                color: Colors.green,
                borderRadius: BorderRadius.circular(6),
                dataLabelSettings: DataLabelSettings(
                  isVisible: true,
                  textStyle: GoogleFonts.quicksand(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ),
              // Expense Bars
              ColumnSeries<FinanceCO2Data, String>(
                name: 'Expense',
                dataSource: data,
                xValueMapper: (FinanceCO2Data finance, _) => finance.label,
                yValueMapper: (FinanceCO2Data finance, _) => finance.expense,
                color: Colors.red,
                dataLabelSettings: DataLabelSettings(isVisible: true),
                borderRadius: BorderRadius.circular(6),
              ),
            ],
          );
  }
}

class ExpenseCO2Chart extends StatelessWidget {
  final List<FinanceCO2Data> data;
  final String title; // "Daily", "Weekly", or "Monthly"

  const ExpenseCO2Chart({required this.data, required this.title, super.key});

  @override
  Widget build(BuildContext context) {
    return data.isEmpty
        ? FallbackChart()
        : Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
            child: SizedBox(
              height: 320,
              child: SfCartesianChart(
                title: ChartTitle(
                    text: '$title Expense & CO₂ Emissions',
                    textStyle: GoogleFonts.quicksand(
                        fontSize: 14, fontWeight: FontWeight.bold)),
                legend: Legend(
                  isVisible: true,
                  position: LegendPosition.bottom,
                  textStyle:
                      GoogleFonts.quicksand(fontSize: 12, color: Colors.black),
                ),

                primaryXAxis: CategoryAxis(title: AxisTitle(text: title)),

                // Primary Y-Axis for Expense
                primaryYAxis: NumericAxis(
                  title: AxisTitle(
                    text: 'Expense (RM)',
                    textStyle: GoogleFonts.quicksand(
                        fontSize: 12, color: Colors.grey[700]),
                  ),
                  opposedPosition: false, // Left Side
                ),

                // Secondary Y-Axis for CO₂
                axes: [
                  NumericAxis(
                    name: 'co2Axis',
                    title: AxisTitle(
                      text: 'CO₂ (kg)',
                      textStyle: GoogleFonts.quicksand(
                          fontSize: 12, color: Colors.grey[700]),
                    ),
                    opposedPosition: true, // Right Side
                  ),
                ],

                series: <CartesianSeries>[
                  // Stacked Bar for Expense
                  StackedColumnSeries<FinanceCO2Data, String>(
                    name: 'Expense (RM)',
                    dataSource: data,
                    xValueMapper: (FinanceCO2Data item, _) => item.label,
                    yValueMapper: (FinanceCO2Data item, _) => item.expense,
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(6),
                    dataLabelSettings: DataLabelSettings(
                      isVisible: true,
                      textStyle: GoogleFonts.quicksand(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  // Line Chart for CO₂ Trend (Secondary Axis)
                  LineSeries<FinanceCO2Data, String>(
                    name: 'CO₂ (kg)',
                    dataSource: data,
                    xValueMapper: (FinanceCO2Data item, _) => item.label,
                    yValueMapper: (FinanceCO2Data item, _) => item.co2,
                    color: Colors.red,
                    markerSettings: MarkerSettings(isVisible: true),
                    dataLabelSettings: DataLabelSettings(
                      isVisible: true,
                      textStyle: GoogleFonts.quicksand(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                    yAxisName: 'co2Axis', // Bind to Secondary Y-Axis
                  ),
                ],
              ),
            ),
          );
  }
}
