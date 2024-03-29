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
import 'package:mutex/mutex.dart';

class WordDatabase {
  static Map<String, WordDatabaseEntry> db = new Map();
  static String version = '(loading database…)';
  static String dbFile = '';

  static String builtInDbVersion = '';
  static Mutex mutex = new Mutex();

  static Future<Map<String, WordDatabaseEntry>> getDatabase(
    {bool force = false}) async {

    await mutex.acquire();

    if (force || db.isEmpty) {
      db = new Map();

      await Preferences.loadPreferences();

      // Load the database from a downloaded update if present and newer than the
      // baked-in database in the application bundle, or the baked-in database
      // otherwise.
      final filename = 'qawHaq.json.bz2';
      var data;

      if (WordDatabase.dbFile == '') {
        WordDatabase.dbFile =
        '${(await getApplicationDocumentsDirectory()).path}/$filename';
      }

      if (builtInDbVersion.isEmpty) {
        builtInDbVersion = (await rootBundle.loadString('data/VERSION')).trim();
      }

      if (verCmp(Preferences.dbUpdateVersion, builtInDbVersion) > 0) {
        File file = new File(WordDatabase.dbFile);
        if (await file.exists()) {
          data = await file.readAsBytes();
        } else {
          data = await rootBundle.load('$filename');
        }
      } else {
        data = await rootBundle.load('$filename');
      }

      String json = utf8.decode(new BZip2Decoder().decodeBuffer(
          new InputStream(data)));

      final doc = jsonDecode(json);

      version = doc['version'];
      Preferences.langs = {};
      for (String lang in doc['locales'].keys) {
        Preferences.langs[lang] = doc['locales'][lang];
      }

      Preferences.supportedLangs = [];
      for (String lang in doc['supported_locales']) {
        Preferences.supportedLangs.add(lang);
      }

      doc['qawHaq'].forEach ((key, entry) {
        db[key] = new WordDatabaseEntry.fromJSON(entry);
      });
    }
    mutex.release();

    return db;
  }

  // Measures similarity between haystack and needle. If haystack contains
  // needle, returns the number of extra characters in haystack that aren't
  // also in needle. Otherwise, returns a large number for sorting purposes.
  static int _levenshtein(String s, String t, {int max = 999999999}) {
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
  static Iterable<WordDatabaseEntry> _verbprefixes = {}, _verbsuffixes = {};
  static Iterable<WordDatabaseEntry> _nounsuffixes = {};
  static bool _analysisReady = false;

  // Break the query up into separate words and analyze them
  static List<WordDatabaseEntry> _analyze(Map<String, WordDatabaseEntry> db,
      String query) {
    List<WordDatabaseEntry> results = [];

    if (!_analysisReady) {
      // TODO: Handle cases like 'v:pref,klcp1' properly.
      _verbprefixes = db.values.where((e) => e.partOfSpeech.startsWith('v:pref'));
      _verbsuffixes = db.values.where((e) => e.partOfSpeech.startsWith('v:suff'));
      _nounsuffixes = db.values.where((e) => e.partOfSpeech.startsWith('n:suff'));
      _analysisReady = true;
    }

    for (String word in query.split(' ')) {
      // Strip away any non-alpha characters (pIqaD and "'" count as alpha)
      word = word.replaceAllMapped(new RegExp('[^a-zA-Z\'-\-]'),
        (m) => '');

      results.insertAll(results.length, _analyzeWord(db, word));
    }

    return results;
  }

  // Test whether a word ends with one of the suffixes in the provided list.
  // Returns an identified suffix, or null if no suffix found.
  static WordDatabaseEntry? _endsWithSuffix(Iterable<WordDatabaseEntry> suffixes,
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
    WordDatabaseEntry? suff;

    Iterable<WordDatabaseEntry> exact;

    // Pop noun suffixes off the end of the word until no more noun suffixes
    // can be identified.
    while ((suff = _endsWithSuffix(_nounsuffixes, unparsedNoun)) != null) {
      nounResults.insert(0, suff!);
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
      verbResults.insert(0, suff!);
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
    // Deal with Unicode black magic
    const Map<String,String> unicodeFixes = const {
      // Desmartify quotes
      '‘': "'", '’' : "'",
      // Decompose Unicode: the database is normalized to a decomposed form so
      // that String.toLowerCase() can work on the decomposed characters
      'Å' : 'A\u030a', 	'å' : 'a\u030a',
      'Ä' : 'A\u0308', 	'ä' : 'a\u0308',
      'Ö' : 'O\u0308', 	'ö' : 'o\u0308',
      'Ü' : 'U\u0308', 	'ü' : 'u\u0308',
      // We will probably never see a capital Eszett, but lowercase it anyway,
      // since String.toLowerCase() probably won't do it for us
      'ẞ' : 'ß',
      // Decompose Eszett to "ss" to support Swiss German spelling in search
      'ß' : 'ss',
      // Convert all ё to е to normalize for searches
      'ё' : 'е', 'е\u0308' : 'е', 'Ё' : 'Е', 'Е\u0308' : 'Е',
    };

    unicodeFixes.forEach((find, replace) {
      string = string.replaceAll(find, replace);
    });

    return string;
  }

  static String _transliterate(String string, InputMode inputMode) {
    // Map pIqaD characters to tlhIngan Hol
    const Map<String, String> pIqaD = const {
      '' : 'a', '' : 'b', '' : 'ch', '' : 'D', '' : 'e', '' : 'gh',
      '' : 'H', '' : 'I', '' : 'j', '' : 'l', '' : 'm', '' : 'n',
      '' : 'ng', '' : 'o', '' : 'p', '' : 'q', '' : 'Q', '' : 'r',
      '' : 'S', '' : 't', '' : 'tlh', '' : 'u', '' : 'v', '' : 'w',
      '' : 'y', '' : '\'',
    };

    if (inputMode != InputMode.tlhInganHol) {
      // Normalize string to be transliterated to lowercase before attempting
      // xifan hol transliteration
      string = string.toLowerCase();

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

      xifanCommon.forEach((letter, replacement) {
        string = string.replaceAll(letter, replacement);
      });

      if (inputMode == InputMode.xifanholkq) {
        xifankq.forEach((letter, replacement) {
          string = string.replaceAll(letter, replacement);
        });
      } else if (inputMode == InputMode.xifanholkQ) {
        xifankQ.forEach((letter, replacement) {
          string = string.replaceAll(letter, replacement);
        });
      }
    }

    // Recase letters that can only ever be one case in Klingon
    klingonCase.forEach((letter, replacement) {
      string = string.replaceAll(letter, replacement);
    });

    // 'h' is lowercase when part of 'ch', 'gh', or 'tlh', and capital when 'H'.
    // Replace h/H last, to allow c, g, l, and t to be lowercased first.
    string = string.replaceAllMapped(
      new RegExp('(^|[^gl]|[^t]l)h'), (m) => '${m[1]}H');
    string = string.replaceAllMapped(
      new RegExp('(c|^g|[^n]g|tl)H'), (m) => '${m[1]}h');

    // Transliterate any pIqaD that may be present in the search query
    pIqaD.forEach((letter, replacement) {
      string = string.replaceAll(letter, replacement);
    });

    return string;
  }

  // Determine the minimum Levenshtein distance between a query and the entry
  // name, definition, or search tags of an entry.
  static int _minLeven(String query, String querylc, WordDatabaseEntry entry) {
    int result = 999999999;

    if (Preferences.searchDefinitions &&
        entry.definitionLowercase[Preferences.searchLang] != null) {
      result = min(result, _levenshtein(querylc,
        entry.definitionLowercase[Preferences.searchLang]!));
    }

    if (Preferences.searchEntryNames) {
      result = min(result, _levenshtein(query, entry.entryName));
    }

    if (Preferences.searchSearchTags &&
        entry.searchTags[Preferences.searchLang] != null) {
      entry.searchTags[Preferences.searchLang]!.forEach((tag) {
        result = min(result, _levenshtein(querylc, tag));
      });
    }

    return result;
  }

  // Analyze a query and search for matching non-analyzed database entries
  static List<WordDatabaseEntry> match({Map<String, WordDatabaseEntry>? db,
    String query = '', InputMode? inputMode}) {
    // Get the current locale. Preferences should have already been initialized
    // when the database was initialized.
    String locale = Preferences.searchLang;

    if (inputMode == null) inputMode = Preferences.inputMode;

    // Sanitize query, create a lowercase version for use in non-Klingon text
    // searches, and a transliterated (if appropriate) and Klingon-cased version
    // for Klingon text searches. Perform the Klingon transliteration last, to
    // prevent xifan hol transliterations from affecting non-Klingon search.
    query = _sanitize(query);
    String queryLowercase = query.toLowerCase();
    query = _transliterate(query, inputMode);

    List <WordDatabaseEntry> ret = [];

    // Start with analysis results
    if (db != null && Preferences.searchEntryNames) {
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
            e.searchTags[locale] != null &&
                e.searchTags[locale]!.contains(queryLowercase)
        )).toList();
        ret.addAll(tagMatches);
      }

      List<WordDatabaseEntry> partialMatches = [];

      // Search for entries whose search tags partially match the query,
      // excluding any already identified results
      if (Preferences.searchSearchTags) {
        partialMatches.addAll(db.values.where((e) =>
        ret.where((r) => r.searchName == e.searchName).isEmpty && (
          e.searchTags[locale] != null &&
          e.searchTags[locale]!.where((t) =>
            t.contains(queryLowercase)).isNotEmpty
        )).toList());
      }

      // Search for entries whose entry name or definition partially match the
      // query, excluding any already identified results, sorting based on which
      // partial matches most closely resembled the search query
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
             _levenshtein(query, e.definitionLowercase[locale]!, max: 4) < 4) &&
            e.definitionLowercase[locale]!.contains(queryLowercase)
        ).toList());
      }

      partialMatches.sort((WordDatabaseEntry a, WordDatabaseEntry b) {
        return _minLeven(query, queryLowercase, a) -
          _minLeven(query, queryLowercase, b);
      });
      ret.addAll(partialMatches);
    }

    return ret;
  }

  // Compare two version numbers. Return 0 if version numbers are equal.
  // Return negative if version b is newer than version a.
  // Return positive if version a is newer than version b.
  // Treat versions with more fields as newer than versions with fewer fields.
  // Treat longer version fields as newer than shorter version fields.
  static int verCmp(String a, String b) {
    List<String> aSplit = a.split('.');
    List<String> bSplit = b.split('.');

    if (a.length != b.length) {
      return a.length - b.length;
    }

    for (int i = 0; i < aSplit.length; i++) {
      if (aSplit[i].length != bSplit[i].length) {
        return aSplit[i].length - bSplit[i].length;
      }

      int cmp = aSplit[i].compareTo(bSplit[i]);
      if (cmp != 0) {
        return cmp;
      }
    }

    return 0;
  }

  static Iterable <WordDatabaseEntry> homophones(String searchName)
  {
    String name = searchName.split(':')[0];
    String pos = searchName.split(':')[1];

    return WordDatabase.db.values.where((e) =>
      e.entryName == name && e.partOfSpeech.startsWith(pos));
  }
}

class WordDatabaseEntry {
  // Copy a map of string values parsed from JSON to a map of strings
  static Map<String, String> _localizedMapFromJSON(Map<String, dynamic> json) {
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
    if (json['entry_name'] != null) entryName = json['entry_name'];
    if (json['part_of_speech'] != null) partOfSpeech = json['part_of_speech'];
    if (json['synonyms'] != null) synonyms = json['synonyms'];
    if (json['antonyms'] != null) antonyms = json['antonyms'];
    if (json['see_also'] != null) seeAlso = json['see_also'];
    if (json['hidden_notes'] != null) hiddenNotes = json['hidden_notes'];
    if (json['components'] != null) components = json['components'];
    if (json['source'] != null) source = json['source'];

    searchName = normalizeSearchName('$entryName:$partOfSpeech');

    if (json['definition'] != null) definition = _localizedMapFromJSON(json['definition']);
    if (json['notes'] != null) notes = _localizedMapFromJSON(json['notes']);
    if (json['examples'] != null) examples = _localizedMapFromJSON(json['examples']);

    if (json['search_tags'] != null) {
      searchTags = {};

      for (String lang in json['search_tags'].keys) {
        searchTags[lang] = [];

        for (String tag in json['search_tags'][lang]) {
          searchTags[lang]!.add(tag);
        }
      }
    }

    for (String lang in definition.keys) {
      // Precomputed a lowercased definition for searching. Also decompose "ß"
      // to "ss" to support Swiss German spelling in search, and replace 'ё'
      // with 'е' to make searches agnostic of the presence of a diaresis
      definitionLowercase[lang] =
        definition[lang]!.toLowerCase().
          replaceAll('ß', 'ss').replaceAll('ё', 'е');

      // Infer that commas split lists of multiple definitions and add them as
      // search tags to improve search relevance
      if (definitionLowercase[lang]!.contains(',')) {
        if (searchTags[lang] == null) {
          searchTags[lang] = [];
        }
        searchTags[lang]!.addAll(definitionLowercase[lang]!.split(', '));
      }
    }
  }

  int id = 0;
  String entryName = '';
  String partOfSpeech = '';
  Map<String, String> definition = {};
  Map<String, String> definitionLowercase = {};
  String synonyms = '';
  String antonyms = '';
  String seeAlso = '';
  Map<String, String> notes = {};
  String hiddenNotes = '';
  String components = '';
  Map<String, String> examples = {};
  Map<String, List<String>> searchTags = {};
  String source = '';

  String searchName = '';

  Widget toWidget(TextStyle style, {Function(String)? onTap}) {
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
      return ((map[locale] != null && map[locale]!.isNotEmpty) ||
        map['en'] != null && map['en']!.isNotEmpty);
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
                  fontSize: style.fontSize! * 2.5,
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
          hiddenNotes.isNotEmpty ? new Padding(
            padding: new EdgeInsets.only(bottom: listPadding),
            child: new KlingonText(
              fromString: hiddenNotes,
              style: new TextStyle(fontSize: style.fontSize! * 0.8),
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

  ListTile toListTile({void Function()? onTap}) {
    String locale = Preferences.searchLang;

    return new ListTile(
      title: new KlingonText(fromString: '{$entryName:$partOfSpeech}'),
      subtitle: new KlingonText(
        fromString: definition[locale] != null ?
          definition[locale]! : definition['en']!
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
