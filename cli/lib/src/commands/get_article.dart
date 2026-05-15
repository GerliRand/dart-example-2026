import 'dart:async';
import 'dart:io';
import 'package:command_runner/command_runner.dart'; // Command-luokka ja ArgResults käyttöön
import 'package:logging/logging.dart'; // Logger virheiden kirjaamiseen
import 'package:wikipedia/wikipedia.dart'; // Wikipedia API -funktiot ja mallit käyttöön

// Komento, jolla haetaan Wikipedia-artikkeli otsikon perusteella
class GetArticleCommand extends Command {
  GetArticleCommand({required this.logger});

  final Logger logger; // Logger virheiden tallentamiseen

  @override
  String get description => 'Read an article from Wikipedia';

  @override
  String get name => 'article'; // Komennon nimi

  @override
  String get help => 'Gets an article by exact canonical wikipedia title.';

  @override
  String get defaultValue => 'cat'; // Oletusartikkeli, jos käyttäjä ei anna otsikkoa

  @override
  String get valueHelp => 'STRING'; // Näyttää, että komento odottaa tekstiarvoa

  @override
  FutureOr<String> run(ArgResults args) async {
    try {
      // Käytetään käyttäjän antamaa otsikkoa tai oletuksena "cat"
      var title = args.commandArg ?? defaultValue;

      // Haetaan artikkeli Wikipedia API:sta
      final List<Article> articles = await getArticleByTitle(title);

      // API palauttaa listan, mutta käytetään ensimmäistä eli lähintä osumaa.
      final article = articles.first;

      // Luodaan tulostettava teksti
      final buffer = StringBuffer('\n=== ${article.title.titleText} ===\n\n');

      // Tulostetaan artikkelin tekstistä ensimmäiset 500 sanaa
      buffer.write(article.extract.split(' ').take(500).join(' '));
      return buffer.toString();
    } on HttpException catch (e) {
      // Kirjataan HTTP-virheet lokiin
      logger
        ..warning(e.message)
        ..warning(e.uri)
        ..info(usage);

      return e.message;
    } on FormatException catch (e) {
      logger
        ..warning(e.message)
        ..warning(e.source)
        ..info(usage);

      return e.message;
    }
  }
}
