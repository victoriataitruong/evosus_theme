import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'main.dart'; // Ensure this points to where WordCubit is defined

class FavoritesPage extends StatefulWidget {
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
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Tooltip(
              message: 'Toggle Sort Order', // Tooltip text
              child: Row(
                children: [
                  Text('Sort'), // Label on the left side of the icon
                  IconButton(
                    icon: Icon(Icons.sort),
                    onPressed: () {
                      context.read<WordCubit>().toggleSortOrder(); // Toggle sort order
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
        Expanded(
          child: BlocBuilder<WordCubit, WordCubitState>(  // Watch for state changes
            builder: (context, state) {
              List<WordPair> filteredFavorites = state.favorites
                  .where((pair) => pair.asLowerCase.contains(_searchQuery.toLowerCase()))
                  .toList();

              return filteredFavorites.isEmpty
                  ? Center(child: Text('No matching favorites.'))
                  : ListView.builder(
                      itemCount: filteredFavorites.length,
                      itemBuilder: (context, index) {
                        final pair = filteredFavorites[index];
                        return ListTile(
                          leading: Container(
                            width: 25,  // Set width of the image
                            height: 25, // Set height of the image
                            child: Image.asset('assets/images/evosus_logo.png'),
                          ),
                          title: Text(pair.asLowerCase),
                          trailing: IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              context.read<WordCubit>().removeFavorite(pair);  // Use removeFavorite
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
