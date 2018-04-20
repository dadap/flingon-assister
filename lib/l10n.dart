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

  Locale locale;

  static L7dStrings of (BuildContext context) {
    return Localizations.of<L7dStrings>(context, L7dStrings);
  }

  String l6e (String key) {
    return _strings[key][locale.languageCode];
  }

  static final Map<String, Map<String, String>> _strings = {
    'prefs' : {
      'en' : 'Preferences',
      'de' : 'Einstellungen',
    },
    'prefs_disp' : {
      'en' : 'Display Settings',
      'de' : 'Anzeigeeinstellungen',
    },
    'prefs_disp_dblang' : {
      'en' : 'Database language',
      'de' : 'Datenbanksprache',
    },
    'prefs_disp_uilang' : {
      'en' : 'User interface language',
      'de' : 'Benutzeroberflächensprache',
    },
    'prefs_disp_tlhdisp' : {
      'en' : 'Klingon text display',
      'de' : 'Klingonische Textanzeige',
    },
    'prefs_search' : {
      'en' : 'Search Settings',
      'de' : 'Sucheinstellungen',
    },
    'prefs_search_inputmode' : {
      'en' : 'Input mode',
      'de' : 'Eingabemodus',
    },
    'prefs_search_ent' : {
      'en' : 'Search entry names',
      'de' : 'Suche nach Einstragnamen',
    },
    'prefs_search_def' : {
      'en' : 'Search definitions',
      'de' : 'Suche nach Definitionen',
    },
    'prefs_search_tags' : {
      'en' : 'Search search tags',
      'de' : 'Suche nach Such-Tags',
    },
    'prefs_dbupdate' : {
      'en' : 'Database Update Settings',
      'de' : 'Datenbankaktualisierungeinstellungen',
    },
    'prefs_dbupdate_location' : {
      'en' : 'Database update location',
      'de' : 'Databankaktualisierungsspeicherort',
    },
    'dbupdate_check' : {
      'en' : 'Check for updates now',
      'de' : 'Nach Updates suchen',
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
    'appname_translation' : {
      'en' : '"Klingon Language Assitant"',
      'de' : '"Klingonisch-Assistent"'
    },
    'database_version' : {
      'en' : 'Database version',
      'de' : 'Datenbank version',
    },
    'helptext' : {
      'en' :
        '\nTo begin searching, simply press the "Search" (magnifying '
        'glass) button and type into the search box.\n\n'
        'It is recommended to install a Klingon keyboard. Otherwise, to '
        'make it easier to type Klingon on a mobile keyboard, the '
        'following shorthand (called "xifan hol") can be enabled under the '
        'Preferences menu:\n'
        'c ▶ {ch:sen:nolink} / d ▶ {D:sen:nolink} / f ▶ {ng:sen:nolink} / '
        'g ▶ {gh:sen:nolink} / h ▶ {H:sen:nolink} /\n'
        'i ▶ {I:sen:nolink} / k ▶ {Q:sen:nolink} / s ▶ {S:sen:nolink} / '
        'x ▶ {tlh:sen:nolink} / z ▶ {\':sen:nolink}\n'
        'It is also possible to choose the alternate keymapping:\n'
        'k ▶ {q:sen:nolink} / q ▶ {Q:sen:nolink}\n\n'
        'If you encounter any problems, or have any suggestions, please '
        '{file an issue on GitHub:url:'
        'http://github.com/dadap/flingon-assister/issues}'
        ' or {send an e-mail:url:mailto:daniel@dadap.net?'
        'subject=boQwI%27%20feedback}.\n\n'
        'Please support the Klingon language by purchasing '
        '{The Klingon Dictionary:src}, '
        '{Klingon for the Galactic Traveler:src}, {The Klingon Way:src}, '
        '{Conversational Klingon:src}, {Power Klingon:src}, and other '
        'Klingon- and Star Trek-related products from Pocket Books, Simon '
        '& Schuster, and Paramount/Viacom/CBS Entertainment.\n\n'
        'Klingon, Star Trek, and related marks are trademarks of CBS '
        'Studios, Inc., and are used under "fair use" guidelines.\n\n'
        'Original {boQwI\':n:nolink} app: {De\'vID:n:name}\n'
        'Flutter (iOS) port: Daniel Dadap\n'
        'Klingon-English Data: {De\'vID:n:nolink}, with help from others\n'
        'German translations: {Quvar:n:name} (Lieven L. Litaer)\n'
        'TNG {pIqaD:n} font: Admiral {qurgh lungqIj:n:name,nolink} of the '
        '{Klingon Assault Group:url:http://www.kag.org/}\n'
        'DSC {pIqaD:n:nolink} font: {Quvar:n:name,nolink} '
        '(Lieven L. Litaer)\n'
        '{pIqaD qolqoS:n:nolink} font: Daniel Dadap\n\n'
        'Special thanks to Mark Okrand ({marq \'oqranD:n:name}) for '
        'creating the Klingon language.'
        ,
      'de' :
        '\nUm eine Suche zu starten, Klicke auf das Suchsymbol (die Lupe) und '
        'gib etwas in das Suchfeld ein.\n\n'
        'Es wird empfohlen, ein klingonische Tastatur zu installieren. Um auf '
        'einer kleinen Tastatur einfacher Klingonisch einzugeben, kann in den '
        'Einstellungen die folgende vereinfachte Eingabemethode ("xifan hol" '
        'genannt) aktiviert werden:\n'
        'c ▶ {ch:sen:nolink} / d ▶ {D:sen:nolink} / f ▶ {ng:sen:nolink} / '
        'g ▶ {gh:sen:nolink} / h ▶ {H:sen:nolink} /\n'
        'i ▶ {I:sen:nolink} / k ▶ {Q:sen:nolink} / s ▶ {S:sen:nolink} / '
        'x ▶ {tlh:sen:nolink} / z ▶ {\':sen:nolink}\n'
        'Zusätzlich kann auch die folgende Tastenbelegung ausgewählt werden:\n'
        'k ▶ {q:sen:nolink} / q ▶ {Q:sen:nolink}\n\n'
        'Bei Problemen oder Vorschlägen, bitte gib ein {Problem auf GitHub'
        ':url:http://github.com/dadap/flingon-assister/issues} oder {sende eine'
        ' E-Mail:url:mailto:daniel@dadap.net?subject=boQwI%27%20feedback}.\n\n'
        'Bitte unterstütze die klingonische Sprache durch den Erwerb der '
        'Bücher {The Klingon Dictionary:src}, '
        '{Klingon for the Galactic Traveler:src}, {The Klingon Way:src}, '
        '{Conversational Klingon:src}, {Power Klingon:src}, sowie der anderen '
        'Klingonen- oder Star-Trek-bezogenen Produkte von Pocket Books, Simon '
        '&amp; Schuster, und Paramount/Viacom/CBS Entertainment.\n\n'
        'Klingon, Star Trek, und verwandte Begriffe sind Schutzmarken von CBS '
        'Studios, Inc., und werden unter "fair use" verwendet.\n\n'
        'Android Programmierung: {De\'vID:n:name}\n'
        'Flutter (iOS) Portierung: Daniel Dadap\n'
        'Klingonisch-Englische Informationen: {De\'vID:n:name,nolink}, mit '
        'Unterstützung von Anderen\n'
        'Deutsche Übersetzung: {Quvar:n:name} (Lieven L. Litaer)\n'
        'TNG {pIqaD:n} Schriftart: Admiral {qurgh lungqIj:n:name,nolink} von '
        'der {Klingon Assault Group:url:http://www.kag.org/}\n'
        'DSC {pIqaD:n:nolink} Schriftart: {Quvar:n:name,nolink} '
        '(Lieven L. Litaer)\n'
        '{pIqaD qolqoS:n:nolink} Schriftart: Daniel Dadap\n\n'
        'Ein besonderer Dank richtet sich an Marc Okrand '
        '({marq \'oqranD:n:name}) für das Erschaffen der klingonischen Sprache.'
        ,
    }
  };
}