// Tuodaan command_runner-paketin luokat käyttöön
import 'package:command_runner/command_runner.dart';

const version = '0.0.1'; // Vakio muuttuja sovelluksen versiolle

void main(List<String> arguments) {
  // Luodaan uusi CommandRunner-olio
  // ..addCommand() lisää heti HelpCommand-komennon runneriin
  var commandRunner = CommandRunner()..addCommand(HelpCommand());

  // Käynnistetään sovellus käyttäjän antamilla argumenteilla
  commandRunner.run(arguments);
}
