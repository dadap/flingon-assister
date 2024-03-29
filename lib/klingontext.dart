import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'preferences.dart';

class KlingonText extends RichText {
  final TextStyle? style;

  // Constructs a new KlingonText widget
  //
  // fromString: The source string, possibly containing {tlhIngan Hol mu'mey}
  // onTap: A callback to be run when links are tapped
  // style: The default style to apply to non-braced text

  KlingonText({String fromString = '', Function(String)? onTap, this.style}) : super(
    text: _processKlingonText(fromString, onTap, style),
  );

  static MaterialColor? colorForPOS(String pos) {
    List<String> posSplit = pos.split(':');

    if (posSplit.length < 1) {
      return null;
    }

    if (posSplit.length > 1)
      return _colorForPOS(posSplit[0], posSplit[1]);

    return null;
  }

  static MaterialColor? _colorForPOS(String? type, String flags) {
    // Use the default color if color is disabled
    if (!Preferences.partOfSpeechColors) {
      return null;
    }

    // Use the default color if the text has no type
    if (type == null) {
      return null;
    }

    // Use the default color for sentences, URLs, sources, and mailto links
    if (type == 'sen' || type == 'url' || type == 'tlhurl' ||type == 'src' ||
        type == 'mailto') {
      return null;
    }

    List<String> splitFlags = flags.split(',');
    if (splitFlags.contains('suff') || splitFlags.contains('pref')) {
      return Colors.red;
    }

    if (type == 'v') {
      return Colors.yellow;
    }

    if (type == 'n') {
      return Colors.green;
    }

    return Colors.blue;
  }

  static String _topIqaD(String text) {
    // Conversion table for Latinized Klingon text to pIqaD. Process {gh}, {ng},
    // and {tlh} first, to prevent {ngh} from being processed as {ng}*{h},
    // {ng} from being processed as {n}*{g}, and {tlh} from being processed as
    // {t}{l}*{h}.
    const Map<String, String> pIqaD = const {
      'gh' :  '', 'ng' : '',  'tlh' : '', 'a' : '', 'b' : '', 'ch' : '',
      'D' : '', 'e' : '',  'H' : '', 'I' : '', 'j' : '', 'l' : '',
      'm' : '', 'n' : '', 'o' : '', 'p' : '', 'q' : '', 'Q' : '',
      'r' : '', 'S' : '', 't' : '', 'u' : '', 'v' : '', 'w' : '',
      'y' : '', '\'' : '', ',' : '', '.' : '',
    };

    pIqaD.forEach((find, replace) {
      text = text.replaceAll(find, replace);
    });

    return text;
  }

  // Build a TextSpan containing 'src', with text {in curly braces} formatted
  // appropriately.
  static TextSpan _processKlingonText(String src, Function(String)? onTap,
      TextStyle? style) {
    List<TextSpan> ret = [];
    String remainder = src;

    while (remainder.contains('{')) {
      // TODO handle URLs and other special text spans
      if (remainder.startsWith('{') && remainder.contains('}')) {
        int endIndex = remainder.indexOf('}');
        String klingon = remainder.substring(1, endIndex);
        List<String> klingonSplit = klingon.split(':');
        String textOnly = klingonSplit[0].split('@@')[0];
        String textType = klingonSplit.length > 1 ? klingonSplit[1] : '';
        String textFlags = klingonSplit.length > 2 ? klingonSplit[2] : '';

        // Klingon words (i.e., anything that's not a URL or source citation)
        // should be in a serif font, to distinguish 'I' and 'l'.
        bool isKlingon = textType != 'url' &&
          textType != 'src';

        // Anything that's not a source citation or explicitly not a link should
        // be treated as a link. Don't process links without an onTap callback.
        bool link = onTap != null && textType != 'src' &&
            !textFlags.split(',').contains('nolink');

        // Source citations are italicized
        bool italic = textType == 'src';

        TapGestureRecognizer? recognizer;

        remainder = remainder.substring(endIndex + 1);

        if (link) {
          recognizer = new TapGestureRecognizer();
          recognizer.onTap = () {onTap(klingon);};
        }

        // Convert to pIqaD if the user selected a pIqaD font
        if (isKlingon && Preferences.font.contains('pIqaD')) {
          textOnly = _topIqaD(textOnly);
        }

        ret.add(new TextSpan(
          text: textOnly,
          style: new TextStyle(
            fontFamily: isKlingon ? Preferences.font :
                                style == null ? null : style.fontFamily,
            decoration: link ? TextDecoration.underline : null,
            fontStyle: italic ? FontStyle.italic : null,
            color: _colorForPOS(textType, textFlags),
            // TODO part of speech tagging
          ),
          recognizer: recognizer,
        ));

        if (iconFromLink(klingon) != null) {
          ret.add(iconToText(iconFromLink(klingon)!));
        }
      } else {
        int endIndex = remainder.indexOf('{');

        ret.add(new TextSpan(text: remainder.substring(0, endIndex)));
        remainder = remainder.substring(endIndex);
      }
    }

    ret.add(new TextSpan(text: remainder));

    return new TextSpan(children: ret, style: style);
  }

  // Convert a Material icon into a TextSpan
  static TextSpan iconToText(Icon icon) {
    return new TextSpan(
      text: new String.fromCharCode(icon.icon!.codePoint),
      style: new TextStyle(fontFamily: icon.icon!.fontFamily),
    );
  }

  // Choose an appropriate icon for an external link
  static Icon? iconFromLink(String link) {
    List<String> linkSplit = link.split(':');

    if (linkSplit.length > 3) {
      if (linkSplit[1] == 'url' || linkSplit[1] == 'tlhurl') {
        if (linkSplit[2].startsWith('http')) {
          List<String> urlSplit = linkSplit[3].split('/');
          if (urlSplit.length > 2) {
            if(urlSplit[2] == 'www.youtube.com') {
              // YouTube playlist
              return new Icon(Icons.video_library);
            } else if (urlSplit[2] == 'youtu.be') {
              // Individual YouTube video
              return new Icon(Icons.play_circle_outline);
            }
          }
        } else if (linkSplit[2] == 'mailto') {
          // mailto: link
          return new Icon(Icons.mail);
        }
        // Generic URL
        return new Icon(Icons.open_in_browser);
      }
    }

    // No icon
    return null;
  }
}
