import 'package:flutter/services.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'klingontext.dart';
import 'dart:math';
import 'dart:convert';

// XXX add proper localization support
final locale = 'en';

class WordDatabase {
  static Map<String, WordDatabaseEntry> db;

  static Future<Map<String, WordDatabaseEntry>> getDatabase() async {
    if (db != null) {
      return db;
    }

    db = new Map();

    final memFile = 'data/qawHaq.json';
    final doc = JSON.decode(await rootBundle.loadString(memFile));

    for (String entry in doc['qawHaq'].keys) {
      db[entry] = new WordDatabaseEntry.fromJSON(doc['qawHaq'][entry]);
    }

    return db;
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

    Iterable<WordDatabaseEntry> exact;

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
          // XXX parse, but do not display, the 0 prefix. Maybe this could be
          // user-configurable in case people want it, but it's kind of noisy.
          if (pre.entryName != '0') {
            results.insert(0, pre);
          }
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

    // Look for exact matches: this could be useful e.g. for stock phrases such
    // as "qoslIj DatIvjaj". Don't include exact matches that are already part
    // of the analysis breakdown, as might happen with a zero-prefixed verb with
    // no suffixes. Add these exact matches to the head of the results list.
    exact = db.values.where((e) => e.entryName == word);
    if (exact.isNotEmpty) {
      for (WordDatabaseEntry entry in exact) {
        if (results.where((e) => e.searchName == entry.searchName).isEmpty) {
          results.insert(0, entry);
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
          e.definition[locale].contains(query)
      )).toList();

      // Sort based on which entry contained a hit that most closely resembled
      // the search query.
      matches.sort((WordDatabaseEntry a, WordDatabaseEntry b) {
        return min(_extraChars(query, a.entryName),
            _extraChars(query, a.definition[locale])) -
            min(_extraChars(query, b.entryName),
                _extraChars(query, b.definition[locale]));
      });

      ret.insertAll(ret.length, matches);
    }

    return ret;
  }
}

class WordDatabaseEntry {
  WordDatabaseEntry.fromJSON(Map json) {
    try {
      id = int.parse(json['id']);
    } catch (InvalidNumberException) {
      // XXX figure out what ID isn't parsing
      id = 0;
    }
    entryName = json['entry_name'];
    partOfSpeech = json['part_of_speech'];
    definition = json['definition'];
    synonyms = json['synonyms'];
    antonyms = json['antonyms'];
    seeAlso = json['see_also'];
    notes = json['notes'];
    hiddenNotes = json['hidden_notes'];
    components = json['components'];
    examples = json['examples'];
    searchTags = json['search_tags'];
    source = json['source'];

    searchName = normalizeSearchName('$entryName:$partOfSpeech');
  }

  int id;
  String entryName;
  String partOfSpeech;
  Map<String,String> definition;
  String synonyms;
  String antonyms;
  String seeAlso;
  Map<String, String> notes;
  String hiddenNotes;
  String components;
  Map<String, String> examples;
  Map<String, List<String>> searchTags;
  String source;

  String searchName;

  Widget toWidget(TextStyle style, {Function(String) onTap}) {
    final double listPadding = 8.0;
    final double hMargins = 8.0;

    final Widget emptyWidget = const Text('');

    bool _isNotNullOrEmpty(Map<String, String> map) {
      return map != null && map[locale] != null && map[locale].isNotEmpty;
    }

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
                color: KlingonText.colorForPOS(partOfSpeech),
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
                  new TextSpan(text: ') '),
                  new KlingonText(
                    fromString: '${definition[locale]}',
                    style: style,
                    onTap: onTap,
                  ).text,
                ],
              )),
            ),
          _isNotNullOrEmpty(notes) ? new Padding(
            padding: new EdgeInsets.only(bottom: listPadding),
            child: new KlingonText(
                fromString: '${notes[locale]}',
                style: style,
                onTap: onTap
            ),
          ) : emptyWidget,
          _isNotNullOrEmpty(examples) ? new Padding(
            padding: new EdgeInsets.only(bottom: listPadding),
            child: new KlingonText(
            fromString: 'Examples: ${examples[locale]}',
            style: style,
            onTap: onTap
            ),
          ) : emptyWidget,
          seeAlso != null && seeAlso.isNotEmpty ? new Padding(
            padding: new EdgeInsets.only(bottom: listPadding),
            child: new KlingonText(
                fromString: 'See also: $seeAlso',
                style: style,
                onTap: onTap
            ),
          ) : emptyWidget,
          source != null && source.isNotEmpty ? new Padding(
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
          style: new TextStyle(
            fontFamily: 'RobotoSlab',
            color: KlingonText.colorForPOS(partOfSpeech),
          ),
      ),
      subtitle: new KlingonText(fromString: definition[locale]),
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
