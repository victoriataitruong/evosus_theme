import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'favorites_page.dart'; 
import 'package:flutter/services.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky); // Enables immersive full-screen mode
  runApp(MyApp());
}

/// The main widget of the application, which sets up the app structure
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => WordCubit(),
      child: MaterialApp(
        title: 'Evosus Favorites',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Color(0xFFD06A32),
            primary: Color(0xFFD06A32),
            secondary: Color(0xFF5A6D75),
          ),
        ),
        home: MyHomePage(),
      ),
    );
  }
}

/// Cubit for managing the word pair generation and favorites state
class WordCubit extends Cubit<WordCubitState> {
  // List of predefined word pairs to be displayed in the app
  final List<WordPair> _wordList = [
    WordPair('Customer Relationship Management ', '(CRM)'),
    WordPair('Point of Sale ', '(POS)'),
    WordPair('Marketing ', 'Management'),
    WordPair('Field Service ', 'Management'),
    WordPair('Construction ', 'Management'),
    WordPair('Accounting ', 'and Payroll'),
    WordPair('Reporting and ', 'Analytics'),
    WordPair('Credit Card ', 'Processing'),
    WordPair('LOU ', 'App'),
  ];

  int _currentIndex = 0;

  WordCubit() : super(WordCubitState.initial());

  /// Moves to the next word pair in the list, cycling through them.
  void getNext() {
    _currentIndex = (_currentIndex + 1) % _wordList.length;
    emit(WordCubitState(
      current: _wordList[_currentIndex],
      favorites: state.favorites,
      ascending: state.ascending,
    ));
  }

  /// Toggles the favorite status of the current word pair.
  void toggleFavorite() {
    final newFavorites = List<WordPair>.from(state.favorites);
    if (newFavorites.contains(state.current)) {
      newFavorites.remove(state.current);
    } else {
      newFavorites.add(state.current);
      _sortFavorites(newFavorites);
    }
    emit(WordCubitState(current: state.current, favorites: newFavorites, ascending: state.ascending));
  }

  /// Removes a specific word pair from the favorites list.
  void removeFavorite(WordPair pair) {
    final newFavorites = List<WordPair>.from(state.favorites);
    newFavorites.remove(pair);
    emit(WordCubitState(current: state.current, favorites: newFavorites, ascending: state.ascending));
  }

  /// Toggles the sorting order of the favorites list between ascending and descending.
  void toggleSortOrder() {
    final newOrder = !state.ascending;
    final sortedFavorites = List<WordPair>.from(state.favorites)
      ..sort((a, b) => newOrder ? a.asLowerCase.compareTo(b.asLowerCase) : b.asLowerCase.compareTo(a.asLowerCase));
    emit(WordCubitState(current: state.current, favorites: sortedFavorites, ascending: newOrder));
  }

  /// Helper method to sort the list of favorites based on the current order.
  void _sortFavorites(List<WordPair> favorites) {
    favorites.sort((a, b) => state.ascending ? a.asLowerCase.compareTo(b.asLowerCase) : b.asLowerCase.compareTo(a.asLowerCase));
  }
}

/// Represents the state of the WordCubit, including the current word pair,
/// the list of favorites, and the current sorting order.
class WordCubitState {
  final WordPair current;
  final List<WordPair> favorites;
  final bool ascending;

  WordCubitState({required this.current, required this.favorites, required this.ascending});

  /// Factory method to return an initial state with a default word pair and empty favorites list.
  factory WordCubitState.initial() {
    return WordCubitState(current: WordPair('LOU ', 'App'), favorites: [], ascending: true);
  }
}

/// The home page widget which contains navigation and the content display.
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    // Decides which page to display based on selected navigation index
    Widget page;
    switch (selectedIndex) {
      case 0:
        page = GeneratorPage();
        break;
      case 1:
        page = FavoritesPage();
        break;
      default:
        throw UnimplementedError('No widget for $selectedIndex');
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return Scaffold(
          appBar: AppBar(
            toolbarHeight: 0.0,
            backgroundColor: Color(0xFFD06A32),
            actions: [],
          ),
          body: Row(
            children: [
              SafeArea(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFFD06A32), Color(0xFF5A6D75)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: SizedBox(
                    width: constraints.maxWidth >= 600 ? 200 : 80, // Adjust width for navigation rail
                    child: NavigationRail(
                      backgroundColor: Colors.transparent,
                      extended: constraints.maxWidth >= 600,
                      destinations: [
                        NavigationRailDestination(
                          icon: Icon(Icons.home, color: Colors.white),
                          label: Text('Home', style: TextStyle(color: Colors.white)),
                        ),
                        NavigationRailDestination(
                          icon: Icon(Icons.spa, color: Colors.white),
                          label: Text('Favorites', style: TextStyle(color: Colors.white)),
                        ),
                      ],
                      selectedIndex: selectedIndex,
                      onDestinationSelected: (value) {
                        setState(() {
                          selectedIndex = value;
                        });
                      },
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  color: Colors.white,
                  child: page,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// The generator page displays the word pair and allows users to like or skip it.
class GeneratorPage extends StatelessWidget {
  const GeneratorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WordCubit, WordCubitState>(builder: (context, state) {
      var pair = state.current;
      IconData icon = state.favorites.contains(pair)
          ? Icons.favorite
          : Icons.favorite_border;

      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start, // Align items towards the top
          children: [
            // Image and title moved upwards
            Align(
              alignment: Alignment.topCenter, // Center it horizontally at the top
              child: Padding(
                padding: const EdgeInsets.all(50), // Adjust padding as needed
                child: Column(
                  children: [
                    Image.asset(
                      'assets/images/evosus.png',
                      width: 150,
                      height: 150,
                    ),
                    SizedBox(height: 10), // Small space between image and text
                  ],
                ),
              ),
            ),
            // Display word pair
            BigCard(pair: pair),
            SizedBox(height: 20), // Space between word pair and buttons
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    context.read<WordCubit>().toggleFavorite();
                  },
                  icon: Icon(icon),
                  label: Text('Like'),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    context.read<WordCubit>().getNext();
                  },
                  child: Text('Next'),
                ),
              ],
            ),
            Spacer(), // This will push everything else up
          ],
        ),
      );
    });
  }
}

/// A large card displaying a word pair.
class BigCard extends StatelessWidget {
  const BigCard({super.key, required this.pair});

  final WordPair pair;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onPrimary,
    );

    return Card(
      color: theme.colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Text(
          pair.asLowerCase,
          style: style,
          semanticsLabel: "${pair.first} ${pair.second}",
        ),
      ),
    );
  }
}
