import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

// simply set random user state to _randomuserstate
class RandomUser extends StatefulWidget {
  const RandomUser({super.key});

  @override
  State<RandomUser> createState() => RandomUserState();
}

class RandomUserState extends State<RandomUser> {
  // create the controller for our text field
  final TextEditingController _controller = TextEditingController();

  // create the list that will display data we fetch
  final List<String> _users = [];

  // bool to track if things are loading
  bool _isLoading = false;

  // function that is called when pressing the fetch data button in our app
  // bar (on the main screen)
  Future<void> userFetchFromParent() async {
    final text = _controller.text.trim();
    final numUsers = int.tryParse(text);
    if (numUsers == null || numUsers <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a positive number!')),
      );
      return;
    }
    await _getData(numUsers);
  }

  // function called when pressing clear button in app bar from main screen
  void userClearFromParent() {
    setState(() {
      _users.clear();
      _controller.clear();
    });
  }

  // function that is used to actually get data from the randomuser website
  Future<void> _getData(int numUsers) async {
    // set loading bool to true
    setState(() {
      _isLoading = true;
    });

    // create our uri to get numUsers random users from the website
    final uri = Uri.https('randomuser.me', '/api/', {'results': numUsers.toString()});

    try {
      // get our response from the website
      final response = await http.get(uri);

      // use json to decode the response from random user, and put
      // it into a list of dynamics for easy parsing
      final Map<String, dynamic> responseBody = jsonDecode(response.body);
      final List<dynamic> resultsFromJson = responseBody['results'] ?? [];

      // create a list of parsed users and actually parse through
      // the results from json to get user data
      List<String> parsedUsers = [];
      for(int i = 0; i < resultsFromJson.length; i++) {
        final item = resultsFromJson[i];
        final name = item['name'];
        String firstName = name['first'];
        String lastName = name['last'];
        final email = item['email'];
        parsedUsers.add('$firstName $lastName : $email');
      }

      // update users by setting the state (and adding all parsed users)
      setState(() {
        _users.clear();
        _users.addAll(parsedUsers);
      });

      // if we had some type of error, inform the user of that
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching data: $e')),
      );
      // ensure that isLoading is set to false when we are done
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // set the contents of this page to contain a column
    // with a textfield and listview
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: Column(
        children: [
          // set the controller of our text field and call function to get data
          TextField(
            controller: _controller,
            decoration: InputDecoration(
              hintText: 'Input the number of users'
            ' you want here',
            border: OutlineInputBorder()),
          ),
          // add some space between text field and list for easier reading
          const SizedBox(height: 10.0),
          // ensure we have data to display, if we don't inform the user of
          // that, and if we do display it in a listview
          Expanded(
            child: _isLoading 
            ? const Center(child: CircularProgressIndicator())
             : _users.isEmpty 
              ?
              Center (child: 
                Text (
                  textAlign: TextAlign.center,
                  'No data to display yet!',
                  style: TextStyle(
                    fontSize: 25.0
                  ),
                ),
              )
              :
              ListView.separated(
                separatorBuilder: (_, __) => const Divider(), 
                itemCount: _users.length,
                itemBuilder: (context, i) {
                  return ListTile(
                    title: Text(_users[i])
                  );
                }, 
              )
          )
        ],
      ),
    );
  }
}