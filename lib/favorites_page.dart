import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'main.dart'; // Ensure this points to where WordCubit is defined

/// The FavoritesPage displays a list of favorite word pairs that the user can manage.
class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  FavoritesPageState createState() => FavoritesPageState();
}

class FavoritesPageState extends State<FavoritesPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search bar for filtering favorites based on user input
        Padding(
          padding: const EdgeInsets.all(75.0),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              labelText: 'Search',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
            onChanged: (query) {
              setState(() {
                _searchQuery = query;
              });
            },
          ),
        ),
        // Sort order toggle button
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Tooltip(
              message: 'Toggle Sort Order', // Tooltip text for sorting
              child: Row(
                children: [
                  Text('Sort'), // Label on the left side of the sort icon
                  IconButton(
                    icon: Icon(Icons.sort),
                    onPressed: () {
                      context.read<WordCubit>().toggleSortOrder(); // Toggle the sorting order of favorites
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
        // List of filtered and sorted favorites
        Expanded(
          child: BlocBuilder<WordCubit, WordCubitState>(  // React to state changes
            builder: (context, state) {
              // Filter favorites based on the search query
              List<WordPair> filteredFavorites = state.favorites
                  .where((pair) => pair.asLowerCase.contains(_searchQuery.toLowerCase()))
                  .toList();

              return filteredFavorites.isEmpty
                  ? Center(child: Text('No matching favorites.'))  // Message when no matches are found
                  : ListView.builder(
                      itemCount: filteredFavorites.length,
                      itemBuilder: (context, index) {
                        final pair = filteredFavorites[index];
                        bool isFavorite = state.favorites.contains(pair); // Check if the pair is in favorites
                        return ListTile(
                          leading: SizedBox(
                            width: 25,  // Set width of the logo
                            height: 25, // Set height of the logo
                            child: Image.asset('assets/images/evosus_logo.png'),
                          ),
                          title: Tooltip(
                            message: isFavorite
                                ? 'This word is in your favorites!'  // More informative tooltip for added favorites
                                : 'Click to add to favorites',  // Tooltip for non-favorite word pairs
                            child: Text(pair.asLowerCase),
                          ),
                          trailing: IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),  // Delete button to remove from favorites
                            onPressed: () {
                              context.read<WordCubit>().removeFavorite(pair);  // Remove word pair from favorites
                            },
                          ),
                        );
                      },
                    );
            },
          ),
        ),
      ],
    );
  }
}
