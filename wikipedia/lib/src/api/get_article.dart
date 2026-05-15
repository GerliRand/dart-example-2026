import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../model/article.dart'; // Article-malli Wikipedia-artikkelille

// Hakee Wikipedia-artikkelin otsikon perusteella
Future<List<Article>> getArticleByTitle(String title) async {
  final http.Client client = http.Client(); // Luodaan HTTP-client
  try {
    // Luodaan Wikipedia API:n URL ja query-parametrit
    final Uri url = Uri.https(
      'en.wikipedia.org',
      '/w/api.php',
      <String, Object?>{
        'action': 'query', // Haetaan dataa query-toiminnolla
        'format': 'json', // Pyydetään vastaus JSON-muodossa
        'titles': title.trim(), // Käyttäjän otsikko ilman yli. välilyöntejä
        'prop': 'extracts', // Pyydetään artikkelin tekstisisältö
        'explaintext': '', // Palautetaan teksti ilman HTML-muotoilua
      },
    );
    // Lähetetään GET-pyyntö Wikipedia API:lle
    final http.Response response = await client.get(url);

    // Jos pyyntö onnistui, käsitellään vastaus
    if (response.statusCode == 200) {
      final Map<String, Object?> jsonData =
          jsonDecode(response.body) as Map<String, Object?>;

      // Muutetaan JSON-data Article-olioiden listaksi
      return Article.listFromJson(jsonData);
    } else {
      // Jos API palauttaa virheen, heitetään HttpException
      throw HttpException(
        '[ApiClient.getArticleByTitle] '
        'statusCode=${response.statusCode}, '
        'body=${response.body}',
      );
    }
  } on FormatException {
    // Jos JSON-vastausta ei voida lukea oikein, virhe heitetään eteenpäin
    rethrow;
  } finally {
    client.close(); // Suljetaan client
  }
}
