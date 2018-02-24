import 'package:xml/xml.dart' as xml;
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:flutter/material.dart';

class WordDatabase {
  static Future<List<WordDatabaseEntry>> getDatabase() async {
    List<WordDatabaseEntry> ret = [];

    final List<String> memSegments = [
      '00-header', '01-b', '02-ch', '03-D', '04-gh', '05-H', '06-j', '07-l',
      '08-m', '09-n', '10-ng', '11-p', '12-q', '13-Q', '14-r', '15-S', '16-t',
      '17-tlh', '18-v', '19-w', '20-y', '21-a', '22-e', '23-I', '24-o',
      '25-u', '26-suffixes', '27-extra', '28-footer'
    ];
    final memBase = 'klingon-assistant/KlingonAssistant/data/mem-';
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
      ret.add(new WordDatabaseEntry.fromXmlNode(entry));
    }

    return ret;
  }

  static List<WordDatabaseEntry> match({List<WordDatabaseEntry> db,
    String query}) {
    List<WordDatabaseEntry> ret = [];

    for (var entry in db) {
      if (query.isNotEmpty && (entry.entryName.contains(query))) {
        ret.add(entry);
      }
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

  Widget toWidget() {
    return new Column(
      children: [
        new Text('$entryName ($partOfSpeech)'),
        new Text('$definition'),
        new Text('$notes'),
      ]
    );
  }
}