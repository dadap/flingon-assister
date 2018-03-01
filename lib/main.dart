import 'package:flutter/material.dart';
import 'database.dart';
import 'package:xml/xml.dart' as xml;
import 'dart:io';
import 'package:material_search/material_search.dart';
import 'package:url_launcher/url_launcher.dart';

void main() => runApp(new MyApp());

// TODO: maybe assign this based on target (e.g. boQwI' on Android)
final String appName = 'jIboQ';

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: appName,
      theme: new ThemeData(
        primarySwatch: Colors.red,
      ),
      home: new MyHomePage(title: appName),
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
    List<String> destinationSplit = destination.split(':');
    if (destinationSplit.length < 2) {
      return;
    }

    // XXX we're not reaching this block
    if ((destinationSplit[1].contains('url')) && (destinationSplit.length > 3)) {
      print('launching ' + [destinationSplit[3], destinationSplit[4]].join(':'));
      launch([destinationSplit[3], destinationSplit[4]].join(':'));
      return;
    }

    destination = WordDatabaseEntry.normalizeSearchName(destination);

    /* Lazily initialize the database if not ready, then attempt load again. */
    if (_db == null) {
      WordDatabase.getDatabase().then((ret) {
        _db = ret;
        load(destination);
      });
    }
    setState(() {
      print('loading: $destination');
      _main = _db[destination].toWidget(
          Theme.of(context).textTheme.body1,
          onTap: load
      );
    });
  }

  /* Build the navigation menu for the drawer. */
  List<Widget> buildmenu() {
    /* List of menu categories, items, and destinations */
    final Map<String, Map<String, String>> menu = {
      appName : {
        'About' : 'boQwI\':n', // TODO write an entry for jIboQ
      },
      'Reference': {
        'Pronunciation' : 'QIch wab Ho\'DoS:n',
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

  // Display the search bar
  loadSearch() {
    setState(() {
      _main = new Expanded(
        child: new MaterialSearchInput(
          placeholder: '  🔍 nuq Danej',
          autovalidate: false,
          getResults: (String query) async {
            if (_db == null) {
              _db = await WordDatabase.getDatabase();
            }

            final results = WordDatabase.match(db: _db, query: query);

            return results.map((item) =>
            new MaterialSearchResult<String>(
              value: item.searchName,
              text: item.entryName + ': ' + item.definition,
            )).toList();
          },
          onSelect: (String selected) {
            load(selected);
          }
        )
      );
    });
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
        actions: [
          new IconButton(
            icon: const Icon(Icons.search),
            onPressed: loadSearch,
          ),
        ]
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
            _main,
          ],
        ),
      ),
    );
  }
}
