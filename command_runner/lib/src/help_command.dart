import 'dart:async';
import 'arguments.dart'; // Tuodaan Command- ja ArgResults-luokat käyttöön
import 'console.dart';
import 'exceptions.dart';

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
    // StringBufferia käytetään pidemmän tekstin rakentamiseen tehokkaasti
    final buffer = StringBuffer();

    // Lisätään yleinen käyttöohje ja käytetään titleText-tyyliä
    buffer.writeln(runner.usage.titleText);

    // Jos käyttäjä antaa --verbose tai -v, tulostetaan tarkat tiedot kaikista komennoista
    if (args.flag('verbose')) {
      for (var cmd in runner.commands) {
        buffer.write(_renderCommandVerbose(cmd));
      }
      return buffer.toString();
    }

    // Jos käyttäjä antaa --command tai -c, näytetään vain valitun komennon tarkka ohje
    if (args.hasOption('command')) {
      var (:option, :input) = args.getOption('command');

      // Etsitään komento käyttäjän antaman nimen perusteella
      var cmd = runner.commands.firstWhere(
        (command) => command.name == input,
        orElse: () {
          // Jos komentoa ei löydy, heitetään oma virhe
          throw ArgumentException(
            'Input ${args.commandArg} is not a known command.',
          );
        },
      );
      return _renderCommandVerbose(cmd);
    }
    // Jos verbose- tai command-optionia ei annettu, tulostetaan lyhyt lista komennoista
    for (var command in runner.commands) {
      buffer.writeln(command.usage);
    }

    return buffer.toString();
  }

  // Apumetodi, joka muodostaa yksityiskohtaisen ohjetekstin yhdelle komennolle
  String _renderCommandVerbose(Command cmd) {
    final indent = ' ' * 10; // Sisennys
    final buffer = StringBuffer();

    // Tulostetaan komennon nimi ja kuvaus värillisellä tyylillä
    buffer.writeln(cmd.usage.instructionText);
    // Tulostetaan komennon tarkempi ohje
    buffer.writeln('$indent ${cmd.help}');

    // Jos komento vaatii argumentin, näytetään argumentin tiedot
    if (cmd.valueHelp != null) {
      buffer.writeln(
        '$indent [Argument] Required? ${cmd.requiresArgument}, Type: ${cmd.valueHelp}, Default: ${cmd.defaultValue ?? 'none'}',
      );
    }
    // Tulostetaan komennon optiot
    buffer.writeln('$indent Options:');

    for (var option in cmd.options) {
      buffer.writeln('$indent ${option.usage}');
    }
    return buffer.toString();
  }
}
