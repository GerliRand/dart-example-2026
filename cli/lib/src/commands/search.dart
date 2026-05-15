import 'dart:async';
import 'dart:io';
import 'package:command_runner/command_runner.dart';
import 'package:logging/logging.dart';
import 'package:wikipedia/wikipedia.dart';

// Komento, jolla haetaan Wikipedia-artikkeleita hakusanalla
class SearchCommand extends Command {
  SearchCommand({required this.logger}) {
    // Lisätään flagi, jolla voidaan näyttää ensimmäisen hakutuloksen yhteenveto
    addFlag(
      'im-feeling-lucky',
      help:
          'If true, prints the summary of the top article that the search returns.',
    );
  }

  final Logger logger; // Logger virheiden tallentamiseen

  @override
  String get description => 'Search for Wikipedia articles.';

  @override
  bool get requiresArgument => true; // Komento tarvitsee hakusanan

  @override
  String get name => 'search'; // Komennon nimi

  @override
  String get valueHelp => 'STRING'; // Näyttää, että komento odottaa tekstiä

  @override
  String get help =>
      'Prints a list of links to Wikipedia articles that match the given term.';

  @override
  FutureOr<String> run(ArgResults args) async {
    // Tarkistetaan, että käyttäjä antoi hakusanan
    if (requiresArgument &&
        (args.commandArg == null || args.commandArg!.isEmpty)) {
      return 'Please include a search term';
    }

    final buffer = StringBuffer('Search results:');
    try {
      // Haetaan Wikipedia-hakutulokset annetulla hakusanalla
      final SearchResults results = await search(args.commandArg!);

      // Jos --im-feeling-lucky on käytössä, haetaan ensimmäisen tuloksen yhteenveto
      if (args.flag('im-feeling-lucky')) {
        final title = results.results.first.title;
        final Summary article = await getArticleSummaryByTitle(title);
        buffer.writeln('Lucky you!');
        buffer.writeln(article.titles.normalized.titleText);

        // Lisätään kuvaus, jos sellainen löytyy
        if (article.description != null) {
          buffer.writeln(article.description);
        }

        buffer.writeln(article.extract);
        buffer.writeln();
        buffer.writeln('All results:');
      }

      // Lisätään kaikki hakutulokset tulosteeseen
      for (var result in results.results) {
        buffer.writeln('${result.title} - ${result.url}');
      }
      return buffer.toString();
    } on HttpException catch (e) {
      logger
        ..warning(e.message)
        ..warning(e.uri)
        ..info(usage);

      return e.message;
    } on FormatException catch (e) {
      // Kirjataan JSON- tai muotoiluvirheet lokiin
      logger
        ..warning(e.message)
        ..warning(e.source)
        ..info(usage);

      return e.message;
    }
  }
}
