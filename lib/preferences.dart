import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'update.dart';
import 'l10n.dart';
import 'klingontext.dart';

enum InputMode {tlhInganHol, xifanholkq, xifanholkQ}
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
  static bool _partOfSpeechColors = true;
  static bool _searchEntryNames = true;
  static bool _searchDefinitions = true;
  static bool _searchSearchTags = true;
  static bool _enableIncompleteLanguages = false;
  static String _updateLocation = _defaultUpdateLocation;
  static String _dbUpdateVersion = '';
  static Map <String, String> langs = new Map();
  static List<String> supportedLangs = new List<String>.empty(growable: true);

  static String inputModeName(InputMode im) {
    switch(im) {
      case InputMode.tlhInganHol:
        return "{tlhIngan Hol}";
      case InputMode.xifanholkq:
        return "xifan hol (k=q; q=Q)";
      case InputMode.xifanholkQ:
        return "xifan hol (k=Q; q=q)";
    }
  }

  static String langName(String shortName) {
    if (shortName == 'tlh') {
      return "{tlhIngan Hol}";
    }

    if (langs.keys.contains(shortName)) {
      return langs[shortName]!;
    }

    return "unknown";
  }

  static String fontName(String font) {
    if (font == 'RobotoSlab') {
      // This is deliberately not "{tlhIngan Hol}", to make sure that it always
      // displays with Latin characters as opposed to pIqaD.
      return 'tlhIngan Hol (Latin Transcription)';
    }
    if (font == 'DSCpIqaD') {
      return '{DISqa\'vI\'rIy pIqaD}';
    }
    if (font == 'TNGpIqaD') {
      return '{qurgh pIqaD}';
    }
    if (font == 'pIqaDqolqoS') {
      return '{pIqaD qolqoS}';
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

  static set partOfSpeechColors(bool val) {
    _partOfSpeechColors = val;
    SharedPreferences.getInstance().then((sp) =>
      sp.setBool('part_of_speech_colors', val));
  }
  static bool get partOfSpeechColors => _partOfSpeechColors;

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

  static set enableIncompleteLanguages(bool val) {
    _enableIncompleteLanguages = val;
    SharedPreferences.getInstance().then((sp) =>
      sp.setBool('enable_incomplete_languages', val));
  }
  static bool get enableIncompleteLanguages => _enableIncompleteLanguages;

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

    int? inputMode = preferences.getInt('input_mode');
    String? searchLang = preferences.getString('search_language');
    String? uiLang = preferences.getString('user_interface_language');
    String? font = preferences.getString('font');
    bool? partOfSpeechColors = preferences.getBool('part_of_speech_colors');
    bool? searchEntryNames = preferences.getBool('search_entry_names');
    bool? searchDefinitions = preferences.getBool('search_definitions');
    bool? searchSearchTags = preferences.getBool('search_search_tags');
    bool? enableIncompleteLanguages =
      preferences.getBool('enable_incomplete_languages');
    String? updateLocation = preferences.getString('update_location');
    String? dbUpdateVersion = preferences.getString('db_update_version');

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

    if (partOfSpeechColors != null) {
      _partOfSpeechColors = partOfSpeechColors;
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

    if (enableIncompleteLanguages != null) {
      _enableIncompleteLanguages = enableIncompleteLanguages;
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
  Widget? _prefsPanel;
  String _inputModeLabel = '';
  String _searchLanguageLabel = '';
  String _uiLanguageLabel = '';
  String _fontLabel = '';
  bool _partOfSpeechColors = Preferences.partOfSpeechColors;
  bool _searchEntryNames = Preferences.searchEntryNames;
  bool _searchDefinitions = Preferences.searchDefinitions;
  bool _searchSearchTags = Preferences.searchSearchTags;
  bool _enableIncompleteLanguages = Preferences.enableIncompleteLanguages;

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
        child: new KlingonText(fromString: Preferences.inputModeName(mode)),
      ));
    }

    for (String lang in Preferences.langs.keys) {
      if (Preferences.enableIncompleteLanguages ||
          Preferences.supportedLangs.contains(lang)) {
        searchLanguageMenu.add(new PopupMenuItem(
          value: lang,
          child: new Text(Preferences.langName(lang)),
        ));
      }
    }

    for (String lang in L10nDelegate.supportedLocales) {
      uiLanguageMenu.add(new PopupMenuItem(
        value: lang,
        child: new KlingonText(fromString: Preferences.langName(lang)),
      ));
    }

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
              fromString: L7dStrings.of(context)!.l6e('prefs_disp')!,
              style: new TextStyle(color: Colors.red),
            ),
            initiallyExpanded: true,
            children: [
              new PopupMenuButton<String>(
                child: new ListTile(
                  title: new KlingonText(fromString: _searchLanguageLabel),
                  leading: new Container(
                    child: new Icon(Icons.search),
                    alignment: Alignment.center,
                    width: 20.0,
                    height: 20.0,
                  ),
                ),
                itemBuilder: (ctx) => searchLanguageMenu,
                onSelected: (val) {
                  setState(() {
                    _searchLanguageLabel =
                      '${L7dStrings.of(context)!.l6e('prefs_disp_dblang')}: ${
                        Preferences.langName(val)}';
                  });
                  Preferences.searchLang = val;
                },
                initialValue: Preferences.searchLang,
              ),
              new ListTile(
                leading: new Container(
                  child: new Checkbox(
                      value: _enableIncompleteLanguages,
                      onChanged: (v) {
                        setState(() => _enableIncompleteLanguages = v!);
                        Preferences.enableIncompleteLanguages = v!;
                      }
                  ),
                  alignment: Alignment.center,
                  width: 20.0,
                  height: 20.0,
                ),
                title: new KlingonText(fromString:
                L7dStrings.of(context)!.l6e('prefs_disp_alldblangs')!),
              ),
              new PopupMenuButton<String>(
                child: new ListTile(
                  title: new KlingonText(fromString: _uiLanguageLabel),
                  leading: new Container(
                    child: new Icon(Icons.language),
                    alignment: Alignment.center,
                    width: 20.0,
                    height: 20.0,
                  ),
                ),
                itemBuilder: (ctx) => uiLanguageMenu,
                onSelected: (val) {
                  Preferences.uiLang = val;
                  L7dStrings.of(context)!.locale = new Locale(val);
                  setState(() {
                    _uiLanguageLabel =
                      '${L7dStrings.of(context)!.l6e('prefs_disp_uilang')}: ${
                        Preferences.langName(val)}';
                  });
                },
              ),
              new PopupMenuButton<String>(
                child: new ListTile(
                  title: new KlingonText(fromString: _fontLabel),
                  leading: new Container(
                    child: new Icon(Icons.font_download),
                    alignment: Alignment.center,
                    width: 20.0,
                    height: 20.0,
                  ),
                ),
                itemBuilder: (ctx) => fontMenu,
                onSelected: (val) {
                  setState(() {
                    _fontLabel =
                      '${L7dStrings.of(context)!.l6e('prefs_disp_tlhdisp')}: ${
                        Preferences.fontName(val)}';
                  });
                  Preferences.font = val;
                },
                initialValue: Preferences.font,
              ),
              new ListTile(
                leading: new Container(
                  child: new Checkbox(
                    value: _partOfSpeechColors,
                    onChanged: (v) {
                      setState(() => _partOfSpeechColors = v!);
                      Preferences.partOfSpeechColors = v!;
                    }
                  ),
                  alignment: Alignment.center,
                  width: 20.0,
                  height: 20.0,
                ),
                title: new KlingonText(fromString:
                L7dStrings.of(context)!.l6e('prefs_disp_poscolors')!),
              ),

            ]
          ),
          new ExpansionTile(
            title: new KlingonText(
              fromString: L7dStrings.of(context)!.l6e('prefs_search')!,
              style: new TextStyle(color: Colors.red),
            ),
            initiallyExpanded: true,
            children: [
              new PopupMenuButton<InputMode>(
                child: new ListTile(
                  title: new KlingonText(fromString: _inputModeLabel),
                  leading: new Container(
                    child: new Icon(Icons.keyboard),
                    alignment: Alignment.center,
                    width: 20.0,
                    height: 20.0,
                  ),
                ),
                itemBuilder: (ctx) => inputModeMenu,
                onSelected: (val) {
                  setState(() {
                    _inputModeLabel =
                    '${L7dStrings.of(context)!.l6e('prefs_search_inputmode')}: ${
                      Preferences.inputModeName(val)}';
                  });
                  Preferences.inputMode = val;
                },
                initialValue: Preferences.inputMode,
              ),
              new ListTile(
                leading: new Container(
                  child: new Checkbox(
                    value: _searchEntryNames,
                    onChanged: (v) {
                      setState(() => _searchEntryNames = v!);
                      Preferences.searchEntryNames = v!;
                    }
                  ),
                  alignment: Alignment.center,
                  width: 20.0,
                  height: 20.0,
                ),
                title: new KlingonText(fromString:
                  L7dStrings.of(context)!.l6e('prefs_search_ent')!),
              ),
              new ListTile(
                leading: new Container(
                  child: new Checkbox(
                    value: _searchDefinitions,
                    onChanged: (v) {
                      setState(() => _searchDefinitions = v!);
                      Preferences.searchDefinitions = v!;
                    }
                  ),
                  alignment: Alignment.center,
                  width: 20.0,
                  height: 20.0,
                ),
                title: new KlingonText(fromString:
                  L7dStrings.of(context)!.l6e('prefs_search_def')!),
              ),
              new ListTile(
                leading: new Container(
                child: new Checkbox(
                  value: _searchSearchTags,
                    onChanged: (v) {
                      setState(() => _searchSearchTags = v!);
                      Preferences.searchSearchTags = v!;
                    }
                  ),
                  alignment: Alignment.center,
                  width: 20.0,
                  height: 20.0,
                ),
                title: new KlingonText(fromString:
                  L7dStrings.of(context)!.l6e('prefs_search_tags')!),
              ),
            ],
          ),
          new ExpansionTile(
            title: new KlingonText(
              fromString: L7dStrings.of(context)!.l6e('prefs_dbupdate')!,
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
                  L7dStrings.of(context)!.l6e('prefs_dbupdate_location')!),
              ),
            ]
          ),
        ],
      );
      setState(() {
        _inputModeLabel =
          '${L7dStrings.of(context)!.l6e('prefs_search_inputmode')}: ${
            Preferences.inputModeName(Preferences.inputMode)}';
        _searchLanguageLabel =
          '${L7dStrings.of(context)!.l6e('prefs_disp_dblang')}: ${
            Preferences.langName(Preferences.searchLang)}';
        _uiLanguageLabel =
          '${L7dStrings.of(context)!.l6e('prefs_disp_uilang')}: ${
            Preferences.langName(Preferences.uiLang)}';
        _fontLabel =
          '${L7dStrings.of(context)!.l6e('prefs_disp_tlhdisp')}: ${
            Preferences.fontName(Preferences.font)}';
      });
    });
    return new Scaffold(
      appBar: new AppBar(
        title: new KlingonText(fromString: L7dStrings.of(context)!.l6e('prefs')!),
        backgroundColor: Colors.red[700],
      ),

      body: new Center(child: _prefsPanel),
    );
  }
}
