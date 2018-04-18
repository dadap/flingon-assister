import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';

class L10nDelegate extends LocalizationsDelegate<L7dStrings> {
  const L10nDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'de'].contains(locale.languageCode);

  @override
  Future<L7dStrings> load(Locale locale) {
    return new SynchronousFuture<L7dStrings>(L7dStrings(locale));
  }

  @override
  bool shouldReload(L10nDelegate old) {
    // TODO check if locale has changed
    return false;
  }
}

class L7dStrings {
  L7dStrings(this.locale);

  final Locale locale;

  static L7dStrings of (BuildContext context) {
    return Localizations.of<L7dStrings>(context, L7dStrings);
  }

  String l6e (String key) {
    return _strings[key][locale.languageCode];
  }

  static final Map<String, Map<String, String>> _strings = {
    'menu_prefs' : {
      'en' : 'Preferences',
      'de' : 'Einstellungen',
    },
    'menu_ref' : {
      'en' : 'Reference',
      'de' : 'Allgemein',
    },
    'menu_ref_pronunciation' : {
      'en' : 'Pronunciation',
      'de' : 'Aussprache',
    },
    'menu_ref_prefix' : {
      'en' : 'Prefixes',
      'de' : 'Vorsilben',
    },
    'menu_ref_prefixchart' : {
      'en' : 'Prefix Chart',
      'de' : 'Vorsilben-Tabelle',
    },
    'menu_ref_nounsuffix' : {
      'en' : 'Noun Suffixes',
      'de' : 'Nomensuffixe',
    },
    'menu_ref_verbsuffix' : {
      'en' : 'Verb Suffixes',
      'de' : 'Verbsuffixe',
    },
    'menu_phr' : {
      'en' : 'Useful Phrases',
      'de' : 'Nützliche Sätze',
    },
    'menu_phr_beginner' : {
      'en' : 'Beginner\'s Conversation',
      'de' : 'Sätze für Anfänger',
    },
    'menu_phr_jokes' : {
      'en' : 'Jokes and Funny Stories',
      'de' : 'Witze',
    },
    'menu_phr_ascension' : {
      'en' : 'Rite of Ascension',
      'de' : 'Ritus des Aufsteigens',
    },
    'menu_phr_Ql' : {
      'en' : 'QI\'lop Holiday',
      'de' : 'QI\'lop',
    },
    'menu_phr_toasts' : {
      'en' : 'Toasts',
      'de' : 'Trinksprüche',
    },
    'menu_phr_lyrics' : {
      'en' : 'Lyrics',
      'de' : 'Liedtexte',
    },
    'menu_phr_curses' : {
      'en' : 'Curse Warfare',
      'de' : 'Wettfluchen',
    },
    'menu_phr_replproverbs' : {
      'en' : 'Replacement Proverbs',
      'de' : 'Ersatz-Sprichwörter',
    },
    'menu_phr_secrproverbs' : {
      'en' : 'Secrecy Proverbs',
      'de' : 'Geheimnis-Sprichwörter',
    },
    'menu_phr_empunday' : {
      'en' : 'Empire Union Day',
      'de' : 'Reichsfeiertag',
    },
    'menu_phr_reject' : {
      'en' : 'Rejecting a Suitor',
      'de' : 'Ablehnen einer Anmache',
    },
    'menu_media' : {
      'en' : 'Media',
      'de' : 'Medien',
    },
    'menu_media_lessons' : {
      'en' : 'Klingon Lessons',
      'de' : 'Klingonischkurs',
    },
    'menu_media_conversation' : {
      'en' : 'Conversational Phrases',
      'de' : 'Konversation',
    },
    'menu_media_battlecomm' : {
      'en' : 'Battle Commands',
      'de' : 'Kampfbefehle',
    },
    'menu_media_othercomm' : {
      'en' : 'Other Commands',
      'de' : 'Andere Befehle',
    },
    'menu_media_curses' : {
      'en' : 'Curses',
      'de' : 'Flüche',
    },
    'menu_media_other' : {
      'en' : 'Other Words and Phrases',
      'de' : 'Andere Wörter und Sätze',
    },
    'menu_kli' : {
      'en' : 'Klingon Language Institute',
      'de' : 'Klingonisch-Institut',
    },
    'menu_kli_lessons' : {
      'en' : 'Online Lessons',
      'de' : 'Onlinekurs',
    },
    'menu_kli_questions' : {
      'en' : 'Ask Questions!',
      'de' : 'Frage stellen',
    },
  };
}