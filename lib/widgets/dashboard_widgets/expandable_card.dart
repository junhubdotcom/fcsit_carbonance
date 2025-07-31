import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ExpandableCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final List<Tab> tabs;
  final List<Widget> tabViews;
  final IconData icon;

  const ExpandableCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.tabs,
    required this.tabViews,
    this.icon = Icons.lightbulb,
  });

  @override
  _ExpandableCardState createState() => _ExpandableCardState();
}

class _ExpandableCardState extends State<ExpandableCard>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isExpanded = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: widget.tabs.length, vsync: this);
  }

  void _toggleExpand() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🟡 Header Section
            GestureDetector(
              onTap: _toggleExpand,
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.blueGrey,
                    radius: 16,
                    child: Icon(widget.icon, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: GoogleFonts.quicksand(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        Text(
                          widget.subtitle,
                          style: GoogleFonts.quicksand(
                            color: Colors.black54,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    _isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    size: 28,
                    color: Colors.grey.shade700,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // 🟢 Expandable Content
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: _isExpanded
                  ? widget.tabs.length > 1
                      ? Column(
                          children: [
                            // 🔵 Tab Bar UI
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: TabBar(
                                labelStyle: GoogleFonts.quicksand(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                                controller: _tabController,
                                labelColor: Colors.black,
                                unselectedLabelColor: Colors.grey,
                                indicatorColor: Colors.blue,
                                indicatorWeight: 3,
                                tabs: widget.tabs,
                              ),
                            ),
                            const SizedBox(height: 12),

                            // 🔴 TabBarView
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                              constraints: BoxConstraints(
                                maxHeight: _isExpanded ? 300 : 0,
                              ),
                              child: TabBarView(
                                controller: _tabController,
                                children: widget.tabViews,
                              ),
                            ),
                          ],
                        )
                      : widget.tabViews[0]
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
