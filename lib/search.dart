import 'package:flutter/material.dart';
import 'database.dart';
import 'main.dart';
import 'dart:async';
import 'preferences.dart';

class SearchPage extends StatefulWidget {
  @override _SearchPageState createState() => new _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  Widget main;

  TextEditingController controller = new TextEditingController();
  Function onPressed;

  Map<String, WordDatabaseEntry> _db;

  @override
  Widget build(BuildContext context) {
    Function clearText = () => setState(() {
      controller.clear();
    });

    Timer timer;

    controller.addListener(() {
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

      if (controller.text.isEmpty) {
        setState(() {
          onPressed = null;
          main = null;
        });
      } else if (_db != null) {
        if (timer != null && timer.isActive) {
          timer.cancel();
        }

        // Rate limit returning query results. Wait a little longer if the
        // query is very short.
        final int duration = controller.text.length > 3 ? 250 :
          1500 ~/ controller.text.length;

        timer = new Timer(new Duration(milliseconds: duration), () {
          List<Widget> results = [];
          Widget newMain;

          if (!mounted) {
            return;
          }

          WordDatabase.match(db: _db, query: controller.text).forEach((e) {
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
          new IconButton(
            icon: new Icon(Icons.settings),
            onPressed: () => Navigator.of(context).push(new MaterialPageRoute(builder: (ctx) => new PreferencesPage())),
          ),
        ],
      ),
      body: new Center(child: main),
    );
  }
}