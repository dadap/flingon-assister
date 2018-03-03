import 'package:flutter/material.dart';
import 'database.dart';
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

    if (destinationSplit[1].contains('url') && destinationSplit.length > 3) {
      launch(destinationSplit.skip(2).join(':'));
      return;
    }

    if (destinationSplit[1].contains('mailto') && destinationSplit.length > 2) {
      launch(destinationSplit.skip(1).join(':'));
      return;
    }

    destination = WordDatabaseEntry.normalizeSearchName(destination);

    Navigator.of(context).push(new MaterialPageRoute(
        builder: (BuildContext ctx) {
          return buildHelper(ctx, destination);
        }));
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
      'Useful Phrases' : {
        'Beginner\'s Conversation' : '*:sen:bc',
        'Jokes and Funy Stories' : '*:sen:joke',
        'Rite of Ascension' : '*:sen:nt',
        'QI\'lop holiday' : '*:sen:Ql',
        'Toasts' : '*:sen:toast',
        'Lyrics' : '*:sen:lyr',
        'Curse Warfare' : '*:sen:mv',
        'Replacement Proverbs' : '*:sen:rp',
        'Secrecy Proverbs' : '*:sen:sp',
        'Empire Union Day' : '*:sen:eu',
        'Rejecting a suitor' : '*:sen:rej',
      },
      'Media' : {
        'Klingon lessons' : ':url:http://www.youtube.com/playlist?list=PLJrTr05h0I0OcaX5G6_5TCuIisvS4Xed6',
        'Conversational phrases' : ':url:http://www.youtube.com/playlist?list=PLJrTr05h0I0MazOxYJq47Eqdsa9F2glPg',
        'Battle commands' : ':url:http://www.youtube.com/playlist?list=PLJrTr05h0I0Mwfo-f1YJv1VC7pNgiqicp',
        'Other commands' : ':url:http://www.youtube.com/playlist?list=PLJrTr05h0I0PuQHLzrhp0n4TXsOZVzYzo',
        'Curses' : ':url:http://www.youtube.com/playlist?list=PLJrTr05h0I0NHU5zsb7rd7Vz0Ed_4hLhg',
        'Other words and phrases' : ':url:http://www.youtube.com/playlist?list=PLJrTr05h0I0MsVYmwqMCXp8rwDjSKZzWC',
      },
      'Klingon Language Institute' : {
        'Online Lessons' : ':url:http://www.kli.org/learn-klingon-online/',
        'Ask Questions!' : ':url:http://www.kli.org/questions/categories/',
      },
    };

    List<Widget> ret = [];

    for (String category in menu.keys) {
      List<ListTile> options = [];
      for (String name in menu[category].keys) {
        options.add(new ListTile(
          title: new Text(name),
          onTap: () {
            Navigator.pop(context);
            load(menu[category][name]);
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

  // Display the search page
  loadSearch() {
    Widget main;

    TextEditingController controller = new TextEditingController();
    Function onPressed;
    Function clearText = () => setState(() {
      controller.clear();
    });

    Navigator.of(context).push(new MaterialPageRoute(
      builder: (BuildContext ctx) {
        // XXX this isn't updating state consistently when typing a search
        // query without pressing enter.
        controller.addListener(() {
          if (_db == null) {
            setState(() {
              main = new CircularProgressIndicator();
            });

            WordDatabase.getDatabase().then((db) {
              _db = db;
              setState(() {main = null;});
            });
          }

          if (controller.text.isEmpty) {
            setState(() {
              onPressed = null;
              main = null;
            });
          } else if (_db != null) {
            List<Widget> results = [];
            Widget newMain;

            WordDatabase.match(db: _db, query: controller.text).forEach((e) {
              results.add(e.toListTile(onTap: () => load(e.searchName)));
            });

            newMain = new Column(
              children: [new Expanded(child: new ListView(children: results))
            ],);

            setState(() {
              onPressed = clearText;
              main = newMain;
            });
          }
        });

        return new Scaffold(
          appBar: new AppBar(
            title: new TextField(
              autofocus: true,
              autocorrect: false,
              style: Theme.of(context).textTheme.title,
              controller: controller,
            ),
            actions: [
              new IconButton(
                icon: new Icon(Icons.clear),
                onPressed: onPressed,
              ),
            ],
          ),
          body: new Center(child: main),
        );
      }
    ));
  }

  Widget getEntry(String entry, BuildContext context) {
    Widget ret;

    if (_db == null) {
      ret = const Text('Error: database not initialized!');
    } else if (entry.startsWith('*:')) {
      List<Widget> entries = [];

      _db.values.where((elem) {
        return elem.partOfSpeech == entry.substring(2);
      }).forEach((elem) {
        entries.add(elem.toListTile(onTap: () => load(elem.searchName)));
      });

      ret = new Expanded(child: new ListView(children: entries));
    } else if (_db[entry] == null) {
      ret = new Text('The entry {$entry} was not found in the database.');
    } else {
      ret = _db[entry].toWidget(Theme.of(context).textTheme.body1, onTap: load);
    }

    return new Column(children: [ret]);
  }

  Widget buildHelper(BuildContext context, String entry) {
    Widget main = new CircularProgressIndicator();

      // Lazily nitialize the database and load destination entry when done.
      if (_db == null) {
        WordDatabase.getDatabase().then((ret) {
          _db = ret;
          setState(() {
            main = getEntry(entry, context);
          });
        });
      } else {
        main = getEntry(entry, context);
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
          child: main,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return buildHelper(context, 'boQwI\':n');
  }
}
