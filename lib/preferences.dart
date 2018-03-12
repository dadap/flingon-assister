import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum InputMode {tlhInganHol, xifanholkq, xifanholkQ}
const List<String> _langs = const ['de', 'en'];
const List<String> _fonts = const [
  'RobotoSlab',
  'DSCpIqaD',
  'TNGpIqaD',
  'pIqaDqolqoS'
];

class Preferences {
  static InputMode _inputMode = InputMode.tlhInganHol;
  static String _searchLang = "en";
  static String _font = "RobotoSlab";
  static bool _searchEntryNames = true;
  static bool _searchDefinitions = true;
  static bool _searchSearchTags = true;

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

  static String fontName(String font) {
    if (font == 'RobotoSlab') {
      return 'tlhIngan Hol (Latin Transcription)';
    }
    if (font == 'DSCpIqaD') {
      return 'pIqaD (DSC)';
    }
    if (font == 'TNGpIqaD') {
      return 'pIqaD (TNG)';
    }
    if (font == 'pIqaDqolqoS') {
      return 'pIqaD qolqoS';
    }
    return 'unknown';
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

  static void set font(String val) {
    _font = val;
    SharedPreferences.getInstance().then((sp) =>
      sp.setString('font', val));
  }
  static String get font => _font;

  static void set searchEntryNames(bool val) {
    _searchEntryNames = val;
    SharedPreferences.getInstance().then((sp) =>
      sp.setBool('search_entry_names', val));
  }
  static bool get searchEntryNames => _searchEntryNames;

  static void set searchDefinitions(bool val) {
    _searchDefinitions = val;
    SharedPreferences.getInstance().then((sp) =>
      sp.setBool('search_definitions', val));
  }
  static bool get searchDefinitions => _searchDefinitions;

  static void set searchSearchTags(bool val) {
    _searchSearchTags = val;
    SharedPreferences.getInstance().then((sp) =>
      sp.setBool('search_search_tags', val));
  }
  static bool get searchSearchTags => _searchSearchTags;

  static loadPreferences() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();

    int inputMode = preferences.getInt('input_mode');
    String searchLang = preferences.getString('search_language');
    String font = preferences.getString('font');

    if (inputMode != null) {
      _inputMode = _intToInputMode(inputMode);
    }

    if (searchLang != null) {
      _searchLang = searchLang;
    }

    if (font != null) {
      _font = font;
    }
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
  String _fontLabel = 'Klingon text display:';
  bool _searchEntryNames = Preferences.searchEntryNames;
  bool _searchDefinitions = Preferences.searchDefinitions;
  bool _searchSearchTags = Preferences.searchSearchTags;

  @override
  Widget build(BuildContext context) {
    List<PopupMenuEntry<InputMode>> inputModeMenu = [];
    List<PopupMenuEntry<String>> searchLanguageMenu = [];
    List <PopupMenuEntry<String>> fontMenu = [];

    for (InputMode mode in InputMode.values) {
      inputModeMenu.add(new PopupMenuItem(
        value: mode,
        child: new Text(Preferences.inputModeName(mode)),
      ));
    }

    for (String lang in _langs) {
      searchLanguageMenu.add(new PopupMenuItem(
        value: lang,
        child: new Text(Preferences.langName(lang)),
      ));
    }

    for (String font in _fonts) {
      fontMenu.add(new PopupMenuItem(
        value: font,
        child: new Text(Preferences.fontName(font)),
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
          new PopupMenuButton<String>(
            child: new ListTile(
              title: new Text(_fontLabel),
              leading: new Icon(Icons.more_vert),
            ),
            itemBuilder: (ctx) => fontMenu,
            onSelected: (val) {
              setState(() {
                _fontLabel =
                  'Klingon text display: ${Preferences.fontName(val)}';
              });
              Preferences.font = val;
            },
            initialValue: Preferences.font,
          ),
          new ListTile(
            leading: new Checkbox(
              value: _searchEntryNames,
              onChanged: (v) {
                setState(() => _searchEntryNames = v);
                Preferences.searchEntryNames = v;
              }
            ),
            title: new Text('Search entry names'),
          ),
          new ListTile(
            leading: new Checkbox(
              value: _searchDefinitions,
              onChanged: (v) {
                setState(() => _searchDefinitions = v);
                Preferences.searchDefinitions = v;
              }
            ),
            title: new Text('Search definitions'),
          ),
          new ListTile(
            leading: new Checkbox(
                value: _searchSearchTags,
                onChanged: (v) {
                  setState(() => _searchSearchTags = v);
                  Preferences.searchSearchTags = v;
                }
            ),
            title: new Text('Search search tags'),
          ),
        ],
      );
      setState(() {
        _inputModeLabel =
          'Input mode: ${Preferences.inputModeName(Preferences.inputMode)}';
        _searchLanguageLabel =
          'Search language: ${Preferences.langName(Preferences.searchLang)}';
        _fontLabel =
          'Klingon text display: ${Preferences.fontName(Preferences.font)}';
      });
    });
    return new Scaffold(
      appBar: new AppBar(title: new Text('Preferences')),

      body: new Center(child: _prefsPanel),
    );
  }
}