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
      leading: new Icon(Icons.update),
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

  String URL;
  String version;
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
    if (URL == null) {
      // URL isn't set yet: fetch the manifest and get the path to the latest db
      String manifestPath = _manifestLocation();
      msg = 'Checking for updates';

      HttpClient http = new HttpClient();
      http.getUrl(Uri.parse(manifestPath)).then((req) => req.close()).then((
          resp) async {
        final String formatVersion = '1';
        String manifest = await resp.transform(UTF8.decoder).join();

        final m = JSON.decode(manifest);
        version = m[formatVersion]['latest'];

        if (version != null) {
          setState(() {
            URL = m[formatVersion][version]['path'];
            size = m[formatVersion][version]['size'];

            // Figure out if the path is absolute or relative and canonicalize
            if (URL != null && size != null) {
              if (!URL.contains('://')) {
                URL = '${manifestPath.substring(
                  0, manifestPath.lastIndexOf('/'))}/$URL';
              }
            }
          });
        }
      }, onError: () {
        msg = 'A failure occurred while checking for database updates.';
      });
    } else if (update == null) {
      // Path to the update has been determined, but update hasn't started
      if (!doInstall) {
        if (WordDatabase.version == version) {
          // Already up to date
          setState(() {
            msg = 'No update available';
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
      } else {
        // Fetch the update and install it
        HttpClient db = new HttpClient();
        update = [];
        msg = 'Downloading database update $version';

        db.getUrl(Uri.parse(URL)).then((r) => r.close()).then((resp) async {
          resp.listen((data) {
            update.insertAll(update.length, data);
            setState(() {
              completion = update.length / size;
              print('$completion');
            });
          }, onDone: () async {
            File db = new File(WordDatabase.dbFile);

            setState(() => msg = 'Download complete: $version');

            await db.writeAsBytes(update);
            WordDatabase.getDatabase(force: true);

            setState(() => done = true);
          }, onError: (err) {
            setState(() => msg = 'Failed to update database');
          });
        });
      }
    } else if (done) {
      setState(() {
        msg = 'Database updated to $version';
      });
    }

    Widget status;

    if (URL != null && !doInstall) {
      status = buttons;
    } else {
      status = new LinearProgressIndicator(value: completion);
    }

    return new ListTile(title: new Text(msg), subtitle: status);
  }
}