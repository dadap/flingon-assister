import 'package:flutter/material.dart';
import 'database.dart';
import 'preferences.dart';
import 'dart:io';
import 'dart:convert';

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
      title: new Text('Check for updates now'),
      leading: new Center(child: new Icon(Icons.update)),
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
  Widget buttons;
  double completion;

  String url;
  String version;
  String movedTo;
  int size;
  List<int> update;
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
    void error([String text = 'The manifest file appears to be invalid.']) {
      setState(() {
        msg = text;
        url = '';
      });
    }

    if (url == null) {
      // URL isn't set yet: fetch the manifest and get the path to the latest db
      String manifestPath = _manifestLocation();
      msg = 'Checking for updates';

      HttpClient http = new HttpClient();
      http.getUrl(Uri.parse(manifestPath)).then((req) => req.close()).then((
          resp) async {
        final String formatVersion = 'iOS-1';
        String manifest = await resp.transform(utf8.decoder).join();

        Map m;

        try {
          m = jsonDecode(manifest);
          if (m != null) {
            if (m[formatVersion] != null) {
              version = m[formatVersion]['latest'];
            }
            movedTo = m['moved_to'];
          }
        } catch (e) {
          error();
        }

        if (m == null) {
          error();
        } else if (movedTo != null) {
          setState(() => url = '');
        } else if (version != null) {
          setState(() {
            url = m[formatVersion][version]['path'];
            size = m[formatVersion][version]['size'];

            // Figure out if the path is absolute or relative and canonicalize
            if (url != null && size != null) {
              if (!url.contains('://')) {
                url = '${manifestPath.substring(
                  0, manifestPath.lastIndexOf('/'))}/$url';
              }
            }
          });
        } else {
          error();
        }
      }, onError: ((e) =>
        error('An error occurred while fetching the update manifest.'))
      );
    } else if (update == null) {
      // Path to the update has been determined, but update hasn't started
      if (!doInstall) {
        if (movedTo != null) {
          // Advertise the new update location
          setState(() {
            msg = 'The update location has moved to $movedTo';
            buttons = new ButtonBar(
              children: [
                new FlatButton(
                  onPressed: () {
                    Preferences.updateLocation = movedTo;
                    setState(() => url = null);
                  },
                  child: new Text('Use new location'),
                ),
                new FlatButton(
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
        } else if (WordDatabase.version == version) {
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
              new FlatButton(
                child: new Text('Install Update'),
                onPressed: () => setState(() => doInstall = true),
              ),
              new FlatButton(
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

    Widget status;

    if (url != null && !doInstall) {
      status = buttons;
    } else {
      status = new LinearProgressIndicator(value: completion);
    }

    return new ListTile(title: new Text(msg), subtitle: status);
  }
}