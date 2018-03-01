import 'package:flutter/material.dart';

class KlingonText extends RichText {
  final TextStyle style;

  // Constructs a new KlingonText widget
  //
  // fromString: The source string, possibly containing {tlhIngan Hol mu'mey}
  // onTap: A callback to be run when links are tapped
  // style: The default style to apply to non-braced text

  KlingonText({String fromString, Function onTap, this.style}) : super(
    text: _ProcessKlingonText(fromString, onTap, style),
  );

  // Build a TextSpan containing 'src', with tet {in curly braces} formatted
  // appropriately.
  static TextSpan _ProcessKlingonText(String src, Function onTap(String),
      TextStyle style) {
    List<TextSpan> ret = [];
    String remainder = src;

    while (remainder.contains('{')) {
      // TODO handle URLs and other special text spans
      if (remainder.startsWith('{') && remainder.contains('}')) {
        int endIndex = remainder.indexOf('}');
        String klingon = remainder.substring(1, endIndex);
        String klingonTextOnly = klingon.split(':').first;
        remainder = remainder.substring(endIndex + 1);

        ret.add(new TextSpan(
          text: klingonTextOnly,
          style: new TextStyle(
            fontFamily: 'RobotoSlab', // distinguish 'I' and 'l'
            // TODO color coding, part of speech tagging
          ),
          // TODO handle tap
        ));
      } else {
        int endIndex = remainder.indexOf('{');

        ret.add(new TextSpan(text: remainder.substring(0, endIndex)));
        remainder = remainder.substring(endIndex);
      }
    }

    ret.add(new TextSpan(text: remainder));

    return new TextSpan(children: ret, style: style);
  }
}
