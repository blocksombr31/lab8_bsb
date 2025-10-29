// lib/movies.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

// set state of movies to movies state
class Movies extends StatefulWidget {
  const Movies({super.key});

  @override
  MoviesState createState() => MoviesState();
}

class MoviesState extends State<Movies> {
  // create our text controller, list to display movies, and is loading bool
  final TextEditingController _controller = TextEditingController();
  final List<String> _movies = [];
  bool _isLoading = false;

  // function called when a user presses button to get movies
  Future<void> moviesFetchFromParent() async {
    // get text from our text field and parse it
    final text = _controller.text.trim();
    final numMovies = int.tryParse(text);
    // ensure the user entered a number
    if (numMovies == null || numMovies <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a positive number!')),
      );
      return;
    }
    await _getData(numMovies);
  }

  // function that clears movies and text field
  void moviesClearFromParent() {
    setState(() {
      _movies.clear();
      _controller.clear();
    });
  }

  // function used to actually reach out to the TMDB movies website and
  // get movies using our api key
  Future<void> _getData(int numMovies) async {
    final token = dotenv.env['TMDB_READ_ACCESS_TOKEN'];
    if (token == null || token.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Invalid access token to TMDB, please check or update the .env file.',
          ),
        ),
      );
      return;
    }

    // set is loading to true so that we get our loading icon
    setState(() {
      _isLoading = true;
    });

    // variables used to ensure we follow conventions of getting data
    // from TMDB and to hold some data
    final List<String> collected = [];
    int page = 1;
    const int pageSize = 20;
    final int maxPages = ((numMovies / pageSize).ceil()).clamp(1, 10);

    // loop until we get as many movies as specified earlier
    try {
      while (collected.length < numMovies && page <= maxPages) {
        // create the uri for connecting to the movies db and specify location
        final uri = Uri.https('api.themoviedb.org', '/3/movie/popular', {
          'language': 'en-US',
          'page': page.toString(),
        });

        // actually reach out to the movies db using our key from .env
        final response = await http.get(uri, headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        });

        if (response.statusCode != 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Network error: ${response.statusCode}')),
          );
          break;
        }

        // breakdown the response into a list of dynamics that we can
        // parse into readable movie data using jsondecode
        final Map<String, dynamic> body = jsonDecode(response.body);
        final List<dynamic> results = (body['results'] as List<dynamic>?) ?? [];

        // parse every dynamic into a nicely formatted string which we
        // will add each to collected (what will be displayed)
        for (final item in results) {
          if (collected.length >= numMovies) break;
          final title =
              (item['title'] ?? item['original_title'] ?? '').toString();
          final release = (item['release_date'] ?? '').toString();
          String year = '';
          if (release.isNotEmpty && release.length >= 4) {
            year = ' (${release.substring(0, 4)})';
          }
          final vote = item['vote_average'] != null
              ? ' — ${item['vote_average']}'
              : '';
          collected.add('$title$year$vote');
        }
        page++;
      }

      // update our movies list so that the screen actually
      // updates with what we have gathered from movies db
      setState(() {
        _movies.clear();
        _movies.addAll(collected);
      });
    } catch (e) {
      // if something went wrong inform the user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching data: $e')),
      );
    } finally {
      // ensure that we set isloading to false so the loading icon goes away
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // set the contents of this page to have a column containing a text
    // field and a list view of movies
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        children: [
          // set the controller of the text field to the controller made above
          TextField(
            controller: _controller,
            decoration: const InputDecoration(
              hintText: 'Input the number of popular movies you want here',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
            onSubmitted: (_) => moviesFetchFromParent(),
          ),
          // add some space between text field and list for easier reading
          const SizedBox(height: 10.0),
          // ensure we have data to display, if we don't inform the user of
          // that, and if we do display it in a listview
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _movies.isEmpty
                    ? const Center(
                        child: Text(
                          'No data to display yet!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 25.0,
                          ),
                        ),
                      )
                    : ListView.separated(
                        separatorBuilder: (_, __) => const Divider(),
                        itemCount: _movies.length,
                        itemBuilder: (context, i) => ListTile(
                          title: Text(_movies[i]),
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}
