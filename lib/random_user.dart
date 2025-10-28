import 'package:flutter/material.dart';

// simply set random user state to _randomuserstate
class RandomUser extends StatefulWidget {
  const RandomUser({super.key});

  @override
  State<RandomUser> createState() => _RandomUserState();
}

class _RandomUserState extends State<RandomUser> {
  // create the controller for our text field
  final TextEditingController _controller = TextEditingController();

  // create the list that will display data we fetch
  final List<String> _users = [];

  // function for actually getting data from random user website using
  // the value from our text field
  void _getData(String value) {
    // todo
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
      padding: EdgeInsetsGeometry.all(10.0),
      child: Column(
        children: [
          // set the controller of our text field and call function to get data
          TextField(
            controller: _controller,
            onSubmitted:(value) => _getData(value),
            decoration: InputDecoration(hintText: 'Input to fetch data here...'),
          ),
          // add some space between text field and list for easier reading
          const SizedBox(height: 10.0),
          // ensure we have data to display, if we don't inform the user of
          // that, and if we do display it in a listview
          Expanded(
            child: _users.isEmpty 
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