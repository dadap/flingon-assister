import 'package:flutter/material.dart';
import 'database.dart';
import 'main.dart';
import 'dart:async';

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

        // Rate limit returning query results
        timer = new Timer(const Duration(milliseconds: 250), () {
          List<Widget> results = [];
          Widget newMain;

          WordDatabase.match(db: _db, query: controller.text).forEach((e) {
            results.add(e.toListTile(onTap: () =>
                Navigator.of(context).push(
                    new MaterialPageRoute(builder: (ctx) =>
                    new MyHomePage(e.searchName))
                )));
          });

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
        ],
      ),
      body: new Center(child: main),
    );
  }
}