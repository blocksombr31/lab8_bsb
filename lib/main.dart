import 'package:flutter/material.dart';
import 'package:lab8_bsb/random_user.dart';
import 'package:lab8_bsb/movies.dart';

///
/// Author - Brady Blocksom
/// 
/// Date - 10/28/2025
/// 
/// Bugs - none known
/// 
/// Description - todo
/// 
/// Reflection - todo
/// 

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: HomePage(),
    );
  }
}

// set our homepage to be a stateful widget, using homepagestate as our
// state, which will allow us later to use tab controller to 'figure out'
// which tab we are on
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override 
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  // tell the compiler we will give the tab controller a value
  late TabController _tabController;

  // initalize home page state by initalizing our tabcontroller
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
  }

  // function to get data from the api relative to the current screen
  void _fetchData() {
    // see which tab we are on, then get data accordingly
    if(_tabController.index == 0) {
      print('random user fetch');
      // deal with random user
    } else {
      print('movies fetch');
      // deal with movies
    }
  }

  // function to clear the data from the current screen
  void _clearData() {
    if(_tabController.index == 0) {
      print('random user clear');
      // random user
    } else {
      print('movies clear');
      // movies
    }
  }

  @override
  Widget build(BuildContext context) {
    // wrap both of our tabs in a scaffold, with an app bar containing our
    // title, as well as the buttons we will use to fetch and clear data
    return Scaffold(
      appBar: AppBar(
        title: const Text('API Exploratorium'),
        actions: [
          IconButton(onPressed: _fetchData, icon: const Icon(Icons.get_app)),
          IconButton(onPressed: _clearData, icon: const Icon(Icons.clear)),
        ],
        // create our tab bar with our controller we created eariler
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Random User'),
            Tab(text: 'Movies'),
          ],
        ),
      ),
      // set the body of our scaffold to be the view of our tabs, using
      // our tab controller to help track which page we are on
      body: TabBarView(
        controller: _tabController,
        children: [
          RandomUser(),
          Movies(),
        ],
      ),
    );
  }
}