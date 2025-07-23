import 'package:flutter/material.dart';
import 'package:stashcard/carddetail.dart';
import 'package:stashcard/cardlist.dart';
import 'package:stashcard/db.dart';
import 'package:stashcard/settings.dart';
import 'package:url_launcher/url_launcher.dart';

enum SortOptions { byName, byDateCreated, byUsage }

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  ThemeMode themeMode = ThemeMode.system;
  runApp(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        ),
        darkTheme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.green, brightness: Brightness.dark),
          brightness: Brightness.dark
        ),
        home: Stashcard(),
        themeMode: themeMode,
      )
  );
}

class Stashcard extends StatefulWidget {
  const Stashcard({super.key});

  @override
  State<Stashcard> createState() => _StashcardState();
}

class _StashcardState extends State<Stashcard> {
  SortOptions selectedSort = SortOptions.byName;
  bool _isSearching = false;
  TextEditingController _searchController = TextEditingController();
  String searchQuery = '';
  int currentPageIndex = 0;

  @override
  Widget build(BuildContext context) {
    const String title = 'Stashcard';

    final List<Widget> pages = <Widget>[
      CardGrid(selectedOption: selectedSort, searchQuery: searchQuery,),
      SettingsPage()
    ];

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
            icon: Icon(_isSearching ? Icons.close : Icons.search)
          ),
          IconButton(
            onPressed: () {
              showDialog(
                  context: context,
                  builder: (BuildContext context) => Theme(
                    data: ThemeData.from(colorScheme: ColorScheme.of(context)),
                  child: AlertDialog(
                    title: const Text("Donate"),
                    icon: const Icon(Icons.favorite),
                    iconColor: Colors.red,
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      spacing: 10,
                      children: [
                        const Text(
                          "I'm a student and I work on this app in my free time. If you like it, you can support development by donating. And if you don't want to donate, that's fine too.",
                          softWrap: true,
                        ),
                        const Text("Enjoy the app!", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),)
                      ],
                    ),
                    actions: [
                      FilledButton(
                        onPressed: () => {
                          launchUrl(Uri.parse("https://ko-fi.com/lahev"))
                        },
                        child: const Text('Donate'),
                      ),
                      OutlinedButton(
                        onPressed: () => {
                          Navigator.pop(context)
                        },
                        child: const Text('Close'),
                      )
                    ],
                  )
              ));
            },
            icon: const Icon(Icons.favorite_border),
          ),
          PopupMenuButton<SortOptions>(
            initialValue: selectedSort,
            onSelected: (SortOptions sort) {
              setState(() {
                selectedSort = sort;
              });
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<SortOptions>>[
              const PopupMenuItem(
                  value: SortOptions.byName,
                  child: Text('Sort by name')
              ),
              const PopupMenuItem(
                  value: SortOptions.byDateCreated,
                  child: Text('Sort by date created')
              ),
              const PopupMenuItem(
                  value: SortOptions.byUsage,
                  child: Text('Sort by usage')
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: Builder(
        builder: (BuildContext context) {
          return FloatingActionButton(
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CardList())
              );
            },
            child: const Icon(Icons.add),
          );
        },
      ),
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          setState(() {
            currentPageIndex = index;
          });
        },
        selectedIndex: currentPageIndex,
        destinations: const <Widget>[
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: "Home"),
          NavigationDestination(icon: Icon(Icons.settings_outlined), selectedIcon: Icon(Icons.settings), label: "Settings"),
        ],
      ),
      body: pages[currentPageIndex],
    );
  }
}

class CardGrid extends StatefulWidget {

  final SortOptions selectedOption;
  final String searchQuery;

  const CardGrid({super.key, required this.selectedOption, this.searchQuery = ''});

  @override
  State<CardGrid> createState() => _CardGridState();
}

class _CardGridState extends State<CardGrid> {
  late Future<List<UserCard>> _futureCards;
  final db = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    _futureCards = _loadCards();
  }

  Future<List<UserCard>> _loadCards() async {
    return await db.getUserCardsSorted(widget.selectedOption);
  }

  Future<void> _refreshCards() async {
    setState(() {
      _futureCards = _loadCards();
    });

    await _futureCards;
  }

  @override
  void didUpdateWidget(covariant CardGrid oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.selectedOption != oldWidget.selectedOption) {
      _refreshCards();
    }

    if (widget.searchQuery != oldWidget.searchQuery) {
      _refreshCards();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<UserCard>>(
      future: _futureCards,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text("Chyba: ${snapshot.error}"));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("Žádné karty"));
        }

        final userCards = snapshot.data!;
        final filteredCards = userCards.where((userCard) {
          return widget.searchQuery.isEmpty || userCard.name.toLowerCase().contains(widget.searchQuery.toLowerCase());
        }).toList();

        return RefreshIndicator(
          onRefresh: () => _refreshCards(),
          child: GridView.builder(
              padding: const EdgeInsets.all(20),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 1.5,
              ),
              itemCount: filteredCards.length,
              itemBuilder: (context, index) {
                final userCard = filteredCards[index];
                return GestureDetector(
                  onTap: () async {
                    await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => CardDetail(cardId: userCard.id,))
                    );
                    db.incrementUsage(userCard.id!);
                    _refreshCards();
                  },
                  child: Card(
                    elevation: 2,
                    child: Center(
                      child: Text(userCard.name),
                    ),
                  ),
                );
              },
          ),
        );
      },
    );
  }
}