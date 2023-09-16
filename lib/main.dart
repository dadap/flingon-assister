import 'package:flutter/material.dart';
import 'database.dart';
import 'search.dart';
import 'klingontext.dart';
import 'preferences.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart'
    show debugDefaultTargetPlatformOverride;
import 'l10n.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'dart:async';

void main() {
  // See https://github.com/flutter/flutter/wiki/Desktop-shells#target-platform-override
  debugDefaultTargetPlatformOverride = TargetPlatform.fuchsia;
  runApp(new MyApp());
}

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
        accentColor: Colors.redAccent,
        toggleableActiveColor: Colors.redAccent,
      ),
      home: new MyHomePage("help"),
      localizationsDelegates: [
        const L10nDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('en', ''),
        const Locale('de', ''),
      ],
    );
  }
}

class MyHomePage extends StatefulWidget {

  MyHomePage(this.entry,
             {Key key, this.title: appNamepIqaD, this.secondTitle: ""}) :
    super(key: key);

  final String title;
  final String secondTitle;
  final String entry;

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<IconButton> _actions = [];

  static const BasicMessageChannel<String> messageChannel =
    const BasicMessageChannel<String>("load", const StringCodec());

  String _dbversion = '';
  static bool loadHandlerRegistered = false;

  void loadURI(String uri) async {
    await WordDatabase.getDatabase();
    List<String> uriSplit = uri.split('/');
    if (uriSplit.length > 4) {
      if (uriSplit[0].endsWith('content:') &&
          uriSplit[1].isEmpty && uriSplit[2] ==
          'org.tlhInganHol.android.klingonassistant.KlingonContentProvider') {
        if (uriSplit[3] == 'lookup') {
          load(Uri.decodeComponent(uriSplit[4]));
        }
      }
    }
  }

  @override
  void initState() {
    super.initState();
    if (!loadHandlerRegistered) {
      messageChannel.setMessageHandler((msg) async {
        loadURI(msg);
        return '';
      });
      loadHandlerRegistered = true;
    }
  }

  _launch(String uri) {
    MethodChannel('platform').invokeMethod('openURL', uri);
  }

  Future<bool> _ttsAvailable() async {
    bool ret = await MethodChannel('platform').invokeMethod('ttsAvailable');
    return ret;
  }

  /* Load an entry as the main widget */
  load(String destination, {String withTitle}) {
    List<String> destinationSplit = destination.split(':');
    if (destinationSplit.length < 2) {
      if (destination == 'prefix_chart') {
        Navigator.of(context).push(new MaterialPageRoute(builder: (ctx) => new MyHomePage(destination)));
      } else {
        Navigator.of(context).push(new MaterialPageRoute(builder: (ctx) => new SearchPage(query: destination)));
      }
      return;
    }

    if (destinationSplit[1].contains('url') && destinationSplit.length > 3) {
      _launch(destinationSplit.skip(2).join(':'));
      return;
    }

    if (destinationSplit[1].contains('mailto') && destinationSplit.length > 2) {
      _launch(destinationSplit.skip(1).join(':'));
      return;
    }

    if (!destination.contains('@@')) {
      destination = WordDatabaseEntry.normalizeSearchName(destination);
    }

    Navigator.of(context).push(new MaterialPageRoute(
        builder: (c) => new MyHomePage(destination, secondTitle: withTitle,),
    ));
  }

  /* Build the navigation menu for the drawer. */
  List<Widget> buildmenu() {
    /* List of menu categories, items, and destinations */
    final Map<String, Map<String, String>> menu = {
      'ref': {
        'pronunciation' : 'QIch wab Ho\'DoS:n',
        'prefix' : 'moHaq:n',
        'prefixchart' : 'prefix_chart',
        'nounsuffix' : 'DIp:n',
        'verbsuffix' : 'wot:n',
      },
      'phr' : {
        'beginner' : '*:sen:bc',
        'jokes' : '*:sen:joke',
        'ascension' : '*:sen:nt',
        'Ql' : '*:sen:Ql',
        'toasts' : '*:sen:toast',
        'lyrics' : '*:sen:lyr',
        'curses' : '*:sen:mv',
        'replproverbs' : '*:sen:rp',
        'secrproverbs' : '*:sen:sp',
        'empunday' : '*:sen:eu',
        'reject' : '*:sen:rej',
      },
      'media' : {
        'lessons' : ':url:http://www.youtube.com/playlist?list=PLJrTr05h0I0OcaX5G6_5TCuIisvS4Xed6',
        'conversation' : ':url:http://www.youtube.com/playlist?list=PLJrTr05h0I0MazOxYJq47Eqdsa9F2glPg',
        'battlecomm' : ':url:http://www.youtube.com/playlist?list=PLJrTr05h0I0Mwfo-f1YJv1VC7pNgiqicp',
        'othercomm' : ':url:http://www.youtube.com/playlist?list=PLJrTr05h0I0PuQHLzrhp0n4TXsOZVzYzo',
        'curses' : ':url:http://www.youtube.com/playlist?list=PLJrTr05h0I0NHU5zsb7rd7Vz0Ed_4hLhg',
        'other' : ':url:http://www.youtube.com/playlist?list=PLJrTr05h0I0MsVYmwqMCXp8rwDjSKZzWC',
      },
      'kli' : {
        'lessons' : ':url:http://www.kli.org/learn-klingon-online/',
        'questions' : ':url:http://www.kli.org/questions/categories/',
      },
    };

    List<Widget> ret = [
      new ListTile(
        title: new KlingonText(fromString: L7dStrings.of(context).l6e('prefs')),
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
          title: new KlingonText(fromString:
            L7dStrings.of(context).l6e('menu_${category}_${name}')),
          onTap: () {
            Navigator.pop(context);
            load(
              menu[category][name],
              withTitle: L7dStrings.of(context).l6e('menu_${category}_${name}'),
            );
          },
          trailing: KlingonText.iconFromLink(menu[category][name]),
        ));
      }
      ret.add(new ExpansionTile(
        title: new KlingonText(
          fromString: L7dStrings.of(context).l6e('menu_$category'),
          style: new TextStyle(color: Colors.red),
        ),
        children: options,
        initiallyExpanded: true,
      ));
    }

    return ret;
  }

  void _search() {
    Navigator.of(context).push(new MaterialPageRoute(
        builder: (c) => new SearchPage()));
  }

  Widget getEntry(String entry, BuildContext context, {String withTitle}) {
    Widget ret;

    if (WordDatabase.db == null) {
      ret = const Text('Error: database not initialized!');
    } else if (entry.startsWith('*:')) {
      // Load all entries with the given category
      List<Widget> entries = [
        new ListTile(title: new KlingonText(
          fromString: withTitle,
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
          fromString: 'Components of: {$entry}',
          style: new TextStyle(fontWeight: FontWeight.bold),
        ),
        ),
      ];

      for (String component in entry.split('@@')[1].split(',')) {
        String trimmed = component.trim();

        if (trimmed.endsWith(':0') && trimmed.split(':').length > 2) {
          WordDatabase.homophones(trimmed).forEach((h) =>
            entries.add(h.toListTile(onTap: () => load(h.searchName))));
        } else {
          String c = WordDatabaseEntry.normalizeSearchName(trimmed);
          if (WordDatabase.db.containsKey(c))
            entries.add(WordDatabase.db[c].toListTile(onTap: () => load(c)));
        }
      }

      ret = new Expanded(child: new ListView(children: entries,));
    } else if (entry.endsWith(':0') && entry.split(':').length > 2) {
      // Load all homophones with the given part of speech
      String pos = entry.split(':')[1];

      List<Widget> entries = [
        new ListTile(title: new KlingonText(
          fromString: 'Homophones for: {$entry} ($pos)',
          style: new TextStyle(fontWeight: FontWeight.bold)
        ))
      ];

      WordDatabase.homophones(entry).forEach((m) =>
        entries.add(m.toListTile(onTap: () => load(m.searchName))));

      ret = new Expanded(child: new ListView(children: entries,));
    } else if (WordDatabase.db[entry] == null) {
      ret = new Text('The entry {$entry} was not found in the database.');
    } else {
      ret = WordDatabase.db[entry].toWidget(
        Theme.of(context).textTheme.bodyMedium,
        onTap: load,
      );
    }

    return new Column(children: [ret]);
  }

  Widget buildHelper(BuildContext context, String entry, {String withTitle}) {
    Widget main = new CircularProgressIndicator();

    if (_actions.isEmpty) {
      _actions.add(new IconButton(
        icon: const Icon(Icons.search),
        onPressed: _search,
      ));
    }

    _ttsAvailable().then((available) {
      if (available && entry.contains(':') && !entry.startsWith('*')) {
        if (_actions[0].onPressed == _search) {
          _actions.insert(0, new IconButton(
              icon: const Icon(Icons.chat_bubble),
              onPressed: () {
                print(widget.entry.split(':').first);
                MethodChannel('platform').invokeMethod('speak',
                  widget.entry.split(':').first);
              }
          ));
        }
      } else {
        if (_actions[0].onPressed != _search) {
          _actions.removeAt(0);
        }
      }
      setState(() {});
    });

    // Lazily initialize the database and load destination entry when done.
    if (WordDatabase.db == null) {
      WordDatabase.getDatabase().then((ret) {
        if (entry != 'help') {
          setState(() {
            main = getEntry(entry, context, withTitle: withTitle);
            _dbversion = '${L7dStrings.of(context).l6e('database_version')} ${
              WordDatabase.version}';
          });
        }
      });
    } else {
      if (entry != 'help') {
        main = getEntry(entry, context, withTitle: withTitle);
      }
      _dbversion = '${L7dStrings.of(context).l6e('database_version')} ${
        WordDatabase.version}';
    }

    if (entry == 'help') {
      Widget help = new ListView(children: [new Padding(
        padding: new EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
        child: new Column(children: [
          new KlingonText(fromString:
            '{tlhIngan Hol boQwI\':n:nolink}',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          new Text(
              L7dStrings.of(context).l6e('appname_translation'),
              style: Theme.of(context).textTheme.headlineSmall
          ),
          new KlingonText(
            fromString: _dbversion,
            style: Theme.of(context).textTheme.caption,
          ),
          new KlingonText(fromString: L7dStrings.of(context).l6e('helptext'),
            style: Theme.of(context).textTheme.bodyMedium,
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
          1 : new FixedColumnWidth(34.0),
          2 : new FixedColumnWidth(34.0),
          3 : new FixedColumnWidth(34.0),
          4 : new FixedColumnWidth(34.0),
          5 : new FixedColumnWidth(34.0),
          6 : new FixedColumnWidth(34.0),
          7 : new FixedColumnWidth(34.0)},
        defaultVerticalAlignment: TableCellVerticalAlignment.bottom,
        children:[
          new TableRow(children: [
            new Text(''),
            new Text('none', textAlign: TextAlign.center,),
            new Text('me', textAlign: TextAlign.center,),
            new Text('you', textAlign: TextAlign.center,),
            new Text('him / her / it', textAlign: TextAlign.center,),
            new Text('us', textAlign: TextAlign.center,),
            new Text('you (pl)', textAlign: TextAlign.center,),
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
            new Text('he / she / it', textAlign: TextAlign.right,),
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
          backgroundColor: Colors.red[700],
          actions: _actions,
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
    L7dStrings.of(context).locale = new Locale(Preferences.uiLang);
    return buildHelper(context, widget.entry, withTitle: widget.secondTitle);
  }
}
