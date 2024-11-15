import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Movie Search App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final String apiKey = 'e547e17d4e91f3e62a571655cd1ccaff';
  final TextEditingController _searchController = TextEditingController();
  List movies = [];
  List favorites = [];

  Future<void> searchMovies(String query) async {
    final url = 'https://api.themoviedb.org/3/search/movie?api_key=$apiKey&query=$query';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        movies = data['results'];
      });
    } else {
      // Handle error
      setState(() {
        movies = [];
      });
    }
  }

  void addToFavorites(Map<String, dynamic> movie) {
    setState(() {
      if (!favorites.contains(movie)) {
        favorites.add(movie);
      }
    });
  }

  void removeFromFavorites(Map<String, dynamic> movie) {
    setState(() {
      favorites.remove(movie);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Movie Search App"),
        actions: [
          IconButton(
            icon: Icon(Icons.favorite),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FavoritesScreen(
                    favorites: favorites,
                    onRemove: removeFromFavorites,
                  ),
                ),
              );
            },
          )
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search for movies',
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () => searchMovies(_searchController.text),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: movies.length,
              itemBuilder: (context, index) {
                final movie = movies[index];
                return ListTile(
                  leading: movie['poster_path'] != null
                      ? Image.network(
                          'https://image.tmdb.org/t/p/w200${movie['poster_path']}',
                          width: 50,
                        )
                      : Icon(Icons.movie),
                  title: Text(movie['title'] ?? 'No title'),
                  subtitle: Text('Release Date: ${movie['release_date'] ?? 'N/A'}'),
                  trailing: IconButton(
                    icon: Icon(
                      favorites.contains(movie) ? Icons.favorite : Icons.favorite_border,
                      color: favorites.contains(movie) ? Colors.red : null,
                    ),
                    onPressed: () => addToFavorites(movie),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MovieDetailScreen(movie: movie),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class FavoritesScreen extends StatelessWidget {
  final List favorites;
  final Function(Map<String, dynamic>) onRemove;

  FavoritesScreen({required this.favorites, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Favorites")),
      body: ListView.builder(
        itemCount: favorites.length,
        itemBuilder: (context, index) {
          final movie = favorites[index];
          return ListTile(
            leading: movie['poster_path'] != null
                ? Image.network('https://image.tmdb.org/t/p/w200${movie['poster_path']}')
                : Icon(Icons.movie),
            title: Text(movie['title'] ?? 'No title'),
            subtitle: Text('Release Date: ${movie['release_date'] ?? 'N/A'}'),
            trailing: IconButton(
              icon: Icon(Icons.remove_circle, color: Colors.red),
              onPressed: () => onRemove(movie),
            ),
          );
        },
      ),
    );
  }
}

class MovieDetailScreen extends StatelessWidget {
  final Map<String, dynamic> movie;

  MovieDetailScreen({required this.movie});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(movie['title'] ?? 'Movie Details')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (movie['poster_path'] != null)
              Image.network('https://image.tmdb.org/t/p/w500${movie['poster_path']}'),
            SizedBox(height: 20),
            Text(
              movie['title'] ?? 'No title',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'Release Date: ${movie['release_date'] ?? 'N/A'}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 10),
            Text(
              'Rating: ${movie['vote_average']?.toString() ?? 'N/A'}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 10),
            Text(
              movie['overview'] ?? 'No synopsis available',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
