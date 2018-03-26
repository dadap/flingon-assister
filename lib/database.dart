import 'package:flutter/services.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'klingontext.dart';
import 'dart:math';
import 'dart:convert';
import 'preferences.dart';
import 'package:archive/archive.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class WordDatabase {
  static Map<String, WordDatabaseEntry> db;
  static String version = '(loading database…)';
  static String dbFile;

  static Future<Map<String, WordDatabaseEntry>> getDatabase(
    {bool force : false}) async {
    if (!force && db != null) {
      return db;
    }

    db = new Map();

    // Load the database from a downloaded update if present, or the baked-in
    // database in the application bundle otherwise.
    final filename = 'qawHaq.json.bz2';
    if (WordDatabase.dbFile == null) {
      WordDatabase.dbFile =
        '${(await getApplicationDocumentsDirectory()).path}/$filename';
    }

    var data;

    File file = new File(WordDatabase.dbFile);
    if (await file.exists()) {
      data = await file.readAsBytes();
    } else {
      data = await rootBundle.load('data/$filename');
    }

    String json = new String.fromCharCodes(new BZip2Decoder().decodeBuffer(
      new InputStream(data)));

    final doc = jsonDecode(json);

    version = doc['version'];

    for (String entry in doc['qawHaq'].keys) {
      db[entry] = new WordDatabaseEntry.fromJSON(doc['qawHaq'][entry]);
    }

    // Load the preferences so we can be aware of the currently selected locale
    await Preferences.loadPreferences();

    return db;
  }

  // Measures similarity between haystack and needle. If haystack contains
  // needle, returns the number of extra characters in haystack that aren't
  // also in needle. Otherwise, returns a large number for sorting purposes.
  static int _levenshtein(String s, String t, {int max: 999999999}) {
    if (s == t)
      return 0;
    if (s.length == 0)
      return t.length;
    if (t.length == 0)
      return s.length;

    if ((s.length - t.length).abs() > max) {
      return max + 1;
    }

    List<int> v0 = new List<int>.filled(t.length + 1, 0);
    List<int> v1 = new List<int>.filled(t.length + 1, 0);

    for (int i = 0; i < t.length + 1; i < i++)
      v0[i] = i;

    for (int i = 0; i < s.length; i++) {
      v1[0] = i + 1;

      for (int j = 0; j < t.length; j++) {
        int cost = (s[i] == t[j]) ? 0 : 1;
        v1[j + 1] = min(v1[j] + 1, min(v0[j + 1] + 1, v0[j] + cost));
      }

      for (int j = 0; j < t.length + 1; j++) {
        v0[j] = v1[j];
      }
    }

    return v1[t.length];
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

  // Table of case fixes for letters that can only ever be one case in Klingon.
  // Case errors in 'h'/'H' or 'q'/'Q' will not be corrected.
  static Map<String, String> klingonCase = {
    'A' : 'a',
    'B' : 'b',
    // 'c' only occurs as part of 'ch', and is always lowercase
    'C' : 'c',
    'd' : 'D',
    'E' : 'e',
    // 'g' may occur as part of 'ng' or 'gh', and is always lowercase.
    'G' : 'g',
    // 'h' and 'H' are handled by separate context-sensitive regex replacements
    'i' : 'I',
    'J' : 'j',
    // 'l' may occur on its own or as part of 'tlh', and is always lowercase
    'L' : 'l',
    'M' : 'm',
    // 'n' may occor on its own or as part of 'ng', and is always lowercase
    'N' : 'n',
    'O' : 'o',
    'P' : 'p',
    // 'q' and 'Q' are distinct letters
    'R' : 'r',
    's' : 'S',
    // 't' may occur on its own or as part of 'tlh', and is always lowercase
    'T' : 't',
    'U' : 'u',
    'V' : 'v',
    'W' : 'w',
    'Y' : 'y',
  };

  // Sanitize input
  static String _sanitize(String string) {
    // Map pIqaD characters to tlhIngan Hol
    const Map<String, String> pIqaD = const {
      '' : 'a', '' : 'b', '' : 'ch', '' : 'D', '' : 'e', '' : 'gh',
      '' : 'H', '' : 'I', '' : 'j', '' : 'l', '' : 'm', '' : 'n',
      '' : 'ng', '' : 'o', '' : 'p', '' : 'q', '' : 'Q', '' : 'r',
      '' : 'S', '' : 't', '' : 'tlh', '' : 'u', '' : 'v', '' : 'w',
      '' : 'y', '' : '\'',
    };

    // Deal with Unicode black magic
    const Map<String,String> unicodeFixes = const {
      // Desmartify quotes
      '‘': "'", '’' : "'",
      // Decompose Unicode: the database is normalized to a decomposed form so
      // that String.toLowerCase() can work on the decomposed characters
      'Ä' : 'A\u0308', 	'ä' : 'a\u0308',
      'Ö' : 'O\u0308', 	'ö' : 'o\u0308',
      'Ü' : 'U\u0308', 	'ü' : 'u\u0308',
      // We will probably never see a capital Eszett, but lowercase it anyway,
      // since String.toLowerCase() probably won't do it for us
      'ẞ' : 'ß'
    };

    for (String fixKey in unicodeFixes.keys) {
      string = string.replaceAll(fixKey, unicodeFixes[fixKey]);
    }

    // Strip away any non-alpha characters (pIqaD and "'" count as alpha)
    string = string.replaceAllMapped(new RegExp('[^a-zA-Zß\u0308\'- \-]'),
                                     (m) => '');

    if (Preferences.inputMode != InputMode.tlhInganHol) {
      // Map xifan hol characters to tlhIngan Hol, ignoring identity mappings
      // and incorrect casing. Process 'h' first to avoid turning "ng" into
      // "ngH" instead of "ngh". Process 'g' before 'f' to avoid turning 'f'
      // into "ngh" instead of "ng".
      const Map<String, String> xifanCommon = const {
        'h': 'H', 'c' : 'ch', 'g' : 'gh', 'f' : 'ng', 'x' : 'tlh', 'z' : '\''
      };
      const Map<String, String> xifankq = const { 'q' : 'Q', 'k' : 'q' };
      const Map<String, String> xifankQ = const { 'k' : 'Q' };

      // Lowercase the query if it was entered in xifan hol
      string = string.toLowerCase();

      for (String letter in xifanCommon.keys) {
        string = string.replaceAll(letter, xifanCommon[letter]);
      }

      if (Preferences.inputMode == InputMode.xifanholkq) {
        for (String letter in xifankq.keys) {
          string = string.replaceAll(letter, xifankq[letter]);
        }
      } else if (Preferences.inputMode == InputMode.xifanholkQ) {
        for (String letter in xifankQ.keys) {
          string = string.replaceAll(letter, xifankQ[letter]);
        }
      }
    }

    // Recase letters that can only ever be one case in Klingon
    for (String letter in klingonCase.keys) {
      string = string.replaceAll(letter, klingonCase[letter]);
    }

    // 'h' is lowercase when part of 'ch', 'gh', or 'tlh', and capital when 'H'.
    // Replace h/H last, to allow c, g, l, and t to be lowercased first.
    string = string.replaceAllMapped(
      new RegExp('(^|[^gl]|[^t]l)h'), (m) => '${m[1]}H');
    string = string.replaceAllMapped(
      new RegExp('(c|^g|[^n]g|tl)H'), (m) => '${m[1]}h');

    // Transliterate any pIqaD that may be present in the search query
    for (String letter in pIqaD.keys) {
      string = string.replaceAll(letter, pIqaD[letter]);
    }

    return string;
  }

  // Analyze a query and search for matching non-analyzed database entries
  static List<WordDatabaseEntry> match({Map<String, WordDatabaseEntry> db,
    String query}) {
    // Get the current locale. Preferences should have already been initialized
    // when the database was initialized.
    String locale = Preferences.searchLang;

    // Sanitize query for use in Klingon text searches, and create a lowercase
    // version for use in non-Klingon text searches
    String queryLowercase = query.toLowerCase();
    query = _sanitize(query);

    List <WordDatabaseEntry> ret = [];

    // Start with analysis results
    if (Preferences.searchEntryNames) {
      ret.addAll(_analyze(db, query));
    }

    if (db != null && query.isNotEmpty) {
      // Search for entries whose entry name or definition exactly match the
      // query, excluding any analysis results
      if (Preferences.searchEntryNames) {
        List<WordDatabaseEntry> exactMatches = db.values.where((e) =>
        ret.where((r) => r.searchName == e.searchName).isEmpty && (
            e.entryName == query
        )).toList();
        ret.addAll(exactMatches);
      }

      if (Preferences.searchDefinitions) {
        List<WordDatabaseEntry> exactMatches = db.values.where((e) =>
        ret.where((r) => r.searchName == e.searchName).isEmpty && (
            e.definitionLowercase[locale] == queryLowercase
        )).toList();
        ret.addAll(exactMatches);
      }

      // Search for entries whose search tags exactly match the query,
      // excluding any already identified results
      if (Preferences.searchSearchTags) {
        List<WordDatabaseEntry> tagMatches = db.values.where((e) =>
        ret.where((r) => r.searchName == e.searchName).isEmpty && (
            e.searchTags != null && e.searchTags[locale] != null &&
                e.searchTags[locale].contains(queryLowercase)
        )).toList();
        ret.addAll(tagMatches);
      }

      // Search for entries whose search tags partially match the query,
      // excluding any already identified results
      if (Preferences.searchSearchTags) {
        List<WordDatabaseEntry> partialTagMatches = db.values.where((e) =>
        ret.where((r) => r.searchName == e.searchName).isEmpty && (
          e.searchTags != null && e.searchTags[locale] != null &&
          e.searchTags[locale].where((t) => t.contains(query)).isNotEmpty
        )).toList();
        ret.addAll(partialTagMatches);
      }

      // Search for entries whose entry name or definition partially match the
      // query, excluding any already identified results, sorting based on which
      // partial matches most closely resembled the search query
      List<WordDatabaseEntry> partialMatches = [];

      if (Preferences.searchEntryNames) {
        partialMatches.addAll(db.values.where((e) =>
        ret.where((r) => r.searchName == e.searchName).isEmpty &&
            (query.length > 2 ||
             _levenshtein(query, e.entryName, max: 8) < 8) &&
            e.entryName.contains(query)
        ).toList());
      }

      if (Preferences.searchDefinitions) {
        partialMatches.addAll(db.values.where((e) =>
        ret.where((r) => r.searchName == e.searchName).isEmpty &&
            partialMatches.where((m) => m.searchName == e.searchName).isEmpty &&
            e.definitionLowercase[locale] != null &&
            (query.length > 2 ||
             _levenshtein(query, e.definitionLowercase[locale], max: 4) < 4) &&
            e.definitionLowercase[locale].contains(queryLowercase)
        ).toList());
      }

      partialMatches.sort((WordDatabaseEntry a, WordDatabaseEntry b) {
        if (a.definitionLowercase[locale] == null ||
            b.definitionLowercase[locale] == null) {
          return _levenshtein(query, a.entryName) -
                 _levenshtein(query, b.entryName);
        }

        return min(_levenshtein(query, a.entryName),
                   _levenshtein(query, a.definitionLowercase[locale])) -
               min(_levenshtein(query, b.entryName),
                   _levenshtein(query, b.definitionLowercase[locale]));
      });
      ret.addAll(partialMatches);
    }

    return ret;
  }
}

class WordDatabaseEntry {
  // Copy a map of string values parsed from JSON to a map of strings
  static Map<String, String> _localizedMapFromJSON(Map<String, dynamic> json) {
    if (json == null) {
      return null;
    }

    Map<String, String> ret = {};

    for (String lang in json.keys) {
      ret[lang] = json[lang];
    }

    return ret;
  }

  WordDatabaseEntry.fromJSON(Map json) {
    try {
      id = int.parse(json['id']);
    } catch (InvalidNumberException) {
      // XXX figure out what ID isn't parsing
      id = 0;
    }
    entryName = json['entry_name'];
    partOfSpeech = json['part_of_speech'];
    synonyms = json['synonyms'];
    antonyms = json['antonyms'];
    seeAlso = json['see_also'];
    hiddenNotes = json['hidden_notes'];
    components = json['components'];
    source = json['source'];

    searchName = normalizeSearchName('$entryName:$partOfSpeech');

    definition = _localizedMapFromJSON(json['definition']);
    notes = _localizedMapFromJSON(json['notes']);
    examples = _localizedMapFromJSON(json['examples']);

    if (json['search_tags'] != null) {
      searchTags = {};

      for (String lang in json['search_tags'].keys) {
        searchTags[lang] = json[lang];
      }
    }

    for (String lang in definition.keys) {
      if (definitionLowercase == null) {
        definitionLowercase = {};
      }

      // Precomputed a lowercased definition for searching
      definitionLowercase[lang] = definition[lang].toLowerCase();

      // Infer that commas split lists of multiple definitions and add them as
      // search tags to improve search relevance
      if (definitionLowercase[lang].contains(',')) {
        if (searchTags == null) {
          searchTags = {};
        }
        if (searchTags[lang] == null) {
          searchTags[lang] = [];
        }
        searchTags[lang].addAll(definitionLowercase[lang].split(', '));
      }
    }
  }

  int id;
  String entryName;
  String partOfSpeech;
  Map<String, String> definition;
  Map<String, String> definitionLowercase;
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
    String locale = Preferences.searchLang;

    // Fall back to English if this entry does not have a definition in the
    // current locale.
    if (definition[locale] == null) {
      locale = 'en';
    }

    // Tests whether the given localized entry contains text, falling back
    // to English if empty in the current locale.
    bool _isNotNullOrEmpty(Map<String, String> map) {
      return map != null && ((map[locale] != null && map[locale].isNotEmpty) ||
        map['en'] != null && map['en'].isNotEmpty);
    }

    return new Expanded(child: new Padding(
      padding: new EdgeInsets.symmetric(horizontal: hMargins),
      child: new ListView(
        children: [
          new Padding(
            padding: new EdgeInsets.only(bottom: listPadding),
            child: new KlingonText(
                fromString: '{$entryName:$partOfSpeech}',
                style: new TextStyle(
                  fontSize: style.fontSize * 2.5,
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
                fromString: '${notes[locale] == null ?
                  notes['en'] : notes[locale]}',
                style: style,
                onTap: onTap
            ),
          ) : emptyWidget,
          hiddenNotes != null && hiddenNotes.isNotEmpty ? new Padding(
            padding: new EdgeInsets.only(bottom: listPadding),
            child: new KlingonText(
              fromString: hiddenNotes,
              style: new TextStyle(fontSize: style.fontSize * 0.8),
              onTap: onTap,
            ),
          ) : emptyWidget,
          _isNotNullOrEmpty(examples) ? new Padding(
            padding: new EdgeInsets.only(bottom: listPadding),
            child: new KlingonText(
            fromString: 'Examples: ${examples[locale] == null ?
              examples['en'] : examples[locale]}',
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
    String locale = Preferences.searchLang;

    return new ListTile(
      title: new KlingonText(fromString: '{$entryName:$partOfSpeech}'),
      subtitle: new KlingonText(
        fromString: definition[locale] != null ?
          definition[locale] : definition['en']
      ),
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
