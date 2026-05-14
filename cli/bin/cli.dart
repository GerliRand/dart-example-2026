// Tuodaan command_runner-paketin luokat käyttöön
import 'package:command_runner/command_runner.dart';

const version = '0.0.1'; // Vakio muuttuja sovelluksen versiolle

void main(List<String> arguments) {
  // Luodaan uusi CommandRunner-olio ja määritellään tulostus ja virhekäsittely
  var commandRunner = CommandRunner(
    // onOutput määrittää, miten komennon tuloste näytetään käyttäjälle
    onOutput: (String output) async {
      await write(output);
    },
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
