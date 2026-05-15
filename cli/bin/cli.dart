import 'package:cli/cli.dart';
import 'package:command_runner/command_runner.dart';

void main(List<String> arguments) async {
  // Luodaan loggeri virheitä varten.
  // Lokit kirjoitetaan tiedostoon cli/logs-kansioon.
  final errorLogger = initFileLogger('errors');

  // Luodaan CommandRunner, joka käsittelee käyttäjän antamat komennot
  final app =
      CommandRunner(
          // onOutput määrittää, miten komennon tuloste näytetään käyttäjälle
          onOutput: (String output) async {
            await write(output);
          },
          // onError määrittää, miten virheet käsitellään
          onError: (Object error) {
            // Jos kyseessä on vakavampi Dart-virhe, kirjataan se lokiin
            // ja heitetään virhe uudelleen
            if (error is Error) {
              errorLogger.severe(
                '[Error] ${error.toString()}\n${error.stackTrace}',
              );
              throw error;
            }
            // Jos kyseessä on tavallinen poikkeus, kirjataan se warning-tasolla lokiin
            if (error is Exception) {
              errorLogger.warning(error);
            }
          },
        )
        // Lisätään help-komento käyttöohjeita varten
        ..addCommand(HelpCommand())
        // Lisätään search-komento Wikipedia-hakua varten
        // Sama loggeri annetaan komennolle, jotta se voi kirjata virheitä
        ..addCommand(SearchCommand(logger: errorLogger))
        // Lisätään article-komento artikkelin hakemista varten
        ..addCommand(GetArticleCommand(logger: errorLogger));

  // Käynnistetään sovellus käyttäjän antamilla komentoriviargumenteilla
  app.run(arguments);
}
