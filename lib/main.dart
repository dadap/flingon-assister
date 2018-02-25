import 'package:flutter/material.dart';
import 'database.dart';
import 'package:xml/xml.dart' as xml;
import 'dart:io';
import 'package:material_search/material_search.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'boQwI\'',
      theme: new ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or press Run > Flutter Hot Reload in IntelliJ). Notice that the
        // counter didn't reset back to zero; the application is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: new MyHomePage(title: 'boQwI\''),
    );
  }
}

class MyHomePage extends StatefulWidget {

  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Map<String, WordDatabaseEntry> _db;
  Widget _main = new Text('Please be patient while the database is loading…');

  /* Load an entry as the main widget */
  load(String destination) {
    /* Lazily initialize the database if not ready, then attempt load again. */
    if (_db == null) {
      WordDatabase.getDatabase().then((ret) {
        _db = ret;
        load(destination);
      });
    }
    setState(() {
      _main = _db[destination].toWidget();
    });
  }

  /* Build the navigation menu for the drawer. */
  List<Widget> buildmenu() {
    /* List of menu categories, items, and destinations */
    final Map<String, Map<String, String>> menu = {
      'boQwI\'' : {
        'About' : 'boQwI\':n',
      },
      'Reference': {
        'Pronunciation' : 'QIch:n',
        'Prefixes' : 'moHaq:n',
        'Noun Suffixes' : 'DIp:n',
        'Verb Suffixes' : 'wot:n',
      },
    };

    List<Widget> ret = [];

    for (String category in menu.keys) {
      List<ListTile> options = [];
      for (String name in menu[category].keys) {
        options.add(new ListTile(
          title: new Text(name),
          onTap: () {
            load(menu[category][name]);
            Navigator.pop(context);
          },
        ));
      }
      ret.add(new ExpansionTile(
        title: new Text(category),
        children: options,
        initiallyExpanded: true,
      ));
    }

    return ret;
  }

  @override
  Widget build(BuildContext context) {
    /* Initialize the database and load the "boQwI'" entry when done. */
    if (_db == null) {
      WordDatabase.getDatabase().then((ret) {
        _db = ret;
        load('boQwI\':n');
      });
    }

    return new Scaffold(
      appBar: new AppBar(
        title: new Text(widget.title),
      ),
      drawer: new Drawer(
        child: new ListView(
          children: buildmenu(),
        ),
    ),
      body: new Center(
        child: new Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            new MaterialSearchInput(
              placeholder: '  🔍 nuq Danej',
              getResults: (String query) async {
                if (_db == null) {
                  _db = await WordDatabase.getDatabase();
                }

                final results = WordDatabase.match(db: _db, query: query);

                return results.map((item) => new MaterialSearchResult<String>(
                  value: item.searchName,
                  text: item.entryName + ': ' + item.definition,
                )).toList();
              },
              onSelect: (String selected) {
                load(selected);
              }
            ),
            _main,
          ],
        ),
      ),
    );
  }
}
