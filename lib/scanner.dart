import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:stocard_alternative/db.dart';
import 'carddetail.dart';
import 'main.dart';

class Scanner extends StatefulWidget {
  const Scanner({super.key, required this.cardName});

  final String cardName;

  @override
  State<StatefulWidget> createState() => _Scanner();
}

MobileScannerController controller = MobileScannerController();


class _Scanner extends State<Scanner> {
  Barcode barcode = Barcode();
  late String cardName;
  bool _isBarcodeProcessed = false;

  @override
  void initState() {
    super.initState();
    controller.start();
    cardName = widget.cardName;
  }

  void _handleScan(BarcodeCapture barcodes) async {
    if (_isBarcodeProcessed) return;

    if (barcodes.barcodes.isNotEmpty) {
      _isBarcodeProcessed = true;
      controller.stop();
      setState(() {
        barcode = barcodes.barcodes.first;
      });
    } else {
      print("No barcode detected.");
      return;
    }

    final db = DatabaseHelper();

    try {
      final code = int.parse(barcode.displayValue!);
      await db.insertCard(UserCard(
          name: cardName,
          code: code,
          usage: 0,
          createdAt: DateTime.now()
      ));

      final card = await db.getLastAddedCard();

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const StocardApp()),
            (Route<dynamic> route) => false,
      );

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => CardDetail(cardId: card.id)),
      );
    } catch (e) {
      rethrow;
    }

  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text("Scan a card"),
      ),
      body: MobileScanner(
        controller: controller,
        onDetect: _handleScan,
      )
    );
  }
}