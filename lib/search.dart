import 'package:flutter/material.dart';
import 'database.dart';
import 'main.dart';
import 'dart:async';
import 'preferences.dart';

class SearchPage extends StatefulWidget {
  final String query;

  SearchPage({this.query : ''});

  @override _SearchPageState createState() => new _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  Widget main;

  TextEditingController controller = new TextEditingController();
  String debouncedQuery;
  Function onPressed;

  Map<String, WordDatabaseEntry> _db = WordDatabase.db;

  @override
  Widget build(BuildContext context) {
    if (_db == null) {
      setState(() {
        main = new CircularProgressIndicator();
      });

      WordDatabase.getDatabase().then((db) {
        _db = db;
        setState(() {
          main = null;
        });
      });
    }

    if (widget.query.isEmpty) {
      Function clearText = () =>
          setState(() {
            controller.clear();
          });

      Timer timer;

      controller.addListener(() {
        // Debounce in case the view is re-built for any reason other than an
        // actual change to the TextField text
        if (debouncedQuery == controller.text) {
          return;
        } else {
          debouncedQuery = controller.text;
        }

        if (debouncedQuery.isEmpty) {
          // Deactivate the clear query button and clear the results
          setState(() {
            onPressed = null;
            main = null;
          });
        } else if (_db != null) {
          if (timer != null && timer.isActive) {
            timer.cancel();
          }

          // Rate limit returning query results.
          timer = new Timer(new Duration(milliseconds: 250), () {
            List<Widget> results = [];
            Widget newMain;

            if (!mounted) {
              return;
            }

            WordDatabase.match(db: _db, query: debouncedQuery).forEach((e) {
              results.add(e.toListTile(onTap: () =>
                  Navigator.of(context).push(
                      new MaterialPageRoute(builder: (ctx) =>
                      new MyHomePage(e.searchName))
                  )));
            });

            if (!mounted) {
              return;
            }

            newMain = new Column(
              children: [new Expanded(child: new ListView(children: results))
              ],);

            setState(() {
              onPressed = clearText;
              main = newMain;
            });
          });
        }
      });
    } else {
      // widget.query is not empty; i.e., this is a pre-populated search
      List<Widget> results = [];
      WordDatabase.match(db: _db, query: widget.query).forEach((e) {
        results.add(e.toListTile(onTap: () =>
          Navigator.of(context).push(
            new MaterialPageRoute(builder: (ctx) =>
            new MyHomePage(e.searchName))
          )));
      });

      setState(() => main = new Column(children: [
        new Expanded(child: new ListView(children: results))
      ],));
    }

    return new Scaffold(
      appBar: new AppBar(
        title: widget.query.isEmpty ? new TextField(
          autofocus: true,
          autocorrect: false,
          style: Theme.of(context).textTheme.title,
          controller: controller,
        ) : new SingleChildScrollView(
          child: new Text(widget.query),
          scrollDirection: Axis.horizontal,
        ),
        actions: widget.query.isEmpty ? [
          new IconButton(
            icon: new Icon(Icons.clear),
            onPressed: onPressed,
          ),
          new IconButton(
            icon: new Icon(Icons.settings),
            onPressed: () => Navigator.of(context).push(new MaterialPageRoute(
                builder: (ctx) => new PreferencesPage())
            ),
          ),
        ] : [],
      ),
      body: new Center(child: main),
    );
  }
}