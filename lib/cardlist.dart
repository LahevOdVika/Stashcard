import 'package:flutter/material.dart';
import 'package:stashcard/scanner.dart';
import 'package:flutter/services.dart' show rootBundle;

Future<List<String>> loadCards(String filter) async {
  String fileContent = await rootBundle.loadString('assets/cardCompanies');
  return fileContent.split('\n').map((e) => e.trim()).where((e) => e.isNotEmpty && e.toLowerCase().contains(filter.toLowerCase())).toList();
}

class CardList extends StatefulWidget {
  const CardList({super.key});

  @override
  State<CardList> createState() => _CardListState();
}

class _CardListState extends State<CardList> {
  bool _isSearching = false;
  String title = "Add card";
  TextEditingController _searchController = TextEditingController();
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isSearching ?
        TextField(
          controller: _searchController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Search...',
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.white),
          ),
          onChanged: (value) {
            setState(() {
              searchQuery = value;
            });
          },
        )
            : Text(title),
        actions: [
          IconButton(
              onPressed: () {
                setState(() {
                  _isSearching = !_isSearching;
                  if (!_isSearching) {
                    _searchController.clear();
                    searchQuery = '';
                  }
                });
              },
              icon: Icon(_isSearching ? Icons.close : Icons.search),
          )
        ],
      ),
      body: CardListBody(searchQuery: searchQuery,),
    );
  }
}

class CardListBody extends StatefulWidget {
  final String searchQuery;

  const CardListBody({super.key, this.searchQuery = ''});

  @override
  State<CardListBody> createState() => _CardListBodyState();
}

class _CardListBodyState extends State<CardListBody> {
  late Future<List<String>> _futureCardNames;

  @override
  void initState() {
    super.initState();
    _futureCardNames = loadCards(widget.searchQuery);
  }

  @override
  void didUpdateWidget(covariant CardListBody oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.searchQuery != oldWidget.searchQuery) {
      setState(() {
        _futureCardNames = loadCards(widget.searchQuery);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<String>>(
      future: _futureCardNames,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text("Chyba: ${snapshot.error}"));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("Žádné karty"));
        }

        final cards = snapshot.data!;

        return ListView.separated(
          separatorBuilder: (_, __) => const Divider(),
          itemCount: cards.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(cards[index]),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(
                    builder: (context) => Scanner(cardName: cards[index])
                ));
              },
            );
          },
        );
      },
    );
  }
}
