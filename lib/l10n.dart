import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';

class L10nDelegate extends LocalizationsDelegate<L7dStrings> {
  static List<String> supportedLocales = ['en', 'de', 'tlh'];
  const L10nDelegate();

  @override
  bool isSupported(Locale locale) =>
    supportedLocales.contains(locale.languageCode);

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

  static L7dStrings? of (BuildContext context) {
    return Localizations.of<L7dStrings>(context, L7dStrings);
  }

  String? l6e (String key) {
    return _strings[key]![locale.languageCode];
  }

  static final Map<String, Map<String, String>> _strings = {
    'prefs' : {
      'en' : 'Preferences',
      'de' : 'Einstellungen',
      'tlh' : '{SeHlaw}',
      'pt' : 'Preferências',
    },
    'prefs_disp' : {
      'en' : 'Display Settings',
      'de' : 'Anzeigeeinstellungen',
      'tlh' : '{HaSta DuHmey}',
      'pt' : 'Configurações de visualização',
    },
    'prefs_disp_dblang' : {
      'en' : 'Database language',
      'de' : 'Datenbanksprache',
      'tlh' : '{qawHaq Hol}',
      'pt' : 'Língua do banco de dados',
    },
    'prefs_disp_alldblangs' : {
      'en' : 'Enable incomplete database languages',
      'de' : 'Unvollständige Datenbanksprachen aktivieren',
      'tlh' : '{qawHaq Holmey naQHa\' yIDuHmoH}',
      'pt' : 'Habilitar banco de dados de línguas incompletas',
    },
    'prefs_disp_uilang' : {
      'en' : 'User interface language',
      'de' : 'Benutzeroberflächensprache',
      'tlh' : '{HaSta Hol}', // XXX need better translation
      'pt' : 'Língua da interface de usuário',
    },
    'prefs_disp_tlhdisp' : {
      'en' : 'Klingon text display',
      'de' : 'Klingonische Textanzeige',
      'tlh' : '{tlhIngan Hol ngutlh tu\'qom}',
      'pt' : 'Exibir texto em Klingon',
    },
    'prefs_disp_poscolors' : {
      'en' : 'Color-code words based on part of speech',
      'de' : 'Wörter nach Wortart einfärben',
      'tlh' : '{mu\'mey nguv}',
      'pt' : 'Código de cores baseado no tipo de palavra',
    },
    'prefs_search' : {
      'en' : 'Search Settings',
      'de' : 'Sucheinstellungen',
      'tlh' : '{nejmeH DuHmey}',
      'pt' : 'Configurações de pesquisa',
    },
    'prefs_search_inputmode' : {
      'en' : 'Input mode',
      'de' : 'Eingabemodus',
      'tlh' : '{chay\' ghItlh}',
      'pt' : 'Modo de entrada',
    },
    'prefs_search_ent' : {
      'en' : 'Search entry names',
      'de' : 'Suche nach Einträgen',
      'tlh' : '{tlhIngan Hol mu\'mey tISam}',
      'pt' : 'Pesquisar nome das entradas',
    },
    'prefs_search_def' : {
      'en' : 'Search definitions',
      'de' : 'Suche nach Definitionen',
      'tlh' : '{nov Hol jIyweSmey tISam}',
      'pt' : 'Procurar por definições',
    },
    'prefs_search_tags' : {
      'en' : 'Search search tags',
      'de' : 'Suche nach Such-Tags',
      'tlh' : '{mu\' SammeH permey tISam}',
      'pt' : 'Procurar por palavras-chaves',
    },
    'prefs_dbupdate' : {
      'en' : 'Database Update Settings',
      'de' : 'Datenbankaktualisierungeinstellungen',
      'tlh' : '{qawHaqvaD De\' chu\' DuHmey}',
      'pt' : 'Configurações de atualização do banco de dados',
    },
    'prefs_dbupdate_location' : {
      'en' : 'Database update location',
      'de' : 'Pfad zur Datenbankaktualisierung',
      'tlh' : '{qawHaqvaD De\' chu\' Daq}',
      'pt' : 'Local de atualização do banco de dados',
    },
    'dbupdate_check' : {
      'en' : 'Check for updates now',
      'de' : 'Nach Updates suchen',
      'tlh' : '{DaH qawHaqvaD De\' chu\' yInej}',
      'pt' : 'Checar por atualizações agora',
    },
    'dbupdate_badmanifest' : {
      'en' : 'The manifest appears to be invalid.',
      'de' : 'Das Manifest scheint ungültig zu sein.',
      'tlh' : '{qawHaq De\' chu\' DelHa\'lu\'law\'}',
      'pt' : 'O manifesto parece ser inválido.',
    },
    'dbupdate_checking' : {
      'en' : 'Checking for updates',
      'de' : 'Nach Updates suchen',
      'tlh' : '{qawHaq De\' chu\' vInejtaH}',
      'pt' : 'Buscando atualizações',
    },
    'dbupdate_manifetcherr' : {
      'en' : 'An error occurred while fetching the update manifest',
      'de' : 'Beim Abrufen des Update-Manifests ist ein Fehler aufgetreten',
      'tlh' : '{qawHaq De\' chu\' Delbogh ghItlh vIlI\'taHvIS, qaSpu\' Qagh}',
      'pt' : 'Um error ocorreu ao buscar o manifesto de atualizações',
    },
    'menu_ref' : {
      'en' : 'Reference',
      'de' : 'Allgemein',
      'tlh' : '{De\' lI\'}',
      'pt' : 'Referência',
    },
    'menu_ref_pronunciation' : {
      'en' : 'Pronunciation',
      'de' : 'Aussprache',
      'tlh' : '{QIch wab Ho\'DoS}',
      'pt' : 'Pronunciação',
    },
    'menu_ref_prefix' : {
      'en' : 'Prefixes',
      'de' : 'Vorsilben',
      'tlh' : '{moHaq}',
      'pt' : 'Prefíxos',
    },
    'menu_ref_prefixchart' : {
      'en' : 'Prefix Chart',
      'de' : 'Vorsilben-Tabelle',
      'tlh' : '{moHaq DaH}',
      'pt' : 'Tabela de prefíxos',
    },
    'menu_ref_nounsuffix' : {
      'en' : 'Noun Suffixes',
      'de' : 'Nomensuffixe',
      'tlh' : '{DIp mojaq}',
      'pt' : 'Sufíxos nomiais',
    },
    'menu_ref_verbsuffix' : {
      'en' : 'Verb Suffixes',
      'de' : 'Verbsuffixe',
      'tlh' : '{wot mojaq}',
      'pt' : 'Sufíxos verbais',
    },
    'menu_phr' : {
      'en' : 'Useful Phrases',
      'de' : 'Nützliche Sätze',
      'tlh' : '{mu\'tlheghmey lI\'}',
      'pt' : 'Frases úteis',
    },
    'menu_phr_beginner' : {
      'en' : 'Beginner\'s Conversation',
      'de' : 'Sätze für Anfänger',
      'tlh' : '{ghojchoHwI\' mu\'tlheghmey}',
      'pt' : 'Conversação para iniciantes',
    },
    'menu_phr_jokes' : {
      'en' : 'Jokes and Funny Stories',
      'de' : 'Witze',
      'tlh' : '{qIDmey, lutmey tlhaQ je}',
      'pt' : 'Piadas e hisórias engraçadas',
    },
    'menu_phr_ascension' : {
      'en' : 'Rite of Ascension',
      'de' : 'Ritus des Aufsteigens',
      'tlh' : '{nentay}',
      'pt' : 'Ritual de Ascensão',
    },
    'menu_phr_Ql' : {
      'en' : 'QI\'lop Holiday',
      'de' : 'QI\'lop',
      'tlh' : '{QI\'lop}',
      'pt' : 'QI\'lop',
    },
    'menu_phr_toasts' : {
      'en' : 'Toasts',
      'de' : 'Trinksprüche',
      'tlh' : '{tlhutlhwI\' mu\'tlheghmey}',
      'pt' : 'Brindes',
    },
    'menu_phr_lyrics' : {
      'en' : 'Lyrics',
      'de' : 'Liedtexte',
      'tlh' : '{bom mu\'}',
      'pt' : 'Letras de músicas',
    },
    'menu_phr_curses' : {
      'en' : 'Curse Warfare',
      'de' : 'Wettfluchen',
      'tlh' : '{mu\'qaD veS}',
      'pt' : 'Guerra de Insultos',
    },
    'menu_phr_replproverbs' : {
      'en' : 'Replacement Proverbs',
      'de' : 'Ersatz-Sprichwörter',
      'tlh' : '{qa\'meH vIttlheghmey}',
      'pt' : 'Provérbios de substituição',
    },
    'menu_phr_secrproverbs' : {
      'en' : 'Secrecy Proverbs',
      'de' : 'Geheimnis-Sprichwörter',
      'tlh' : '{peghmey vIttlheghmey}',
      'pt' : 'Provérbios de segredo',
    },
    'menu_phr_empunday' : {
      'en' : 'Empire Union Day',
      'de' : 'Tag der Reichsvereinigung',
      'tlh' : '{wo\' boq jaj}',
      'pt' : 'Dia da União do Império',
    },
    'menu_phr_reject' : {
      'en' : 'Rejecting a Suitor',
      'de' : 'Annäherungsversuche ablehnen',
      'tlh' : '{nga\'chuq \'e\' lajQo\'}',
      'pt' : 'Rejeitando um pretendente',
    },
    'menu_media' : {
      'en' : 'Media',
      'de' : 'Medien',
      'tlh' : '{HaSta tamey}',
      'pt' : 'Mídia',
    },
    'menu_media_lessons' : {
      'en' : 'Klingon Lessons',
      'de' : 'Klingonischkurs',
      'tlh' : '{tlhIngan Hol ghojmoHmeH SoQmey}',
      'pt' : 'Lições de Klingon',
    },
    'menu_media_conversation' : {
      'en' : 'Conversational Phrases',
      'de' : 'Konversation',
      'tlh' : '{ja\'chuq}',
      'pt' : 'Frases de Conversação',
    },
    'menu_media_battlecomm' : {
      'en' : 'Battle Commands',
      'de' : 'Kampfbefehle',
      'tlh' : '{may\'Daq ra\'meH mu\'tlheghmey}',
      'pt' : 'Comandos de batalha',
    },
    'menu_media_othercomm' : {
      'en' : 'Other Commands',
      'de' : 'Andere Befehle',
      'tlh' : '{ra\'meH latlh mu\'tlheghmey}',
      'pt' : 'Outros Comandos',
    },
    'menu_media_curses' : {
      'en' : 'Curses',
      'de' : 'Flüche',
      'tlh' : '{mu\'qaDmey}',
      'en' : 'Insultos',
    },
    'menu_media_other' : {
      'en' : 'Other Words and Phrases',
      'de' : 'Andere Wörter und Sätze',
      'tlh' : '{latlh mu\'mey mu\'tlheghmey je}',
      'pt' : 'Outras palavras e frases',
    },
    'menu_kli' : {
      'en' : 'Klingon Language Institute',
      'de' : 'Klingonisch-Institut',
      'tlh' : '{tlhIngan Hol yejHaD}',
      'pt' : 'Instituto da Língua Klingon',
    },
    'menu_kli_lessons' : {
      'en' : 'Online Lessons',
      'de' : 'Onlinekurs',
      'tlh' : '{ghojmeH mIw bonlu\'pu\'bogh}',
      'pt' : 'Lições Online',
    },
    'menu_kli_questions' : {
      'en' : 'Ask Questions!',
      'de' : 'Stell eine Frage!',
      'tlh' : '{yIghel!}',
      'pt' : 'Faça uma pergunta!',
    },
    'appname_translation' : {
      'en' : '"Klingon Language Assistant"',
      'de' : '"Klingonisch-Assistent"',
      'tlh' : '', // The line above already says "tlhIngan Hol boQwI'"
      'pt' : '"Assistente da Língua Klingon"',
    },
    'database_version' : {
      'en' : 'Database version',
      'de' : 'Datenbankversion',
      'tlh' : '{qawHaq mI\'}',
      'pt' : 'Versão do Banco de dados',
    },
    'helptext' : {
      'en' :
        '\nTo begin searching, simply press the "Search" (magnifying '
        'glass) button and type into the search box.\n\n'
        'To hear the sounds of Klingon, you need to install a '
        '{Klingon Text to Speech app:url:'
        'https://itunes.apple.com/us/app/hija/id1366951358}\n\n'
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
        '{qurgh pIqaD:n} font: Admiral {qurgh lungqIj:n:name,nolink} of the '
        '{Klingon Assault Group:url:http://www.kag.org/}\n'
        '{DISqa\'vI\'rIy pIqaD:n:nolink} font: {Quvar:n:name,nolink} '
        '(Lieven L. Litaer)\n'
        '{pIqaD qolqoS:n:nolink} font: Daniel Dadap\n\n'
        'Special thanks to Mark Okrand ({marq \'oqranD:n:name}) for '
        'creating the Klingon language.'
        ,
      'de' :
        '\nUm eine Suche zu starten, klicke auf das Suchsymbol (die Lupe) und '
        'gib etwas in das Suchfeld ein.\n\n'
        'Um die klingonischen Wörter zu hören, muss die {klingonisch '
        'Vorlesesoftware:url:https://itunes.apple.com/us/app/hija/id1366951358}'
        ' installiert werden.\n\n'
        'Es wird empfohlen, eine klingonische Tastatur zu installieren. Um auf '
        'einer kleinen Tastatur einfacher Klingonisch einzugeben, kann in den '
        'Einstellungen die folgende vereinfachte Eingabemethode ("xifan hol" '
        'genannt) aktiviert werden:\n'
        'c ▶ {ch:sen:nolink} / d ▶ {D:sen:nolink} / f ▶ {ng:sen:nolink} / '
        'g ▶ {gh:sen:nolink} / h ▶ {H:sen:nolink} /\n'
        'i ▶ {I:sen:nolink} / k ▶ {Q:sen:nolink} / s ▶ {S:sen:nolink} / '
        'x ▶ {tlh:sen:nolink} / z ▶ {\':sen:nolink}\n'
        'Zusätzlich kann auch die folgende Tastenbelegung ausgewählt werden:\n'
        'k ▶ {q:sen:nolink} / q ▶ {Q:sen:nolink}\n\n'
        'Bei Problemen oder Vorschlägen, öffne bitte ein {Issue auf GitHub'
        ':url:http://github.com/dadap/flingon-assister/issues} oder {sende eine'
        ' E-Mail:url:mailto:daniel@dadap.net?subject=boQwI%27%20feedback}.\n\n'
        'Bitte unterstütze die klingonische Sprache durch den Erwerb der '
        'Bücher {The Klingon Dictionary:src}, '
        '{Klingon for the Galactic Traveler:src}, {The Klingon Way:src}, '
        '{Conversational Klingon:src}, {Power Klingon:src}, sowie anderer '
        'Produkte mit Klingonen- oder Star-Trek-Bezug von Pocket Books, Simon '
        '&amp; Schuster, und Paramount/Viacom/CBS Entertainment.\n\n'
        'Klingon, Star Trek, und verwandte Begriffe sind Schutzmarken von CBS '
        'Studios, Inc., und werden unter "fair use" verwendet.\n\n'
        'Android Programmierung: {De\'vID:n:name}\n'
        'Flutter (iOS) Portierung: Daniel Dadap\n'
        'Klingonisch-Englische Informationen: {De\'vID:n:name,nolink}, mit '
        'Unterstützung von Anderen\n'
        'Deutsche Übersetzung: {Quvar:n:name} (Lieven L. Litaer)\n'
        '{qurgh pIqaD:n} Schriftart: Admiral {qurgh lungqIj:n:name,nolink} von '
        'der {Klingon Assault Group:url:http://www.kag.org/}\n'
        '{DISqa\'vI\'rIy pIqaD:n:nolink} Schriftart: {Quvar:n:name,nolink} '
        '(Lieven L. Litaer)\n'
        '{pIqaD qolqoS:n:nolink} Schriftart: Daniel Dadap\n\n'
        'Ein besonderer Dank richtet sich an Marc Okrand '
        '({marq \'oqranD:n:name}) für das Erschaffen der klingonischen Sprache.'
        ,
      'tlh' :
        '\n{mu\'mey Danej DaneHchugh, vaj nejmeH Degh yIwIv.:sen:nolink}\n\n'
        '{tlhIngan Hol QIch wabmey DaQoy DaneHchugh, vaj :sen:nolink}'
        '{QIch nIqHom:tlhurl:https://itunes.apple.com/us/app/hija/id1366951358}'
        ' {DaSuqnIS.:sen:nolink}\n\n'
        '{Qaghmey Dangu\'chugh qoj bIghelnISchugh, vaj :sen:nolink}'
        '{ghItHubDaq Qagh yIDel:tlhurl:'
        'https://github.com/dadap/flingon-assister/issues}{, qoj :sen:nolink}'
        '{QIn yIlI\':tlhurl:mailto:daniel@dadap.net?subject=boQwI\'%20feedback}'
        '\n\n{taHjaj tlhIngan Hol. tlhIngan Hol paqmey yIje\'. :sen:nolink}'
        "{tlhIngan Hol mu'ghom, qIb lengwI'vaD tlhIngan Hol, tlhIngan Ho'DoS, "
        "ja'chuqmeH tlhIngan Hol, HoS tlhIngan Hol, latlh tlhIngan Hol "
        "bopbogh paqmey je yIje'. tlhIngan Hol, Hov leng je ghajwI'pu' maHbe' "
        "boQwI' ghunwI'pu''e'. mu'meyvam wIlo' net may.:sen:nolink}\n\n"
        '{boQwI\' wa\'DIch ghunlI\' :sen:nolink}{De\'vID:n:name}\n'
        '{boQwI\'vam ghunlI\' :sen:nolink}{De\'nIl DapDap tuq:n:name,nolink}\n'
        '{qawHaq gherlI\' :sen:nolink}{De\'vID:n:name,nolink}'
        '{, latlh ghot je:sen:nolink}\n'
        '{DoyIchlan Hol mughwI\' ghaH :sen:nolink}{Quvar:n:name}'
        '{\'e\':sen:nolink}\n'
        '{qurgh pIqaD ngutlh tu\'qom chenmoH :sen:nolink}'
        '{Hol \'ampaS:tlhurl:http://hol.kag.org}{ Devbogh :sen:nolink}'
        '{ qurgh \'aj lungqIj tuq:n:name,nolink}\n'
        '{DISqa\'vI\'rIy pIqaD ngutlh tu\'qom chenmoH :sen:nolink}'
        '{Quvar:n:name,nolink}\n'
        '{pIqaD qolqoS ngutlh tu\'qom chenmoH :sen:nolink}'
        '{De\'nIl:n:name,nolink}\n\n'
        '{tlhIngan Hol chenmoHmo\' pe\'vIl :sen:nolink}'
        '{marq \'oqranD:n:name}{ wItlho\'.:sen:nolink}'
        ,
        'pt' :
          '\nPara começar a pesquisar, clique em Pesquisar (lente de aumento'
          'e digite na barra de busca.\n\n'
          'Para ouvir sons em klingon, você precisa instalar o aplicativo '
          '{Klingon Text to Speech app:url:'
          'https://itunes.apple.com/us/app/hija/id1366951358}\n\n'
          'É recomendado que você instale o teclado Klingon. Caso contrário para'
          'facilitar a digitação em Klingon no teclado do celular, a seguinte'
          'regra (chamada "xifan hol") pode ser habilitada no menu Preferências:\n'
          'c ▶ {ch:sen:nolink} / d ▶ {D:sen:nolink} / f ▶ {ng:sen:nolink} / '
          'g ▶ {gh:sen:nolink} / h ▶ {H:sen:nolink} /\n'
          'i ▶ {I:sen:nolink} / k ▶ {Q:sen:nolink} / s ▶ {S:sen:nolink} / '
          'x ▶ {tlh:sen:nolink} / z ▶ {\':sen:nolink}\n'
          'Também é possible escolher um outro mapeamento alternativo:\n'
          'k ▶ {q:sen:nolink} / q ▶ {Q:sen:nolink}\n\n'
          'Se você encontrar qualquer problemas, ou tiver sugestões, por favor'
          '{file an issue on GitHub:url:'
          'http://github.com/dadap/flingon-assister/issues}'
          ' ou {envie um e-mail:url:mailto:daniel@dadap.net?'
          'subject=boQwI%27%20feedback}.\n\n'
          'Por favor suporte a língua Klingon comprando  '
          '{The Klingon Dictionary:src}, '
          '{Klingon for the Galactic Traveler:src}, {The Klingon Way:src}, '
          '{Conversational Klingon:src}, {Power Klingon:src}, e outros '
          'Klingon- e Star Trek produtos relacionados da Pocket Books, Simon '
          '& Schuster, e Paramount/Viacom/CBS Entertainment.\n\n'
          'Klingon, Star Trek, e marcas relacionadas são marcas registradas da '
          'CBS Studios, Inc., e são usadas sob a diretiva de "uso justo".\n\n'
          'Original {boQwI\':n:nolink} app: {De\'vID:n:name}\n'
          'Flutter (iOS) port: Daniel Dadap\n'
          'Klingon-English Data: {De\'vID:n:nolink}, com ajuda de outros\n'
          'Tradução Alemã: {Quvar:n:name} (Lieven L. Litaer)\n'
          '{qurgh pIqaD:n} fonte: Admiral {qurgh lungqIj:n:name,nolink} do '
          '{Klingon Assault Group:url:http://www.kag.org/}\n'
          '{DISqa\'vI\'rIy pIqaD:n:nolink} fonte: {Quvar:n:name,nolink} '
          '(Lieven L. Litaer)\n'
          '{pIqaD qolqoS:n:nolink} fonte: Daniel Dadap\n\n'
          'Agradecimentos especiais a Marc Okrand ({marq \'oqranD:n:name}) por '
          'criar a Língua Klingon.'          
    }
  };
}
