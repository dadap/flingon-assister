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
      'tlh' : '{SeHlaw}',
    },
    'prefs_disp' : {
      'en' : 'Display Settings',
      'de' : 'Anzeigeeinstellungen',
      'tlh' : '{HaSta DuHmey}',
    },
    'prefs_disp_dblang' : {
      'en' : 'Database language',
      'de' : 'Datenbanksprache',
      'tlh' : '{qawHaq Hol}',
    },
    'prefs_disp_uilang' : {
      'en' : 'User interface language',
      'de' : 'Benutzeroberflächensprache',
      'tlh' : '{HaSta Hol}', // XXX need better translation
    },
    'prefs_disp_tlhdisp' : {
      'en' : 'Klingon text display',
      'de' : 'Klingonische Textanzeige',
      'tlh' : '{tlhIngan Hol ngutlh tu\'qom}',
    },
    'prefs_disp_poscolors' : {
      'en' : 'Color-code words based on part of speech',
      'de' : 'Zeige Wörter mit Farbe',
      'tlh' : '{mu\'mey nguv}',
    },
    'prefs_search' : {
      'en' : 'Search Settings',
      'de' : 'Sucheinstellungen',
      'tlh' : '{nejmeH DuHmey}',
    },
    'prefs_search_inputmode' : {
      'en' : 'Input mode',
      'de' : 'Eingabemodus',
      'tlh' : '{chay\' ghItlh}',
    },
    'prefs_search_ent' : {
      'en' : 'Search entry names',
      'de' : 'Suche nach Einstragnamen',
      'tlh' : '{tlhIngan Hol mu\'mey tISam}',
    },
    'prefs_search_def' : {
      'en' : 'Search definitions',
      'de' : 'Suche nach Definitionen',
      'tlh' : '{nov Hol jIyweSmey tISam}',
    },
    'prefs_search_tags' : {
      'en' : 'Search search tags',
      'de' : 'Suche nach Such-Tags',
      'tlh' : '{mu\' SammeH permey tISam}',
    },
    'prefs_dbupdate' : {
      'en' : 'Database Update Settings',
      'de' : 'Datenbankaktualisierungeinstellungen',
      'tlh' : '{qawHaqvaD De\' chu\' DuHmey}',
    },
    'prefs_dbupdate_location' : {
      'en' : 'Database update location',
      'de' : 'Databankaktualisierungsspeicherort',
      'tlh' : '{qawHaqvaD De\' chu\' Daq}',
    },
    'dbupdate_check' : {
      'en' : 'Check for updates now',
      'de' : 'Nach Updates suchen',
      'tlh' : '{DaH qawHaqvaD De\' chu\' yInej}',
    },
    'menu_ref' : {
      'en' : 'Reference',
      'de' : 'Allgemein',
      'tlh' : '{De\' lI\'}',
    },
    'menu_ref_pronunciation' : {
      'en' : 'Pronunciation',
      'de' : 'Aussprache',
      'tlh' : '{QIch wab Ho\'DoS}',
    },
    'menu_ref_prefix' : {
      'en' : 'Prefixes',
      'de' : 'Vorsilben',
      'tlh' : '{moHaq}',
    },
    'menu_ref_prefixchart' : {
      'en' : 'Prefix Chart',
      'de' : 'Vorsilben-Tabelle',
      'tlh' : '{moHaq DaH}',
    },
    'menu_ref_nounsuffix' : {
      'en' : 'Noun Suffixes',
      'de' : 'Nomensuffixe',
      'tlh' : '{DIp mojaq}',
    },
    'menu_ref_verbsuffix' : {
      'en' : 'Verb Suffixes',
      'de' : 'Verbsuffixe',
      'tlh' : '{wot mojaq}',
    },
    'menu_phr' : {
      'en' : 'Useful Phrases',
      'de' : 'Nützliche Sätze',
      'tlh' : '{mu\'tlheghmey lI\'}',
    },
    'menu_phr_beginner' : {
      'en' : 'Beginner\'s Conversation',
      'de' : 'Sätze für Anfänger',
      'tlh' : '{ghojchoHwI\' mu\'tlheghmey}',
    },
    'menu_phr_jokes' : {
      'en' : 'Jokes and Funny Stories',
      'de' : 'Witze',
      'tlh' : '{qIDmey, lutmey tlhaQ je}',
    },
    'menu_phr_ascension' : {
      'en' : 'Rite of Ascension',
      'de' : 'Ritus des Aufsteigens',
      'tlh' : '{nentay}',
    },
    'menu_phr_Ql' : {
      'en' : 'QI\'lop Holiday',
      'de' : 'QI\'lop',
      'tlh' : '{QI\'lop}',
    },
    'menu_phr_toasts' : {
      'en' : 'Toasts',
      'de' : 'Trinksprüche',
      'tlh' : '{tlhutlhwI\' mu\'tlheghmey}',
    },
    'menu_phr_lyrics' : {
      'en' : 'Lyrics',
      'de' : 'Liedtexte',
      'tlh' : '{bom mu\'}',
    },
    'menu_phr_curses' : {
      'en' : 'Curse Warfare',
      'de' : 'Wettfluchen',
      'tlh' : '{mu\'qaD veS}',
    },
    'menu_phr_replproverbs' : {
      'en' : 'Replacement Proverbs',
      'de' : 'Ersatz-Sprichwörter',
      'tlh' : '{qa\'meH vIttlheghmey}',
    },
    'menu_phr_secrproverbs' : {
      'en' : 'Secrecy Proverbs',
      'de' : 'Geheimnis-Sprichwörter',
      'tlh' : '{peghmey vIttlheghmey}',
    },
    'menu_phr_empunday' : {
      'en' : 'Empire Union Day',
      'de' : 'Reichsfeiertag',
      'tlh' : '{wo\' boq jaj}',
    },
    'menu_phr_reject' : {
      'en' : 'Rejecting a Suitor',
      'de' : 'Ablehnen einer Anmache',
      'tlh' : '{nga\'chuq \'e\' lajQo\'}',
    },
    'menu_media' : {
      'en' : 'Media',
      'de' : 'Medien',
      'tlh' : '{HaSta tamey}',
    },
    'menu_media_lessons' : {
      'en' : 'Klingon Lessons',
      'de' : 'Klingonischkurs',
      'tlh' : '{tlhIngan Hol ghojmoHmeH SoQmey}',
    },
    'menu_media_conversation' : {
      'en' : 'Conversational Phrases',
      'de' : 'Konversation',
      'tlh' : '{ja\'chuq}',
    },
    'menu_media_battlecomm' : {
      'en' : 'Battle Commands',
      'de' : 'Kampfbefehle',
      'tlh' : '{may\'Daq ra\'meH mu\'tlheghmey}',
    },
    'menu_media_othercomm' : {
      'en' : 'Other Commands',
      'de' : 'Andere Befehle',
      'tlh' : '{ra\'meH latlh mu\'tlheghmey}',
    },
    'menu_media_curses' : {
      'en' : 'Curses',
      'de' : 'Flüche',
      'tlh' : '{mu\'qaDmey}',
    },
    'menu_media_other' : {
      'en' : 'Other Words and Phrases',
      'de' : 'Andere Wörter und Sätze',
      'tlh' : '{latlh mu\'mey mu\'tlheghmey je}',
    },
    'menu_kli' : {
      'en' : 'Klingon Language Institute',
      'de' : 'Klingonisch-Institut',
      'tlh' : '{tlhIngan Hol yejHaD}',
    },
    'menu_kli_lessons' : {
      'en' : 'Online Lessons',
      'de' : 'Onlinekurs',
      'tlh' : '{ghojmeH mIw bonlu\'pu\'bogh}',
    },
    'menu_kli_questions' : {
      'en' : 'Ask Questions!',
      'de' : 'Frage stellen!',
      'tlh' : '{yIghel!}',
    },
    'appname_translation' : {
      'en' : '"Klingon Language Assitant"',
      'de' : '"Klingonisch-Assistent"',
      'tlh' : '', // The line above already says "tlhIngan Hol boQwI'"
    },
    'database_version' : {
      'en' : 'Database version',
      'de' : 'Datenbank version',
      'tlh' : '{qawHaq mI\'}',
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
      'tlh' :
        '\n{mu\'mey Danej \'e\' DaneHchugh, vaj nejmeH Degh yIwIv.:sen:nolink}'
        '\n\n{Qaghmey Dangu\'chugh qoj bIghelnISchugh, vaj HIja\'. :sen:nolink}'
        '{ghItHubDaq Qagh yIDel:tlhurl:'
        'https://github.com/dadap/flingon-assister/issues}{, qoj :sen:nolink}'
        '{QIn yIlI\':tlhurl:mailto:daniel@dadap.net?subject=boQwI\'%20feedback}'
        '\n\n{taHjaj tlhIngan Hol. tlhIngan Hol paqmey yIje\'.:sen:nolink}\n\n'
        '{boQwI\' wa\'DIch ghunlI\' De\'vID:sen:nolink}\n'
        '{boQwI\'vam ghunlI\' De\'nIl DapDap tuq:sen:nolink}\n'
        '{qawHaq gherlI\' De\'vID, latlh ghot je:sen:nolink}\n'
        '{DoyIchlan Hol mughwI\' ghaH Quvar\'e\':sen:nolink}\n'
        '{puq puH veb pIqaD ngutlh tu\'qom renta\' qurgh lungqIj \'aj:sen:nolink}'
        '\n{DISqa\'vI\'rIy pIqaD ngutlh tu\'qom renta\' Quvar:sen:nolink}\n'
        '{pIqaD qolqoS ngutlh tu\'qom renta\' De\'nIl:sen:nolink}\n\n'
        '{tlhIngan Hol chenmoHmo\' pe\'vIl marq \'oqranD wItlho\'.:sen:nolink}'
    }
  };
}