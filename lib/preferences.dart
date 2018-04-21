import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'update.dart';
import 'l10n.dart';
import 'klingontext.dart';

enum InputMode {tlhInganHol, xifanholkq, xifanholkQ}
const List<String> _langs = const ['de', 'en'];
const List<String> _fonts = const [
  'RobotoSlab',
  'DSCpIqaD',
  'TNGpIqaD',
  'pIqaDqolqoS'
];
final _defaultUpdateLocation = 'https://De7vID.github.io/qawHaq/';

class Preferences {
  static InputMode _inputMode = InputMode.tlhInganHol;
  static String _searchLang = "en";
  static String _uiLang = "en";
  static String _font = "RobotoSlab";
  static bool _searchEntryNames = true;
  static bool _searchDefinitions = true;
  static bool _searchSearchTags = true;
  static String _updateLocation = _defaultUpdateLocation;
  static String _dbUpdateVersion;

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
    if (shortName == 'tlh') {
      return "{tlhIngan Hol}";
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

  static set inputMode(InputMode val) {
    _inputMode = val;
    SharedPreferences.getInstance().then((sp) =>
      sp.setInt('input_mode', _inputModeToInt(val)));
  }
  static InputMode get inputMode => _inputMode;

  static set searchLang(String val) {
    _searchLang = val;
    SharedPreferences.getInstance().then((sp) =>
      sp.setString('search_language', val));
  }
  static String get searchLang => _searchLang;

  static set uiLang(String val) {
    _uiLang = val;
    SharedPreferences.getInstance().then((sp) =>
      sp.setString('user_interface_language', val));
  }
  static String get uiLang => _uiLang;

  static set font(String val) {
    _font = val;
    SharedPreferences.getInstance().then((sp) =>
      sp.setString('font', val));
  }
  static String get font => _font;

  static set searchEntryNames(bool val) {
    _searchEntryNames = val;
    SharedPreferences.getInstance().then((sp) =>
      sp.setBool('search_entry_names', val));
  }
  static bool get searchEntryNames => _searchEntryNames;

  static set searchDefinitions(bool val) {
    _searchDefinitions = val;
    SharedPreferences.getInstance().then((sp) =>
      sp.setBool('search_definitions', val));
  }
  static bool get searchDefinitions => _searchDefinitions;

  static set searchSearchTags(bool val) {
    _searchSearchTags = val;
    SharedPreferences.getInstance().then((sp) =>
      sp.setBool('search_search_tags', val));
  }
  static bool get searchSearchTags => _searchSearchTags;

  static set updateLocation(String val) {
    if (val.isEmpty) {
      val = _defaultUpdateLocation;
    }

    _updateLocation = val;
    SharedPreferences.getInstance().then((sp) =>
      sp.setString('update_location', val));
  }
  static String get updateLocation => _updateLocation;

  static set dbUpdateVersion(String val) {
    _dbUpdateVersion = val;
    SharedPreferences.getInstance().then((sp) =>
      sp.setString('db_update_version', val));
  }
  static String get dbUpdateVersion => _dbUpdateVersion;

  static loadPreferences() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();

    int inputMode = preferences.getInt('input_mode');
    String searchLang = preferences.getString('search_language');
    String uiLang = preferences.getString('user_interface_language');
    String font = preferences.getString('font');
    bool searchEntryNames = preferences.getBool('search_entry_names');
    bool searchDefinitions = preferences.getBool('search_definitions');
    bool searchSearchTags = preferences.getBool('search_search_tags');
    String updateLocation = preferences.getString('update_location');
    String dbUpdateVersion = preferences.getString('db_update_version');

    if (inputMode != null) {
      _inputMode = _intToInputMode(inputMode);
    }

    if (searchLang != null) {
      _searchLang = searchLang;
    }

    if (uiLang != null) {
      _uiLang = uiLang;
    }

    if (font != null) {
      _font = font;
    }

    if (searchEntryNames != null) {
      _searchEntryNames = searchEntryNames;
    }

    if (searchDefinitions != null) {
      _searchDefinitions = searchDefinitions;
    }

    if (searchSearchTags != null) {
      _searchSearchTags = searchSearchTags;
    }

    if (updateLocation != null) {
      _updateLocation = updateLocation;
    }

    if (dbUpdateVersion != null) {
      _dbUpdateVersion = dbUpdateVersion;
    }
  }
}

class PreferencesPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _PreferencesPageState();
}

class _PreferencesPageState extends State<PreferencesPage> {
  Widget _prefsPanel;
  String _inputModeLabel = '';
  String _searchLanguageLabel = '';
  String _uiLanguageLabel = '';
  String _fontLabel = '';
  bool _searchEntryNames = Preferences.searchEntryNames;
  bool _searchDefinitions = Preferences.searchDefinitions;
  bool _searchSearchTags = Preferences.searchSearchTags;

  TextEditingController _updateLocationController = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    List<PopupMenuEntry<InputMode>> inputModeMenu = [];
    List<PopupMenuEntry<String>> searchLanguageMenu = [];
    List<PopupMenuEntry<String>> uiLanguageMenu = [];
    List <PopupMenuEntry<String>> fontMenu = [];

    if (_updateLocationController.text.isEmpty) {
      _updateLocationController.text = Preferences.updateLocation;
    }

    _updateLocationController.addListener(() {
      Preferences.updateLocation = _updateLocationController.text;
    });


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
      uiLanguageMenu.add(new PopupMenuItem(
        value: lang,
        child: new Text(Preferences.langName(lang)),
      ));
    }
    uiLanguageMenu.add(new PopupMenuItem(
      value: 'tlh',
      child: new KlingonText(fromString: Preferences.langName('tlh')),
    ));

    for (String font in _fonts) {
      fontMenu.add(new PopupMenuItem(
        value: font,
        child: new KlingonText(fromString: Preferences.fontName(font)),
      ));
    }

    Preferences.loadPreferences().then((p) {
      _prefsPanel = new ListView(
        children: [
          new ExpansionTile(
            title: new KlingonText(
              fromString: L7dStrings.of(context).l6e('prefs_disp'),
              style: new TextStyle(color: Colors.red),
            ),
            initiallyExpanded: true,
            children: [
              new PopupMenuButton<String>(
                child: new ListTile(
                  title: new KlingonText(fromString: _searchLanguageLabel),
                  leading: new Center(child: new Icon(Icons.more_vert)),
                ),
                itemBuilder: (ctx) => searchLanguageMenu,
                onSelected: (val) {
                  setState(() {
                    _searchLanguageLabel =
                      '${L7dStrings.of(context).l6e('prefs_disp_dblang')}: ${
                        Preferences.langName(val)}';
                  });
                  Preferences.searchLang = val;
                },
                initialValue: Preferences.searchLang,
              ),
              new PopupMenuButton<String>(
                child: new ListTile(
                  title: new KlingonText(fromString: _uiLanguageLabel),
                  leading: new Center(child: new Icon(Icons.more_vert)),
                ),
                itemBuilder: (ctx) => uiLanguageMenu,
                onSelected: (val) {
                  Preferences.uiLang = val;
                  L7dStrings.of(context).locale = new Locale(val);
                  setState(() {
                    _uiLanguageLabel =
                      '${L7dStrings.of(context).l6e('prefs_disp_uilang')}: ${
                        Preferences.langName(val)}';
                  });
                },
              ),
              new PopupMenuButton<String>(
                child: new ListTile(
                  title: new KlingonText(fromString: _fontLabel),
                  leading: new Center(child: new Icon(Icons.more_vert)),
                ),
                itemBuilder: (ctx) => fontMenu,
                onSelected: (val) {
                  setState(() {
                    _fontLabel =
                      '${L7dStrings.of(context).l6e('prefs_disp_tlhdisp')}: ${
                        Preferences.fontName(val)}';
                  });
                  Preferences.font = val;
                },
                initialValue: Preferences.font,
              ),
            ]
          ),
          new ExpansionTile(
            title: new KlingonText(
              fromString: L7dStrings.of(context).l6e('prefs_search'),
              style: new TextStyle(color: Colors.red),
            ),
            initiallyExpanded: true,
            children: [
              new PopupMenuButton<InputMode>(
                child: new ListTile(
                  title: new KlingonText(fromString: _inputModeLabel),
                  leading: new Center(child: new Icon(Icons.more_vert)),
                ),
                itemBuilder: (ctx) => inputModeMenu,
                onSelected: (val) {
                  setState(() {
                    _inputModeLabel =
                    '${L7dStrings.of(context).l6e('prefs_search_inputmode')}: ${
                      Preferences.inputModeName(val)}';
                  });
                  Preferences.inputMode = val;
                },
                initialValue: Preferences.inputMode,
              ),
              new ListTile(
                leading: new Center(child: new Checkbox(
                  value: _searchEntryNames,
                  onChanged: (v) {
                    setState(() => _searchEntryNames = v);
                    Preferences.searchEntryNames = v;
                  }
                )),
                title: new KlingonText(fromString:
                  L7dStrings.of(context).l6e('prefs_search_ent')),
              ),
              new ListTile(
                  leading: new Center(child: new Checkbox(
                  value: _searchDefinitions,
                  onChanged: (v) {
                    setState(() => _searchDefinitions = v);
                    Preferences.searchDefinitions = v;
                  }
                )),
                title: new KlingonText(fromString:
                  L7dStrings.of(context).l6e('prefs_search_def')),
              ),
              new ListTile(
                leading: new Center(child: new Checkbox(
                value: _searchSearchTags,
                  onChanged: (v) {
                    setState(() => _searchSearchTags = v);
                    Preferences.searchSearchTags = v;
                  }
                )),
                title: new KlingonText(fromString:
                  L7dStrings.of(context).l6e('prefs_search_tags')),
              ),
            ],
          ),
          new ExpansionTile(
            title: new KlingonText(
              fromString: L7dStrings.of(context).l6e('prefs_dbupdate'),
              style: new TextStyle(color: Colors.red),
            ),
            initiallyExpanded: true,
            children: [
              new UpdateButton(),
              new ListTile(
                title: new TextField(
                  controller: _updateLocationController,
                  keyboardType: TextInputType.url,
                ),
                subtitle: new KlingonText(fromString:
                  L7dStrings.of(context).l6e('prefs_dbupdate_location')),
              ),
            ]
          ),
        ],
      );
      setState(() {
        _inputModeLabel =
          '${L7dStrings.of(context).l6e('prefs_search_inputmode')}: ${
            Preferences.inputModeName(Preferences.inputMode)}';
        _searchLanguageLabel =
          '${L7dStrings.of(context).l6e('prefs_disp_dblang')}: ${
            Preferences.langName(Preferences.searchLang)}';
        _uiLanguageLabel =
          '${L7dStrings.of(context).l6e('prefs_disp_uilang')}: ${
            Preferences.langName(Preferences.uiLang)}';
        _fontLabel =
          '${L7dStrings.of(context).l6e('prefs_disp_tlhdisp')}: ${
            Preferences.fontName(Preferences.font)}';
      });
    });
    return new Scaffold(
      appBar: new AppBar(
        title: new KlingonText(fromString: L7dStrings.of(context).l6e('prefs'))
      ),

      body: new Center(child: _prefsPanel),
    );
  }
}