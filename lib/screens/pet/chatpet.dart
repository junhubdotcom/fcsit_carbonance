import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:image_picker/image_picker.dart';
import 'package:steadypunpipi_vhack/models/complete_expense.dart';
import 'package:steadypunpipi_vhack/models/expense.dart';
import 'package:steadypunpipi_vhack/models/expense_item.dart';
import 'package:steadypunpipi_vhack/services/api_service.dart';
import 'package:steadypunpipi_vhack/services/carbon_service.dart';
import 'package:steadypunpipi_vhack/services/database_services.dart';

class ChatPet extends StatefulWidget {
  const ChatPet({super.key});

  @override
  State<ChatPet> createState() => _ChatPetState();
}

class _ChatPetState extends State<ChatPet> {
  final Gemini gemini = Gemini.instance;
  final ApiService _apiService = ApiService();
  final DatabaseService db = DatabaseService();
  final CarbonService carbonService = CarbonService();
  late CompleteExpense completeExpense;
  final ChatUser currentUser = ChatUser(id: "0", firstName: "Me");
  final ChatUser geminiUser = ChatUser(
      id: "1", firstName: "Mew", profileImage: "assets/images/cats/cat1.png");
  List<ChatMessage> messages = [];

  @override
  void initState() {
    super.initState();
    messages = [
      ChatMessage(
        text: "Hello, how can I help you?",
        user: geminiUser,
        createdAt: DateTime.now(),
      ),
    ];
  }

  void _sendMessage(ChatMessage chatMessage) {
    setState(() {
      messages = [chatMessage, ...messages];
    });
    try {
      String question = chatMessage.text;
      // List<Uint8List>? images;
      ChatMessage? lastMessage;

      // if (chatMessage.medias?.isNotEmpty ?? false) {
      //   images = [
      //     File(chatMessage.medias!.first.url).readAsBytesSync(),
      //   ];
      // }

      String fullResponse = ""; // accumulate chunks here

      gemini.streamGenerateContent(question).listen((event) {
        String responseChunk = event.content?.parts?.fold("", (prev, part) {
              if (part is TextPart) return "$prev${part.text}";
              return prev;
            }) ??
            "";

        fullResponse += responseChunk;

        setState(() {
          if (lastMessage == null) {
            lastMessage = ChatMessage(
              text: fullResponse.replaceAllMapped(
                  RegExp(r'\n(?!\n)'), (m) => '\n\n'),
              user: geminiUser,
              createdAt: DateTime.now(),
            );
            messages.insert(0, lastMessage!);
          } else {
            // 👇 Replacing the old message with updated content
            messages[0] = ChatMessage(
              text: fullResponse.replaceAllMapped(
                  RegExp(r'\n(?!\n)'), (m) => '\n\n'),
              user: geminiUser,
              createdAt: lastMessage!.createdAt,
            );
          }
        });
      }, onError: (error) {
        print("Gemini API Error: $error");
      }, onDone: () {
        lastMessage = null;
      });
    } catch (e) {
      print("General Error: $e");
      // Handle general errors
    }
  }

  void _sendMediaMessage() async {
    ImagePicker picker = ImagePicker();
    XFile? file = await picker.pickImage(source: ImageSource.gallery);
    if (file != null) {
      ChatMessage imageMessage = ChatMessage(
        text: "",
        user: currentUser,
        medias: [
          ChatMedia(
            url: file.path,
            fileName: "",
            type: MediaType.image,
          )
        ],
        createdAt: DateTime.now(),
      );

      setState(() {
        messages = [imageMessage, ...messages];
      });

      String prompt = """
Please extract and summarize the following details from the image:
- What was purchased (e.g. items like boba tea, groceries, etc.)
- Where the purchase was made (store name and location)
- Time and date of the transaction
- Total cost

Then respond to the user in a friendly tone with a summary like this:

"You purchased [item] at [store name, location] on [date] at [time] for a total of [amount].\n
This record has been successfully logged into your calendar for tracking and verification. 😊\n 
You can refer to your calendar anytime for more detailed information."

If any details are missing or unclear, make a best guess and let the user know you're estimating. Do not ask the user for further clarification.
      
      """;

      List<Uint8List> imageBytes = [File(file.path).readAsBytesSync()];
      ChatMessage? lastMessage;

      gemini.streamGenerateContent(prompt, images: imageBytes).listen(
        (event) {
          String responseChunk = event.content?.parts?.fold("", (prev, part) {
                if (part is TextPart) {
                  return "$prev${part.text}";
                }
                return prev;
              }) ??
              "";

          setState(() {
            if (lastMessage == null) {
              lastMessage = ChatMessage(
                text: responseChunk.replaceAllMapped(
                    RegExp(r'\n(?!\n)'), (match) => '\n\n'),
                user: geminiUser,
                createdAt: DateTime.now(),
              );
              messages.insert(0, lastMessage!);
            } else {
              lastMessage!.text += responseChunk;
            }
          });
        },
        onError: (error) {
          print("Gemini API Error: $error");
        },
        onDone: () {
          lastMessage = null;
        },
      );

      completeExpense = await _apiService.generateContent(file.path);
      print("Complete Expense: $completeExpense");
      await carbonService.generateCarbonApiJson(
          completeExpense.generalDetails, completeExpense.items);
      print("carbon footprint ${completeExpense.items[0].carbon_footprint}");
      final expenseRef = await saveExpense(
          completeExpense.generalDetails, completeExpense.items);
      print(expenseRef);
    }
  }

  Future<DocumentReference<Expense>> saveExpense(
      Expense expense, List<ExpenseItem> items) async {
    try {
      List<DocumentReference<ExpenseItem>> itemRefs = [];
      print("ExpenseItems: $items");
      for (ExpenseItem item in items) {
        final ref = await db.addExpenseItem(item);
        itemRefs.add(ref);
        print("ref: $ref");
      }

      expense.items = itemRefs;

      final expenseRef = await db.addExpense(expense);
      return expenseRef;
    } catch (e) {
      print("Error saving expense with items: $e");
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return DashChat(
      inputOptions: InputOptions(trailing: [
        IconButton(
            onPressed: _sendMediaMessage,
            icon: const Icon(
              Icons.image,
            ))
      ]),
      currentUser: currentUser,
      onSend: _sendMessage,
      messages: messages,
    );
  }
}
