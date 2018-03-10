import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum InputMode {tlhInganHol, xifanholkq, xifanholkQ}

class Preferences {
  static SharedPreferences _preferences;

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

  static InputMode _inputMode = InputMode.tlhInganHol;

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

  static loadPreferences() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    _inputMode = _intToInputMode(preferences.getInt('input_mode'));
  }
}

class PreferencesPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _PreferencesPageState();
}

class _PreferencesPageState extends State<PreferencesPage> {
  Widget _prefsPanel;
  String _inputModeLabel = 'Input mode:';

  @override
  Widget build(BuildContext context) {
    List<PopupMenuEntry<InputMode>> inputModeMenu = [];

    for (InputMode mode in InputMode.values) {
      inputModeMenu.add(new PopupMenuItem(
        value: mode,
        child: new Text(Preferences.inputModeName(mode)),
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
          ],
        );
        setState(() {
          _inputModeLabel =
          'Input mode: ${Preferences.inputModeName(Preferences.inputMode)}';
        });
      }
    );
    return new Scaffold(
      appBar: new AppBar(title: new Text('Preferences')),

      body: new Center(child: _prefsPanel),
    );
  }
}