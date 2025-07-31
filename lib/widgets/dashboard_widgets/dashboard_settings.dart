import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DashboardSettingsModal extends StatefulWidget {
  final List<String> initialSections;
  final Function(List<String>, Map<String, bool>) onSave;

  const DashboardSettingsModal({
    super.key,
    required this.initialSections,
    required this.onSave,
  });

  @override
  State<DashboardSettingsModal> createState() => _DashboardSettingsModalState();
}

class _DashboardSettingsModalState extends State<DashboardSettingsModal> {
  late List<String> sectionOrder;
  late Map<String, bool> sectionVisibility;

  @override
  void initState() {
    super.initState();
    sectionOrder = List.from(widget.initialSections);
    sectionVisibility = {
      for (var section in widget.initialSections) section: true,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
          maxWidth: 400,
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Text(
                "Customize Dashboard",
                style: GoogleFonts.quicksand(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ScrollConfiguration(
                  behavior: const ScrollBehavior().copyWith(overscroll: false),
                  child: ReorderableListView.builder(
                    buildDefaultDragHandles: false,
                    itemCount: sectionOrder.length,
                    itemBuilder: (context, index) {
                      final section = sectionOrder[index];
                      return ListTile(
                        key: ValueKey(section),
                        title: Text(section, style: GoogleFonts.quicksand()),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Switch(
                              value: sectionVisibility[section] ?? true,
                              onChanged: (value) {
                                setState(() {
                                  sectionVisibility[section] = value;
                                });
                              },
                            ),
                            ReorderableDragStartListener(
                              index: index,
                              child: const Padding(
                                padding: EdgeInsets.only(left: 12.0),
                                child: Icon(Icons.drag_handle),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    onReorder: (oldIndex, newIndex) {
                      setState(() {
                        if (newIndex > oldIndex) newIndex--;
                        final item = sectionOrder.removeAt(oldIndex);
                        sectionOrder.insert(newIndex, item);
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text("Cancel", style: GoogleFonts.quicksand()),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      widget.onSave(sectionOrder, sectionVisibility);
                      Navigator.of(context).pop();
                    },
                    child: Text("Save", style: GoogleFonts.quicksand()),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
