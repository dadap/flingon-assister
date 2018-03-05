import 'package:xml/xml.dart' as xml;
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'klingontext.dart';
import 'dart:math';

class WordDatabase {
  static Future<Map<String, WordDatabaseEntry>> getDatabase() async {
    Map<String, WordDatabaseEntry> ret = new Map();

    final List<String> memSegments = [
      '00-header', '01-b', '02-ch', '03-D', '04-gh', '05-H', '06-j', '07-l',
      '08-m', '09-n', '10-ng', '11-p', '12-q', '13-Q', '14-r', '15-S', '16-t',
      '17-tlh', '18-v', '19-w', '20-y', '21-a', '22-e', '23-I', '24-o',
      '25-u', '26-suffixes', '27-extra', '28-footer'
    ];
    final memBase = 'data/mem-';
    final memSuffix = '.xml';
    String concat = '';

    for (String memSegment in memSegments) {
      concat += await rootBundle.loadString(memBase + memSegment + memSuffix);
    }

    final doc = xml.parse(concat);

    for (var entry in doc
        .findAllElements('database')
        .first
        .findElements('table')) {
      var elem = new WordDatabaseEntry.fromXmlNode(entry);
      ret[elem.searchName] = elem;
    }

    return ret;
  }

  // Measures similarity between haystack and needle. If haystack contains
  // needle, returns the number of extra characters in haystack that aren't
  // also in needle. Otherwise, returns a large number for sorting purposes.
  static int _extraChars(String needle, String haystack) {
    if (haystack.contains(needle)) {
      return haystack.length - needle.length;
    }

    return 999999999;
  }

  // Lazily populated lists of verb and noun affixes
  static Iterable<WordDatabaseEntry> _verbprefixes, _verbsuffixes;
  static Iterable<WordDatabaseEntry> _nounsuffixes;
  static bool _analysisReady = false;

  // Break the query up into separate words and analyze them
  static List<WordDatabaseEntry> _analyze(Map<String, WordDatabaseEntry> db,
      String query) {
    List<WordDatabaseEntry> results = [];

    if (!_analysisReady) {
      _verbprefixes = db.values.where((e) => e.partOfSpeech == 'v:pref');
      _verbsuffixes = db.values.where((e) => e.partOfSpeech == 'v:suff');
      _nounsuffixes = db.values.where((e) => e.partOfSpeech == 'n:suff');
      _analysisReady = true;
    }

    for (String word in query.split(' ')) {
      results.insertAll(results.length, _analyzeWord(db, word));
    }

    return results;
  }

  // Test whether a word ends with one of the suffixes in the provided list.
  // Returns an identified suffix, or null if no suffix found.
  static WordDatabaseEntry _endsWithSuffix(Iterable<WordDatabaseEntry> suffixes,
      String word) {
    for (WordDatabaseEntry s in suffixes) {
      if (word.endsWith(s.entryName.substring(1))) {
        return s;
      }
    }
    return null;
  }

  // Analyze an individual word which may or may not be composed of multiple
  // individual components. Does not attempt to identify ungrammatical
  // combinations, e.g. suffixes in incorrect order, multiple suffixes of same
  // type, etc.
  static List<WordDatabaseEntry> _analyzeWord(Map<String, WordDatabaseEntry> db,
      String word) {
    List<WordDatabaseEntry> nounResults = [], verbResults = [], results = [];
    String unparsedNoun = word, unparsedVerb = word;
    WordDatabaseEntry suff;

    // Look for exact matches: this could be useful e.g. for stock phrases such
    // as "qoslIj DatIvjaj".
    Iterable<WordDatabaseEntry> exact = db.values.where((e) =>
      e.entryName == word);
    if (exact.isNotEmpty) {
      results.insertAll(0, exact.toList());
    }

    // Pop noun suffixes off the end of the word until no more noun suffixes
    // can be identified.
    while ((suff = _endsWithSuffix(_nounsuffixes, unparsedNoun)) != null) {
      nounResults.insert(0, suff);
      unparsedNoun = unparsedNoun.substring(0, unparsedNoun.length -
        suff.entryName.length+1); // Ignore '-'
    }

    // If noun suffixes were found, try to find an exact match for the remainder
    // of the word once all suffixes were stripped.
    if (nounResults.isNotEmpty) {
      exact = db.values.where((e) =>
          e.searchName.startsWith('$unparsedNoun:n'));
      if (exact.isNotEmpty) {
        results.insertAll(0, nounResults);
        results.insertAll(0, exact);
      } else {
        // Back out the last suffix in case it was homophonous with the last
        // syllable of the stem, e.g. "HomHom", "qoqqoq".
        exact = db.values.where((e) => e.searchName.startsWith(
          '$unparsedNoun${nounResults[0].entryName.substring(1)}:n'));
        if (exact.isNotEmpty) {
          results.insertAll(0, nounResults.sublist(1));
          results.insertAll(0, exact);
        }
      }
    }

    // Do the same for verbs
    while ((suff = _endsWithSuffix(_verbsuffixes, unparsedVerb)) != null) {
      verbResults.insert(0, suff);
      unparsedVerb = unparsedVerb.substring(0, unparsedVerb.length -
        suff.entryName.length+1); // Ignore '-'
    }

    // For verbs, additionally test prefixes. There should only be one prefix,
    // but test against all of them in case the verb stem begins with a string
    // that is coincidentally the same as a prefix, with the 0-prefix attached.
    // Do not require parsed suffixes, since a verb might consist only of a
    // prefix plus a stem.
    for (WordDatabaseEntry pre in _verbprefixes) {
      if (unparsedVerb.startsWith( // ignore '-' and '0'
        pre.entryName.substring(0, pre.entryName.length-1))) {
        String possibleStem = unparsedVerb.substring(pre.entryName.length-1);
        exact = db.values.where((e) =>
          e.searchName.startsWith('$possibleStem:v'));
        if (exact.isNotEmpty) {
          results.insertAll(0, verbResults);
          results.insertAll(0, exact);
          results.insert(0, pre);
        } else if (verbResults.isNotEmpty) {
          // Back out last suffix, similar to what was done for nouns
          exact = db.values.where((e) => e.searchName.startsWith(
            '$possibleStem${verbResults[0].entryName.substring(1)}:v'));
          if (exact.isNotEmpty) {
            results.insertAll(0, verbResults.sublist(1));
            results.insertAll(0, exact);
            results.insert(0, pre);
          }
        }
      }
    }

    return results;
  }

  // Sanitize input
  static String _sanitize(String string) {
    // Desmartify quotes
    string = string.replaceAll('‘', '\'');
    string = string.replaceAll('’', '\'');
    
    return string;
  }

  // Analyze a query and search for matching non-analyzed database entries
  static List<WordDatabaseEntry> match({Map<String, WordDatabaseEntry> db,
    String query}) {
    query = _sanitize(query);

    // Start with analysis results
    List<WordDatabaseEntry> ret = _analyze(db, query);

    if (db != null && query.isNotEmpty) {
      // Search for entries whose entry name, definition, or search tags match
      // the query, excluding any analysis results
      List<WordDatabaseEntry> matches = db.values.where((e) =>
        ret.where((r) => r.searchName == e.searchName).isEmpty && (
          e.entryName.contains(query) ||
          e.definition.contains(query) ||
          e.searchTags.contains(query)
      )).toList();

      // Sort based on which entry contained a hit that most closely resembled
      // the search query.
      matches.sort((WordDatabaseEntry a, WordDatabaseEntry b) {
        return min(_extraChars(query, a.entryName),
            min(_extraChars(query, a.definition),
                _extraChars(query, a.searchTags))) -
            min(_extraChars(query, b.entryName),
                min(_extraChars(query, b.definition),
                    _extraChars(query, b.searchTags)));
      });

      ret.insertAll(ret.length, matches);
    }

    return ret;
  }
}

class WordDatabaseEntry {
  WordDatabaseEntry.fromXmlNode(xml.XmlNode node) {
    try {
      id = int.parse(innerText(ofNode: node, withName: 'id'));
    } catch (InvalidNumberException) {
      // XXX figure out what ID isn't parsing
      id = 0;
    }
    entryName = innerText(ofNode: node, withName: 'entry_name');
    partOfSpeech = innerText(ofNode: node, withName: 'part_of_speech');
    definition = innerText(ofNode: node, withName: 'definition');
    definitionDE = innerText(ofNode: node, withName: 'definition_de');
    synonyms = innerText(ofNode: node, withName: 'synonyms');
    antonyms = innerText(ofNode: node, withName: 'antonyms');
    seeAlso = innerText(ofNode: node, withName: 'see_also');
    notes = innerText(ofNode: node, withName: 'notes');
    notesDe = innerText(ofNode: node, withName: 'notes_de');
    hiddenNotes = innerText(ofNode: node, withName: 'hidden_notes');
    components = innerText(ofNode: node, withName: 'components');
    examples = innerText(ofNode: node, withName: 'examples');
    examplesDe = innerText(ofNode: node, withName: 'examples_de');
    searchTags = innerText(ofNode: node, withName: 'search_tags');
    searchTagsDe = innerText(ofNode: node, withName: 'search_tags_de');
    source = innerText(ofNode: node, withName: 'source');

    searchName = normalizeSearchName('$entryName:$partOfSpeech');
  }

  int id;
  String entryName;
  String partOfSpeech;
  String definition;
  String definitionDE;
  String synonyms;
  String antonyms;
  String seeAlso;
  String notes;
  String notesDe;
  String hiddenNotes;
  String components;
  String examples;
  String examplesDe;
  String searchTags;
  String searchTagsDe;
  String source;
  String searchName;

  static String innerText({xml.XmlNode ofNode, String withName}) {
    Iterable<xml.XmlNode> matching = ofNode.children.where((child) {
      return child.attributes.where((attrib) {
        return attrib.name.toString() == 'name' &&
            attrib.value.toString() == withName;
      }).isNotEmpty;
    });
    if (matching.isNotEmpty) {
      return matching.first.text;
    }
    return '';
  }

  Widget toWidget(TextStyle style, {Function(String) onTap}) {
    final double listPadding = 8.0;
    final double hMargins = 8.0;

    final Widget emptyWidget = const Text('');

    return new Expanded(child: new Padding(
      padding: new EdgeInsets.symmetric(horizontal: hMargins),
      child: new ListView(
        children: [
          new Padding(
            padding: new EdgeInsets.only(bottom: listPadding),
            child: new Text(
              '$entryName',
              style: new TextStyle(
                fontSize: style.fontSize * 2.5,
                fontFamily: 'RobotoSlab',
              ),
          )),
          new Padding(
              padding: new EdgeInsets.only(bottom: listPadding),
              child: new RichText(text: new TextSpan(
                style: style,
                children: [
                  new TextSpan(text: '('),
                  new TextSpan(
                    text: '$partOfSpeech',
                    style: new TextStyle(fontStyle: FontStyle.italic)
                  ),
                  new TextSpan(text: ') $definition'),
                ],
              )),
            ),
          notes.isNotEmpty ? new Padding(
            padding: new EdgeInsets.only(bottom: listPadding),
            child: new KlingonText(
                fromString: '$notes',
                style: style,
                onTap: onTap
            ),
          ) : emptyWidget,
          examples.isNotEmpty ? new Padding(
            padding: new EdgeInsets.only(bottom: listPadding),
            child: new KlingonText(
            fromString: 'Examples: $examples',
            style: style,
            onTap: onTap
            ),
          ) : emptyWidget,
          seeAlso.isNotEmpty ? new Padding(
            padding: new EdgeInsets.only(bottom: listPadding),
            child: new KlingonText(
                fromString: 'See also: $seeAlso',
                style: style,
                onTap: onTap
            ),
          ) : emptyWidget,
          source.isNotEmpty ? new Padding(
            padding: new EdgeInsets.only(bottom: listPadding),
            child: new KlingonText(
                fromString: 'Source(s): $source',
                style: style,
                onTap: onTap
            ),
          ) : emptyWidget,
        ],
    )));
  }

  ListTile toListTile({Function onTap}) {
    return new ListTile(
      title: new Text(
          entryName,
          style: new TextStyle(fontFamily: 'RobotoSlab'),
      ),
      subtitle: new Text(definition),
      onTap: onTap,
    );
  }

  static String normalizeSearchName(String namepos) {
    List<String> split = namepos.split(':');

    if (split.first == '*') {
      return namepos;
    }

    String homophone = '';

    if (split.length > 2) {
      for (String attrib in split[2].split(',')) {
        try {
          int homophoneNum = int.parse(attrib.split('h').first);
          homophone = ':$homophoneNum';
          break;
        } catch (FormatException) {}
      }
    }

    return '${split[0]}:${split[1]}$homophone';
  }
}
