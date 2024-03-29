import 'package:flutter/material.dart';
import 'database.dart';
import 'preferences.dart';
import 'dart:io';
import 'dart:convert';
import 'l10n.dart';
import 'klingontext.dart';

// TODO: add support for automatic checking for updates and "moved" in manifest

// A ListTile that pops out the update sheet when clicked. This class mainly
// exists in order to get a context that can be walked back to the Scaffold
class UpdateButton extends StatefulWidget {
  @override
  _UpdateButtonState createState() => new _UpdateButtonState();
}

class _UpdateButtonState extends State<UpdateButton> {
  @override
  Widget build(BuildContext context) {
    return new ListTile(
      title: new KlingonText(fromString:
        L7dStrings.of(context)!.l6e('dbupdate_check')!),
      leading: new Container(
        child: new Icon(Icons.update),
        alignment: Alignment.center,
        width: 20.0,
        height: 20.0,
      ),
      onTap: () => UpdateSheet.doUpdate(context),
    );
  }
}

class UpdateSheet extends StatefulWidget {
  // Check for updates and show a bottom sheet to report status
  static void doUpdate(BuildContext context) {
    showBottomSheet(context: context, builder: (ctx) => new UpdateSheet());
  }

  @override
  _UpdateSheetState createState() => new _UpdateSheetState();
}

class _UpdateSheetState extends State<UpdateSheet> {
  String msg = '';
  Widget? buttons;
  double completion = 0.0;

  String url = '';
  String version = '';
  String movedTo = '';
  int size = 0;
  List<int> update = [];
  bool done = false;
  bool doInstall = false;

  // Resolve the manifest location to its actual file path
  static String _manifestLocation() {
    if (Preferences.updateLocation.endsWith('/')) {
      return '${Preferences.updateLocation}manifest.json';
    }
    return Preferences.updateLocation;
  }

  @override
  Widget build (BuildContext context) {
    // Set an error message and set the URL to empty to signal that the message
    // should be displayed.
    void error(String text) {
      setState(() {
        msg = text;
        url = '';
      });
    }

    if (url.isEmpty) {
      // URL isn't set yet: fetch the manifest and get the path to the latest db
      String manifestPath = _manifestLocation();
      msg = L7dStrings.of(context)!.l6e('dbupdate_checking')!;

      HttpClient http = new HttpClient();
      http.getUrl(Uri.parse(manifestPath)).then((req) => req.close()).then((
          resp) async {
        final String formatVersion = 'iOS-1';
        String manifest = await resp.transform(utf8.decoder).join();

        Map m = {};

        try {
          m = jsonDecode(manifest);
          if (m.isNotEmpty) {
            if (m[formatVersion] != null) {
              version = m[formatVersion]['latest'];
              print(version);
            }
            movedTo = m['moved_to'] == null ? '' : m['moved_to'];
          }
        } catch (e) {
          error(L7dStrings.of(context)!.l6e('dbupdate_badmanifest')!);
        }

        if (m.isEmpty) {
          error(L7dStrings.of(context)!.l6e('dbupdate_badmanifest')!);
        } else if (movedTo.isNotEmpty) {
          setState(() => url = '');
        } else if (version.isNotEmpty) {
          setState(() {
            url = m[formatVersion][version]['path'];
            size = m[formatVersion][version]['size'];

            // Figure out if the path is absolute or relative and canonicalize
            if (url.isNotEmpty && size > 0) {
              if (!url.contains('://')) {
                url = '${manifestPath.substring(
                  0, manifestPath.lastIndexOf('/'))}/$url';
              }
            }
          });
        } else {
          error(L7dStrings.of(context)!.l6e('dbupdate_badmanifest')!);
        }
      }, onError: ((e) =>
        error(L7dStrings.of(context)!.l6e('dbupdate_manifetcherr')!))
      );
    } else if (update.isEmpty) {
      // Path to the update has been determined, but update hasn't started
      if (!doInstall) {
        if (movedTo.isNotEmpty) {
          // Advertise the new update location
          setState(() {
            msg = 'The update location has moved to $movedTo';
            buttons = new ButtonBar(
              children: [
                new TextButton(
                  onPressed: () {
                    Preferences.updateLocation = movedTo;
                    setState(() => url = '');
                  },
                  child: new Text('Use new location'),
                ),
                new TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: new Text('Cancel'),
                )
              ],
              alignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
            );
          });
        } else if (url.isEmpty) {
          // This is kind of hacky, but an empty URL signifies that a message
          // should be displayed with a close button.
          buttons = new CloseButton();
        } else if (WordDatabase.verCmp(WordDatabase.version, version) >= 0) {
          // Already up to date
          setState(() {
            msg = 'The database is already the latest version ($version)';
            buttons = new CloseButton();
            done = true;
          });
        } else {
          // Advertise the new database version
          msg = 'A new database version ($version) is available.';
          buttons = new ButtonBar(
            children: [
              new TextButton(
                child: new Text('Install Update'),
                onPressed: () => setState(() => doInstall = true),
              ),
              new TextButton(
                child: new Text('Cancel'),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
            alignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
          );
        }
      } else /* doInstall is true */ {
        // Fetch the update and install it
        HttpClient db = new HttpClient();
        update = [];
        msg = 'Downloading database update $version';

        db.getUrl(Uri.parse(url)).then((r) => r.close()).then((resp) async {
          resp.listen((data) {
            update.insertAll(update.length, data);
            setState(() {
              completion = update.length / size;
            });
          }, onDone: () async {
            File db = new File(WordDatabase.dbFile);

            setState(() => msg = 'Download complete: $version');

            await db.writeAsBytes(update);
            WordDatabase.getDatabase(force: true);
            Preferences.dbUpdateVersion = version;

            setState(() => done = true);
          }, onError: (err) => error('Failed to update database.')
          );
        });
      }
    } else if (done) {
      setState(() {
        msg = 'Database updated to $version';
      });
    }

    Widget? status;

    if (url.isNotEmpty && !doInstall) {
      status = buttons;
    } else {
      status = new LinearProgressIndicator(value: completion);
    }

    return new ListTile(title: new Text(msg), subtitle: status);
  }
}
