import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:stashcard/main.dart';
import 'package:stashcard/providers/db.dart';
import 'carddetail.dart';
import 'package:stashcard/models/card.dart';

class Scanner extends StatefulWidget {
  const Scanner({super.key, required this.cardName});

  final String cardName;

  @override
  State<StatefulWidget> createState() => _Scanner();
}

class _Scanner extends State<Scanner> {
  Barcode barcode = Barcode();
  late String cardName;
  bool _isBarcodeProcessed = false;
  bool _isTorchOn = false;

  late MobileScannerController controller = MobileScannerController();

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
      return;
    }

    final db = DatabaseHelper();
    try {
      final code = barcode.displayValue!;
      await db.insertCard(UserCard(
          name: cardName,
          code: code,
          usage: 0,
          createdAt: DateTime.now(),
          symbology: barcode.format.name));

      final card = await db.getLastAddedCard();

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const NavigationHandler()),
        ModalRoute.withName('/'),
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
        body: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            MobileScanner(
              controller: controller,
              onDetect: _handleScan,
            ),
            Positioned(
              bottom: 30,
              child: IconButton(
                iconSize: 40,
                padding: const EdgeInsets.all(20),
                onPressed: () => setState(() {
                  _isTorchOn = !_isTorchOn;
                  controller.toggleTorch();
                }),
                icon: Icon(_isTorchOn ? Icons.flash_on : Icons.flash_off),
                style: ButtonStyle(
                  backgroundColor:
                  WidgetStateProperty.all<Color>(theme.primaryColor),
                ),
              ),
            ),
          ],
        ));
  }
}
