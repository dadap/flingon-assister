import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum InputMode {tlhInganHol, xifanholkq, xifanholkQ}

class Preferences {
  static InputMode _inputMode = InputMode.tlhInganHol;
  static String _searchLang = "en";

  static String inputModeName(InputMode im) {
    switch(im) {
      case InputMode.tlhInganHol:
        return "tlhIngan Hol";
      case InputMode.xifanholkq:
        return "xifan hol (k=q; q=Q)";
      case InputMode.xifanholkQ:
        return "xifan hol (k=Q; q=q)";
    }
    return "unknown";
  }

  static String langName(String shortName) {
    if (shortName == 'de') {
      return "Deutsch";
    }
    if (shortName == 'en') {
      return "English";
    }
    return "unknown";
  }

  // Helpers to convert InputMode to and from int, since Dart enums aren't ints
  static InputMode _intToInputMode(int i) {
    switch(i) {
      case 1:
        return InputMode.xifanholkq;
      case 2:
        return InputMode.xifanholkQ;
      case 0:
      default:
        return InputMode.tlhInganHol;
    }
  }
  static int _inputModeToInt(InputMode im) {
    switch (im) {
      case InputMode.xifanholkq:
        return 1;
      case InputMode.xifanholkQ:
        return 2;
      case InputMode.tlhInganHol:
      default:
        return 0;
    }
  }

  static void set inputMode(InputMode val) {
    _inputMode = val;
    SharedPreferences.getInstance().then((sp) =>
      sp.setInt('input_mode', _inputModeToInt(val)));
  }
  static InputMode get inputMode => _inputMode;

  static void set searchLang(String val) {
    _searchLang = val;
    SharedPreferences.getInstance().then((sp) =>
      sp.setString('search_language', val));
  }
  static String get searchLang => _searchLang;

  static loadPreferences() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    _inputMode = _intToInputMode(preferences.getInt('input_mode'));
    _searchLang = preferences.getString('search_language');
  }
}

class PreferencesPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _PreferencesPageState();
}

class _PreferencesPageState extends State<PreferencesPage> {
  Widget _prefsPanel;
  String _inputModeLabel = 'Input mode:';
  String _searchLanguageLabel = 'Search language:';

  @override
  Widget build(BuildContext context) {
    List<PopupMenuEntry<InputMode>> inputModeMenu = [];
    List<PopupMenuEntry<String>> searchLanguageMenu = [];

    for (InputMode mode in InputMode.values) {
      inputModeMenu.add(new PopupMenuItem(
        value: mode,
        child: new Text(Preferences.inputModeName(mode)),
      ));
    }

    for (String lang in ['en', 'de']) {
      searchLanguageMenu.add(new PopupMenuItem(
        value: lang,
        child: new Text(Preferences.langName(lang)),
      ));
    }

    Preferences.loadPreferences().then((p) {
        _prefsPanel = new ListView(
          children: [
            new PopupMenuButton<InputMode>(
              child: new ListTile(
                title: new Text(_inputModeLabel),
                leading: new Icon(Icons.more_vert),
              ),
              itemBuilder: (ctx) => inputModeMenu,
              onSelected: (val) {
                setState(() {
                  _inputModeLabel =
                  'Input mode: ${Preferences.inputModeName(val)}';
                });
                Preferences.inputMode = val;
              },
              initialValue: Preferences.inputMode,
            ),
            new PopupMenuButton<String>(
              child: new ListTile(
                title: new Text(_searchLanguageLabel),
                leading: new Icon(Icons.more_vert),
              ),
              itemBuilder: (ctx) => searchLanguageMenu,
              onSelected: (val) {
                setState(() {
                  _searchLanguageLabel =
                  'Search language: ${Preferences.langName(val)}';
                });
                Preferences.searchLang = val;
              },
              initialValue: Preferences.searchLang,
            ),
          ],
        );
        setState(() {
          _inputModeLabel =
            'Input mode: ${Preferences.inputModeName(Preferences.inputMode)}';
          _searchLanguageLabel =
            'Search language: ${Preferences.langName(Preferences.searchLang)}';
        });
      }
    );
    return new Scaffold(
      appBar: new AppBar(title: new Text('Preferences')),

      body: new Center(child: _prefsPanel),
    );
  }
}