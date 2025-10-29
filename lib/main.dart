import 'dart:io';
import 'package:flutter/material.dart';
import 'package:lab8_bsb/random_user.dart';
import 'package:lab8_bsb/movies.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

///
/// Author - Brady Blocksom
/// 
/// Date - 10/28/2025
/// 
/// Bugs - none known
/// 
/// Description - This app contains two tabs, one of which allows the user
/// to generate some number of random users which will display their name
/// and email. The other tab allows the user to get some number of popular
/// movies and display when it came out, the name of it, and the rating.
/// 
/// Reflection - Most of this assignment went fairly smoothly for me. The parts
/// that went well, went very well. The parts that I struggled with however, were
/// rather stressful. I struggled with actually decoding/parsing information from
/// the websites. I also struggled with putting my api key in a .env file so that
/// it's at least hidden from github, but while doing so I kept on getting errors
/// where the program couldn't even find the .env file.
/// 

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // load our env file containing our api key for movies
  try {
    await dotenv.load(fileName: ".env");
  } catch (e, st) {
    print('dotenv.load failed: $e\n$st');
  }

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

  // create a global key with random user and movies so we
  // can call functions there from here
  final GlobalKey<RandomUserState> _randomUserKey = GlobalKey<RandomUserState>();
  final GlobalKey<MoviesState> _moviesKey = GlobalKey<MoviesState>();

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
      _randomUserKey.currentState?.userFetchFromParent();
    } else {
      _moviesKey.currentState?.moviesFetchFromParent();
    }
  }

  // function to clear the data from the current screen
  void _clearData() {
    if(_tabController.index == 0) {
      _randomUserKey.currentState?.userClearFromParent();
    } else {
      _moviesKey.currentState?.moviesClearFromParent();
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
          RandomUser(key: _randomUserKey),
          Movies(key: _moviesKey),
        ],
      ),
    );
  }
}