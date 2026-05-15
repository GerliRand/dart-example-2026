import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../model/search_results.dart'; // SearchResults-malli hakutuloksille

// Hakee Wikipedia-artikkeleita käyttäjän antaman hakusanan perusteella
Future<SearchResults> search(String searchTerm) async {
  final http.Client client = http.Client(); // Luodaan HTTP-client
  try {
    // Luodaan Wikipedia OpenSearch API:n URL ja query-parametrit
    final Uri url = Uri.https(
      'en.wikipedia.org',
      '/w/api.php',
      <String, Object?>{
        'action': 'opensearch', // Käytetään OpenSearch-toimintoa
        'format': 'json', // Pyydetään vastaus JSON-muodossa
        'search': searchTerm, // Hakusana
      },
    );
    // Lähetetään GET-pyyntö Wikipedia API:lle
    final http.Response response = await client.get(url);

    // Jos pyyntö onnistui, käsitellään vastaus
    if (response.statusCode == 200) {
      final List<Object?> jsonData = jsonDecode(response.body) as List<Object?>;
      return SearchResults.fromJson(
        jsonData,
      ); // Luodaan SearchResults-olio JSON-datasta
    } else {
      // Jos API palauttaa virheen, heitetään HttpException
      throw HttpException(
        '[WikimediaApiClient.getArticleByTitle] '
        'statusCode=${response.statusCode}, '
        'body=${response.body}',
      );
    }
  } on FormatException {
    rethrow;
  } finally {
    client.close(); // Suljetaan client aina lopuksi
  }
}
