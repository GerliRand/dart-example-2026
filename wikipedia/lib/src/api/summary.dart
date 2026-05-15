import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http; // HTTP-pyynnöt
import '../model/summary.dart'; // Summary-malli Wikipedia API:n vastaukselle

// Hakee satunnaisen Wikipedia-artikkelin yhteenvedon
Future<Summary> getRandomArticleSummary() async {
  final http.Client client = http.Client(); // Luodaan HTTP-client
  try {
    // Luodaan URL satunnaisen artikkelin summary-endpointtiin
    final Uri url = Uri.https(
      'en.wikipedia.org',
      '/api/rest_v1/page/random/summary',
    );
    // Lähetetään GET-pyyntö Wikipedia API:lle
    final http.Response response = await client.get(url);

    // Jos pyyntö onnistui, käsitellään vastaus
    if (response.statusCode == 200) {
      final Map<String, Object?> jsonData =
          jsonDecode(response.body) as Map<String, Object?>;
      return Summary.fromJson(jsonData); // Luodaan Summary-olio JSON-datasta
    } else {
      // Jos API palauttaa virheen, heitetään HttpException
      throw HttpException(
        '[WikipediaDart.getRandomArticle] '
        'statusCode=${response.statusCode}, body=${response.body}',
      );
    }
  } on FormatException {
    // Jos JSON-muoto on virheellinen, virhe heitetään eteenpäin
    rethrow;
  } finally {
    client.close(); // Suljetaan client aina lopuksi
  }
}

// Hakee Wikipedia-artikkelin yhteenvedon otsikon perusteella
Future<Summary> getArticleSummaryByTitle(String articleTitle) async {
  final http.Client client = http.Client(); // Luodaan HTTP-client
  try {
    // Luodaan URL artikkelin otsikon perusteella
    final Uri url = Uri.https(
      'en.wikipedia.org',
      '/api/rest_v1/page/summary/$articleTitle',
    );
    // Lähetetään GET-pyyntö Wikipedia API:lle
    final http.Response response = await client.get(url);

    // Jos pyyntö onnistui, käsitellään vastaus
    if (response.statusCode == 200) {
      final Map<String, Object?> jsonData =
          jsonDecode(response.body) as Map<String, Object?>;
      return Summary.fromJson(jsonData); // Palautetaan Summary-olio
    } else {
      // Jos API palauttaa virheen, heitetään HttpException
      throw HttpException(
        '[WikipediaDart.getArticleSummary] '
        'statusCode=${response.statusCode}, body=${response.body}',
      );
    }
  } on FormatException {
    // Jos JSON-vastausta ei voida lukea oikein, virhe heitetään eteenpäin
    rethrow;
  } finally {
    client.close(); // Suljetaan client
  }
}
