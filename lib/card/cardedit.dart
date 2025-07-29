import 'package:flutter/material.dart';
import 'package:stashcard/providers/db.dart';

class CardEdit extends StatefulWidget {
  final UserCard card;

  const CardEdit({super.key, required this.card});

  @override
  State<CardEdit> createState() => _CardEditState();
}

class _CardEditState extends State<CardEdit> {
  late TextEditingController newCardName;

  @override
  void initState() {
    super.initState();
    newCardName = TextEditingController(text: widget.card.name);
  }

  @override
  void dispose() {
    newCardName.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Card"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Form(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                TextFormField(
                  controller: newCardName,
                  decoration: InputDecoration(
                    labelText: 'Name',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a name';
                    }
                    return null;
                  },
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: FilledButton(
                      onPressed: () async {
                        final db = DatabaseHelper();
                        await db.updateUserCard(widget.card.copyWith(name: newCardName.text)).then((_) {
                          Navigator.pop(context);
                        });
                      },
                      child: Text('Save'),
                  ),
                ),
              ],
            )
        ),
      ),
    );
  }}