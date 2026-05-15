import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart'; // Dartin testikirjasto
import 'package:wikipedia/src/model/article.dart'; // Article-malli
import 'package:wikipedia/src/model/search_results.dart'; // SearchResults-malli
import 'package:wikipedia/src/model/summary.dart'; // Summary-malli

// Testissä käytettävien JSON-tiedostojen polut
const String dartLangSummaryJson = './test/test_data/dart_lang_summary.json';
const String catExtractJson = './test/test_data/cat_extract.json';
const String openSearchResponse = './test/test_data/open_search_response.json';

void main() {
  // Ryhmitellään kaikki Wikipedia API:n JSON-testit samaan testiryhmään
  group('deserialize example JSON responses from wikipedia API', () {
    // Testaa, että Summary-malli osaa lukea Wikipedia summary JSON -datan
    test('deserialize Dart Programming Language page summary example data from '
        'json file into a Summary object', () async {
      final String pageSummaryInput = await File(
        dartLangSummaryJson,
      ).readAsString();

      final Map<String, Object?> pageSummaryMap =
          jsonDecode(pageSummaryInput) as Map<String, Object?>;

      final Summary summary = Summary.fromJson(pageSummaryMap);

      expect(summary.titles.canonical, 'Dart_(programming_language)');
    });

    // Testaa, että Article-malli osaa lukea artikkeli-JSON-datan
    test('deserialize Cat article example data from json file into '
        'an Article object', () async {
      final String articleJson = await File(catExtractJson).readAsString();

      final Map<String, Object?> articleMap =
          jsonDecode(articleJson) as Map<String, Object?>;

      final List<Article> articles = Article.listFromJson(articleMap);

      expect(articles.first.title.toLowerCase(), 'cat');
    });

    // Testaa, että SearchResults-malli osaa lukea hakutulos-JSON-datan
    test('deserialize Open Search results example data from json file '
        'into a SearchResults object', () async {
      final String resultsString = await File(
        openSearchResponse,
      ).readAsString();

      final List<Object?> resultsAsList =
          jsonDecode(resultsString) as List<Object?>;

      final SearchResults results = SearchResults.fromJson(resultsAsList);

      expect(results.results.length, greaterThan(1));
    });
  });
}
