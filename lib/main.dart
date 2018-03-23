import 'package:flutter/material.dart';
import 'database.dart';
import 'package:url_launcher/url_launcher.dart';
import 'search.dart';
import 'klingontext.dart';
import 'preferences.dart';
import 'dart:async';
import 'update.dart';

void main() => runApp(new MyApp());

const String appNamepIqaD = '';

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'boQwI\'',
      theme: new ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.red,
        primaryColor: Colors.red[900],
        accentColor: Colors.redAccent,
        highlightColor: Colors.red,
      ),
      home: new MyHomePage("help"),
    );
  }
}

class MyHomePage extends StatefulWidget {

  MyHomePage(String this.entry, {Key key, this.title: appNamepIqaD}) :
    super(key: key);

  final String title;
  final String entry;

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _dbversion = '';

  /* Load an entry as the main widget */
  load(String destination, {String withTitle}) {
    List<String> destinationSplit = destination.split(':');
    if (destinationSplit.length < 2) {
      if (destination == 'prefix_chart') {
        Navigator.of(context).push(new MaterialPageRoute(builder: (ctx) => buildHelper(ctx, destination)));
      } else {
        Navigator.of(context).push(new MaterialPageRoute(builder: (ctx) => new SearchPage(query: destination)));
      }
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

    if (!destination.contains('@@')) {
      destination = WordDatabaseEntry.normalizeSearchName(destination);
    }

    Navigator.of(context).push(new MaterialPageRoute(
        builder: (BuildContext ctx) {
          return buildHelper(ctx, destination, withTitle: withTitle);
        }));
  }

  /* Build the navigation menu for the drawer. */
  List<Widget> buildmenu() {
    /* List of menu categories, items, and destinations */
    final Map<String, Map<String, String>> menu = {
      'Reference': {
        'Pronunciation' : 'QIch wab Ho\'DoS:n',
        'Prefixes' : 'moHaq:n',
        'Prefix Chart' : 'prefix_chart',
        'Noun Suffixes' : 'DIp:n',
        'Verb Suffixes' : 'wot:n',
      },
      'Useful Phrases' : {
        'Beginner\'s Conversation' : '*:sen:bc',
        'Jokes and Funny Stories' : '*:sen:joke',
        'Rite of Ascension' : '*:sen:nt',
        'QI\'lop Holiday' : '*:sen:Ql',
        'Toasts' : '*:sen:toast',
        'Lyrics' : '*:sen:lyr',
        'Curse Warfare' : '*:sen:mv',
        'Replacement Proverbs' : '*:sen:rp',
        'Secrecy Proverbs' : '*:sen:sp',
        'Empire Union Day' : '*:sen:eu',
        'Rejecting a Suitor' : '*:sen:rej',
      },
      'Media' : {
        'Klingon Lessons' : ':url:http://www.youtube.com/playlist?list=PLJrTr05h0I0OcaX5G6_5TCuIisvS4Xed6',
        'Conversational Phrases' : ':url:http://www.youtube.com/playlist?list=PLJrTr05h0I0MazOxYJq47Eqdsa9F2glPg',
        'Battle Commands' : ':url:http://www.youtube.com/playlist?list=PLJrTr05h0I0Mwfo-f1YJv1VC7pNgiqicp',
        'Other Commands' : ':url:http://www.youtube.com/playlist?list=PLJrTr05h0I0PuQHLzrhp0n4TXsOZVzYzo',
        'Curses' : ':url:http://www.youtube.com/playlist?list=PLJrTr05h0I0NHU5zsb7rd7Vz0Ed_4hLhg',
        'Other Words and Phrases' : ':url:http://www.youtube.com/playlist?list=PLJrTr05h0I0MsVYmwqMCXp8rwDjSKZzWC',
      },
      'Klingon Language Institute' : {
        'Online Lessons' : ':url:http://www.kli.org/learn-klingon-online/',
        'Ask Questions!' : ':url:http://www.kli.org/questions/categories/',
      },
    };

    List<Widget> ret = [
      new ListTile(
        title: new Text('Help'),
        onTap: () {
          Navigator.pop(context);
          Navigator.push(context, new MaterialPageRoute(
            builder: (c) => new MyHomePage('help')));
        },
        trailing: new Icon(Icons.help),
      ),
      new ListTile(
        title: new Text('Preferences'),
        onTap: () {
          Navigator.pop(context);
          Navigator.push(context, new MaterialPageRoute(
            builder: (c) => new PreferencesPage()));
        },
        trailing: new Icon(Icons.settings),
      )
    ];

    for (String category in menu.keys) {
      List<ListTile> options = [];
      for (String name in menu[category].keys) {
        options.add(new ListTile(
          title: new Text(name),
          onTap: () {
            Navigator.pop(context);
            load(menu[category][name], withTitle: name);
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

  Widget getEntry(String entry, BuildContext context, {String withTitle}) {
    Widget ret;

    if (WordDatabase.db == null) {
      ret = const Text('Error: database not initialized!');
    } else if (entry.startsWith('*:')) {
      // Load all entries with the given category
      List<Widget> entries = [
        new ListTile(title: new Text(
          withTitle,
          style: new TextStyle(fontWeight: FontWeight.bold),
        ),),
      ];

      WordDatabase.db.values.where((elem) {
        return elem.partOfSpeech == entry.substring(2);
      }).forEach((elem) {
        entries.add(elem.toListTile(onTap: () => load(elem.searchName)));
      });

      ret = new Expanded(child: new ListView(children: entries));
    } else if (entry.contains('@@')) {
      // Load components of an explicitly parsed phrase
      List<Widget> entries = [
        new ListTile(title: new KlingonText(
          fromString: 'Components of: {${entry}}',
          style: new TextStyle(fontWeight: FontWeight.bold),
        ),
        ),
      ];

      for (String component in entry.split('@@')[1].split(',')) {
        String c = component.trim();
        entries.add(WordDatabase.db[c].toListTile(onTap: () => load(c)));
      }

      ret = new Expanded(child: new ListView(children: entries,));
    } else if (entry.endsWith(':0') && entry.split(':').length > 2) {
      // Load all homophones with the given part of speech
      String name = entry.split(':')[0];
      String pos = entry.split(':')[1];

      List<Widget> entries = [
        new ListTile(title: new KlingonText(
          fromString: 'Homophones for: {${entry}} ($pos)',
          style: new TextStyle(fontWeight: FontWeight.bold)
        ))
      ];

      WordDatabase.db.values.where((e) => e.entryName == name &&
        e.partOfSpeech.startsWith(pos)).forEach((m) =>
          entries.add(m.toListTile(onTap: () => load(m.searchName))));

      ret = new Expanded(child: new ListView(children: entries,));
    } else if (WordDatabase.db[entry] == null) {
      ret = new Text('The entry {$entry} was not found in the database.');
    } else {
      ret = WordDatabase.db[entry].toWidget(
        Theme.of(context).textTheme.body1,
        onTap: load,
      );
    }

    return new Column(children: [ret]);
  }

  Widget buildHelper(BuildContext context, String entry, {String withTitle}) {
    Widget main = new CircularProgressIndicator();

    // Lazily initialize the database and load destination entry when done.
    if (WordDatabase.db == null) {
      WordDatabase.getDatabase().then((ret) {
        if (entry != 'help') {
          setState(() {
            main = getEntry(entry, context, withTitle: withTitle);
            _dbversion = 'Database version ${WordDatabase.version}';
          });
        }
      });
    } else {
      if (entry != 'help') {
        main = getEntry(entry, context, withTitle: withTitle);
      }
      _dbversion = 'Database version ${WordDatabase.version}';
    }

    if (entry == 'help') {
      Widget help = new ListView(children: [new Padding(
        padding: new EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
        child: new Column(children: [
          new KlingonText(fromString:
            '{tlhIngan Hol boQwI\':n:nolink}',
            style: Theme.of(context).textTheme.headline,
          ),
          new Text(
              '"Klingon Language Assistant"',
              style: Theme.of(context).textTheme.subhead
          ),
          new Text(_dbversion),
          new KlingonText(fromString:
            '\nTo begin searching, simply press the "Search" (magnifying '
            'glass) button and type into the search box.\n\n'
            'It is recommended to install a Klingon keyboard. Otherwise, to '
            'make it easier to type Klingon on a mobile keyboard, the '
            'following shorthand (called "xifan hol") can be enabled under the '
            'Preferences menu:\n'
            'c ▶ {ch:sen:nolink} / d ▶ {D:sen:nolink} / f ▶ {ng:sen:nolink} / '
            'g ▶ {gh:sen:nolink} / h ▶ {H:sen:nolink} /\n'
            'i ▶ {I:sen:nolink} / k ▶ {Q:sen:nolink} / s ▶ {S:sen:nolink} / '
            'x ▶ {tlh:sen:nolink} / z ▶ {\':sen:nolink}\n'
            'It is also possible to choose the alternate keymapping:\n'
            'k ▶ {q:sen:nolink} / q ▶ {Q:sen:nolink}\n\n'
            'If you encounter any problems, or have any suggestions, please '
            '{file an issue:url:http://github.com/dadap/flingon-assister/issues}'
            ' on GitHub.\n\n'
            'Please support the Klingon language by purchasing '
            '{The Klingon Dictionary:src}, '
            '{Klingon for the Galactic Traveler:src}, {The Klingon Way:src}, '
            '{Conversational Klingon:src}, {Power Klingon:src}, and other '
            'Klingon- and Star Trek-related products from Pocket Books, Simon '
            '& Schuster, and Paramount/Viacom/CBS Entertainment.\n\n'
            'Klingon, Star Trek, and related marks are trademarks of CBS '
            'Studios, Inc., and are used under "fair use" guidelines.\n\n'
            'Original {boQwI\':n:nolink} app: {De\'vID:n:name}\n'
            'Flutter port: Daniel Dadap\n'
            'Klingon-English Data: {De\'vID:n:nolink}, with help from others\n'
            'German translations: {Quvar:n:name} (Lieven L. Litaer)\n'
            'TNG {pIqaD:n} font: Admiral {qurgh lungqIj:n:name,nolink} of the '
            '{Klingon Assault Group:url:http://www.kag.org/}\n'
            'DSC {pIqaD:n:nolink} font: {Quvar:n:name,nolink} '
            '(Lieven L. Litaer)\n'
            '{pIqaD qolqoS:n:nolink} font: Daniel Dadap\n\n'
            'Special thanks to Mark Okrand ({marq \'oqranD:n:name}) for '
            'creating the Klingon language.',
          style: Theme.of(context).textTheme.body1,
          onTap: (dest) => load(dest),
        ),
      ]))]);

      main = help;
      // Reload widget after preferences are loaded to handle pIqaD settings
      Preferences.loadPreferences().then((p) => setState(() => main = help));
    }

    if (entry == 'prefix_chart') {
      main = new SingleChildScrollView(scrollDirection: Axis.horizontal,child: new Table(
        columnWidths: {
          0 : new FixedColumnWidth(80.0),
          1 : new FixedColumnWidth(50.0),
          2 : new FixedColumnWidth(50.0),
          3 : new FixedColumnWidth(50.0),
          4 : new FixedColumnWidth(50.0),
          5 : new FixedColumnWidth(50.0),
          6 : new FixedColumnWidth(50.0),
          7 : new FixedColumnWidth(50.0)},
        defaultVerticalAlignment: TableCellVerticalAlignment.bottom,
        children:[
          new TableRow(children: [
            new Text(''),
            new Text('none', textAlign: TextAlign.center,),
            new Text('me', textAlign: TextAlign.center,),
            new Text('you', textAlign: TextAlign.center,),
            new Text('him/\nher/\nit', textAlign: TextAlign.center,),
            new Text('us', textAlign: TextAlign.center,),
            new Text('you\n(pl)', textAlign: TextAlign.center,),
            new Text('them', textAlign: TextAlign.center,),
          ]),
          new TableRow(children: [
            new Text('I', textAlign: TextAlign.right,),
            new Center(child: new KlingonText(fromString: '{jI-:v:pref}')),
            new Center(child: new Text('-')),
            new Center(child: new KlingonText(fromString: '{qa-:v:pref}')),
            new Center(child: new KlingonText(fromString: '{vI-:v:pref}')),
            new Center(child: new Text('-')),
            new Center(child: new KlingonText(fromString: '{Sa-:v:pref}')),
            new Center(child: new KlingonText(fromString: '{vI-:v:pref}')),
          ]),
          new TableRow(children: [
            new Text('you', textAlign: TextAlign.right,),
            new Center(child: new KlingonText(fromString: '{bI-:v:pref}')),
            new Center(child: new KlingonText(fromString: '{cho-:v:pref}')),
            new Center(child: new Text('-')),
            new Center(child: new KlingonText(fromString: '{Da-:v:pref}')),
            new Center(child: new KlingonText(fromString: '{ju-:v:pref}')),
            new Center(child: new Text('-')),
            new Center(child: new KlingonText(fromString: '{Da-:v:pref}')),
          ]),
          new TableRow(children: [
            new Text('he/she/it', textAlign: TextAlign.right,),
            new Center(child: new Text('0')),
            new Center(child: new KlingonText(fromString: '{mu-:v:pref}')),
            new Center(child: new KlingonText(fromString: '{Du-:v:pref}')),
            new Center(child: new Text('0')),
            new Center(child: new KlingonText(fromString: '{nu-:v:pref}')),
            new Center(child: new KlingonText(fromString: '{lI-:v:pref}')),
            new Center(child: new Text('0')),
          ]),
          new TableRow(children: [
            new Text('we', textAlign: TextAlign.right,),
            new Center(child: new KlingonText(fromString: '{ma-:v:pref}')),
            new Center(child: new Text('-')),
            new Center(child: new KlingonText(fromString: '{pI-:v:pref}')),
            new Center(child: new KlingonText(fromString: '{wI-:v:pref}')),
            new Center(child: new Text('-')),
            new Center(child: new KlingonText(fromString: '{re-:v:pref}')),
            new Center(child: new KlingonText(fromString: '{DI-:v:pref}')),
          ]),
          new TableRow(children: [
            new Text('you (pl)', textAlign: TextAlign.right,),
            new Center(child: new KlingonText(fromString: '{Su-:v:pref}')),
            new Center(child: new KlingonText(fromString: '{tu-:v:pref}')),
            new Center(child: new Text('-')),
            new Center(child: new KlingonText(fromString: '{bo-:v:pref}')),
            new Center(child: new KlingonText(fromString: '{che-:v:pref}')),
            new Center(child: new Text('-')),
            new Center(child: new KlingonText(fromString: '{bo-:v:pref}')),
          ]),
          new TableRow(children: [
            new Text('they', textAlign: TextAlign.right,),
            new Center(child: new Text('0')),
            new Center(child: new KlingonText(fromString: '{mu-:v:pref}')),
            new Center(child: new KlingonText(fromString: '{nI-:v:pref}')),
            new Center(child: new KlingonText(fromString: '{lu-:v:pref}')),
            new Center(child: new KlingonText(fromString: '{nu-:v:pref}')),
            new Center(child: new KlingonText(fromString: '{lI-:v:pref}')),
            new Center(child: new Text('0')),
          ]),
          new TableRow(children: [
            new Text(' '),
            new Text(' '),
            new Text(' '),
            new Text(' '),
            new Text(' '),
            new Text(' '),
            new Text(' '),
            new Text(' '),
          ]),
          new TableRow(children: [
            new Text('you (imp)', textAlign: TextAlign.right,),
            new Center(child: new KlingonText(fromString: '{yI-:v:pref}')),
            new Center(child: new KlingonText(fromString: '{HI-:v:pref}')),
            new Center(child: new Text('-')),
            new Center(child: new KlingonText(fromString: '{yI-:v:pref}')),
            new Center(child: new KlingonText(fromString: '{gho-:v:pref}')),
            new Center(child: new Text('-')),
            new Center(child: new KlingonText(fromString: '{tI-:v:pref}')),
          ]),
          new TableRow(children: [
            new Text('you (imp,pl)', textAlign: TextAlign.right,),
            new Center(child: new KlingonText(fromString: '{pe-:v:pref}')),
            new Center(child: new KlingonText(fromString: '{HI-:v:pref}')),
            new Center(child: new Text('-')),
            new Center(child: new KlingonText(fromString: '{yI-:v:pref}')),
            new Center(child: new KlingonText(fromString: '{gho-:v:pref}')),
            new Center(child: new Text('-')),
            new Center(child: new KlingonText(fromString: '{tI-:v:pref}')),
          ]),
        ],
      ));
    }

    return new Scaffold(
      appBar: new AppBar(
          title: new GestureDetector(
            child: new Text(
              widget.title,
              style: widget.title == appNamepIqaD ?
                new TextStyle(fontFamily: 'TNGpIqaD') : null,
            ),
            onTap: widget.title == appNamepIqaD && entry != 'help' ?
              () => Navigator.of(context).push(
                new MaterialPageRoute(builder: (c) => new MyHomePage('help')))
              : null,
          ),
          actions: [
            new IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                Navigator.of(context).push(
                  new MaterialPageRoute(builder: (ctx) => new SearchPage())
                );
              },
            ),
          ]
      ),
      drawer: entry == 'help' ? new Drawer(
        child: new ListView(
          children: buildmenu(),
        ),
      ) : null,
      body: new Center(
        child: main,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Preferences.loadPreferences();

    return buildHelper(context, widget.entry);
  }
}