import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:steadypunpipi_vhack/models/expense_item.dart';

class Expense {
  String? id; // Optional: to store the document ID if needed
  String? transactionName;
  List<DocumentReference<ExpenseItem>> items;
  String paymentMethod;
  Timestamp dateTime;
  String? location;
  String? receiptImagePath;
  String? additionalImagePath;

  Expense({
    String? id,
    String? transactionName,
    List<DocumentReference<ExpenseItem>>? items,
    String? paymentMethod,
    Timestamp? dateTime,
    String? location,
    String? receiptImagePath,
    String? additionalImagePath,
  })  : transactionName = transactionName ?? "",
        items = items ?? [],
        paymentMethod = paymentMethod ?? "Cash",
        dateTime = dateTime ?? Timestamp.now(),
        location = location ?? "None",
        receiptImagePath = receiptImagePath ?? "",
        additionalImagePath = additionalImagePath ?? "";

  // From JSON
  factory Expense.fromJson(Map<String, dynamic> json) {
    final rawItemRefs = json['items'];
    List<DocumentReference<ExpenseItem>>? typedItemRefs;

    if (rawItemRefs is List) {
      typedItemRefs = rawItemRefs
          .map((rawRef) {
            if (rawRef is DocumentReference) {
              return (rawRef as DocumentReference).withConverter<ExpenseItem>(
                fromFirestore: (snapshot, _) {
                  if (!snapshot.exists || snapshot.data() == null) {
                    print(
                        "Warning: Referenced ExpenseItem document ${snapshot.id} does not exist or has no data.");
                    throw Exception(
                        "Referenced ExpenseItem document ${snapshot.id} not found or has null data.");
                  }
                  return ExpenseItem.fromJson(snapshot.data()!);
                },
                toFirestore: (item, _) => item.toJson(),
              );
            } else {
              print(
                  "Warning: Item in 'items' array is not a DocumentReference: $rawRef");
              return null; // Or handle this error as needed
            }
          })
          .whereType<DocumentReference<ExpenseItem>>()
          .toList(); // Filter out nulls
    } else if (rawItemRefs != null) {
      print("Warning: 'items' field was not a List: $rawItemRefs");
      typedItemRefs = null;
    } else {
      typedItemRefs = null;
    }

    return Expense(
      transactionName: json['transactionName'] ?? "",
      items: typedItemRefs,
      paymentMethod: json['paymentMethod'] ?? "Cash",
      // You can handle the following fields if Gemini returns them later or set defaults
      dateTime: json['dateTime'] is Timestamp
          ? json['dateTime'] as Timestamp
          : Timestamp.now(),
      location: json['location'] ?? "",
      receiptImagePath: json['receiptImagePath'] ?? "",
      additionalImagePath: "",
    );
  }

  // Optional: To JSON
  Map<String, dynamic> toJson() {
    final data = {
      'transactionName': transactionName,
      'paymentMethod': paymentMethod,
      'items': items,
      'dateTime': dateTime,
      'location': location,
      'receiptImagePath': receiptImagePath,
      'additionalImagePath': additionalImagePath,
    };

    if (items != null && items.toString().isNotEmpty) {
      data['items'] = items;
    }

    return data;
  }
}
