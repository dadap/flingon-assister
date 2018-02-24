import 'package:xml/xml.dart' as xml;
import 'package:flutter/services.dart';
import 'dart:async';

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
}

class WordDatabaseEntry {
  WordDatabaseEntry.fromXmlNode(xml.XmlNode node) {
    entryName = innerText(ofNode: node, withName: 'entry_name');
    definition = innerText(ofNode: node, withName: 'definition');
  }

  String entryName;
  String definition;

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
}