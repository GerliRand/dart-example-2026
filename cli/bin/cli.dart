import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:command_runner/command_runner.dart';

const version = '0.0.1';

// main is now async and awaits the runner
void main(List<String> arguments) async {
  var runner = CommandRunner(); // Create an instance of your new CommandRunner
  await runner.run(arguments); // Call its run method, awaiting its Future<void>
}

// ? - tietotyyppi on joko lista tai null
void searchWikipedia(List<String>? arguments) async {
  // final - lisätään kerran muuttuja jota ei pysty myöhemmin muutamaan
  final String articleTitle;

  // jos arguments on null tai tyhjä, silloin kysytään title ja tulostetaan se
  if (arguments == null || arguments.isEmpty) {
    print('Please provide an article title: ');

    final inputFromStdin = stdin.readLineSync(); // luetaan teksti
    if (inputFromStdin == null || inputFromStdin.isEmpty) {
      print('No article title provided. Exiting');
      return; // jos ei ole tekstiä niin lopetetaan
    }

    articleTitle = inputFromStdin;
  } else {
    articleTitle = arguments.join(' ');
  }
  print('Looking up articles about "$articleTitle". Please wait...');
  // Kutsu API:a ja odota tulosta
  var articleContent = await getWikipediaArticle(articleTitle);
  print(articleContent);
}

void printUsage() {
  print(
    "The following commands are valid: 'help', 'version', 'wikipedia <ARTICLE-TITLE>'",
  );
}

Future<String> getWikipediaArticle(String articleTitle) async {
  final url = Uri.https(
    'en.wikipedia.org', // Wikipedia API domain
    '/api/rest_v1/page/summary/$articleTitle', // API path for article summary
  );

  final response = await http.get(url); // Make the HTTP request

  if (response.statusCode == 200) {
    return response.body; // Return the response body if successful
  }
  // Return an error message if the request failed
  return 'Error: Failed to fetch article "$articleTitle". Status code: ${response.statusCode}';
}
