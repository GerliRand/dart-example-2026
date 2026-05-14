// Tuodaan command_runner-paketin luokat käyttöön
import 'package:command_runner/command_runner.dart';

const version = '0.0.1'; // Vakio muuttuja sovelluksen versiolle

void main(List<String> arguments) {
  // Luodaan uusi CommandRunner-olio ja määritellään virhekäsittely
  var commandRunner = CommandRunner(
    onError: (Object error) {
      // Jos kyseessä on vakavampi Dart-virhe, heitetään se uudelleen.
      if (error is Error) {
        throw error;
      }
      // Jos kyseessä on tavallinen poikkeus, tulostetaan se käyttäjälle.
      if (error is Exception) {
        print(error);
      }
    },
  )..addCommand(HelpCommand());

  // Käynnistetään sovellus käyttäjän antamilla argumenteilla
  commandRunner.run(arguments);
}
