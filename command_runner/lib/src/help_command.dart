import 'dart:async';
import 'arguments.dart'; // Tuodaan Command- ja ArgResults-luokat käyttöön

// HelpCommand tulostaa ohjelman ja komentojen käyttöohjeet.

class HelpCommand extends Command {
  HelpCommand() {
    // Lisää verbose-flagin, jolla voidaan myöhemmin näyttää tarkempi ohjeistus
    addFlag(
      'verbose',
      abbr: 'v',
      help: 'When true, this command will print each command and its options.',
    );
    // Lisää command-option, jolla voidaan myöhemmin pyytää tietyn komennon ohje
    addOption(
      'command',
      abbr: 'c',
      help:
          "When a command is passed as an argument, prints only that command's verbose usage.",
    );
  }
  @override
  String get name => 'help'; // Komennon nimi

  @override
  String get description => 'Prints usage information to the command line.'; // Lyhyt kuvaus

  @override
  String? get help => 'Prints this usage information'; // Ohjeteksti

  @override
  FutureOr<Object?> run(ArgResults args) async {
    // Aloitetaan ohjelman yleisestä käyttöohjeesta
    var usage = runner.usage;
    // Käydään läpi kaikki CommandRunneriin lisätyt komennot
    for (var command in runner.commands) {
      // Lisätään jokaisen komennon usage-teksti käyttöohjeeseen
      usage += '\n ${command.usage}';
    }

    return usage; // Palautetaan valmis käyttöohje tulostettavaksi
  }
}
