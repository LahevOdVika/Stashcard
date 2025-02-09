import 'package:flutter/material.dart';
import 'package:stocard_alternative/cardedit.dart';
import 'package:stocard_alternative/db.dart';
import 'package:stocard_alternative/main.dart';
import 'package:syncfusion_flutter_barcodes/barcodes.dart';

enum CardOptions { edit, share, delete }

class CardDetail extends StatefulWidget {
  const CardDetail({super.key, required this.cardId});

  final int? cardId;

  @override
  State<CardDetail> createState() => _CardDetailState();
}

class _CardDetailState extends State<CardDetail> {
  CardOptions? selectedOption;
  UserCard? card; // Ukládáme kartu do State

  @override
  void initState() {
    super.initState();
    _refreshCard();
  }

  void _refreshCard() async {
    final db = DatabaseHelper();
    final newCard = await db.getOneCard(widget.cardId!);
    setState(() {
      card = newCard;
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          _refreshCard(); // Refresh při návratu
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Card Detail"),
          actions: [
            PopupMenuButton(
              initialValue: selectedOption,
              onSelected: (CardOptions option) {
                setState(() {
                  selectedOption = option;
                });
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<CardOptions>>[
                PopupMenuItem(
                  value: CardOptions.edit,
                  child: const Text("Edit"),
                  onTap: () async {
                    if (card != null) {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => CardEdit(card: card!)),
                      );
                      _refreshCard();
                    }
                  },
                ),
                const PopupMenuItem(
                  value: CardOptions.share,
                  child: Text("Share"),
                ),
                PopupMenuItem(
                  value: CardOptions.delete,
                  child: const Text("Delete"),
                  onTap: () => showDialog(
                      context: context,
                      builder: (BuildContext context) => AlertDialog(
                        icon: const Icon(Icons.warning),
                        iconColor: Colors.red,
                        title: const Text("Delete card"),
                        content: const Text("Are you sure you want to delete this card?"),
                        actions: [
                          OutlinedButton(
                            onPressed: () async {
                              final db = DatabaseHelper();
                              await db.deleteUserCard(widget.cardId!);
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(builder: (context) => StocardApp()),
                                    (route) => false,
                              );
                            },
                            child: const Text("Delete"),
                          ),
                          FilledButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text("Cancel"),
                          ),
                        ],
                      )
                  )
                ),
              ],
            ),
          ],
        ),
        body: card == null
            ? const Center(child: CircularProgressIndicator())
            : Column(
          children: [
            const SizedBox(height: 30),
            Text(
              card!.name,
              style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            Container(
              padding: const EdgeInsets.all(10),
              height: 200,
              child: SfBarcodeGenerator(
                value: card!.code.toString(),
                showValue: true,
                textSpacing: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
