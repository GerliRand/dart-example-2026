import 'dart:collection';
import 'dart:io'; // Tarvitaan Platform-luokkaa varten
import 'arguments.dart'; // Tuodaan Argument-, Command- ja ArgResults-luokat käyttöön

class CommandRunner {
  // Tallentaa komennot Map-rakenteeseen: komennon nimi -> Command-olio
  final Map<String, Command> _commands = <String, Command>{};

  // Palauttaa komennot niin, ettei niitä voi muokata luokan ulkopuolelta
  UnmodifiableSetView<Command> get commands =>
      UnmodifiableSetView<Command>(<Command>{..._commands.values});

  // Käynnistää komentorivisovelluksen logiikan
  Future<void> run(List<String> input) async {
    // Parsitaan käyttäjän antamat komentoriviargumentit
    final ArgResults results = parse(input);
    // Jos komento löytyy, suoritetaan sen run-metodi
    if (results.command != null) {
      Object? output = await results.command!.run(results);
      print(output.toString()); // Tulostetaan komennon palauttama tulos
    }
  }

  // Lisää uuden komennon CommandRunneriin
  void addCommand(Command command) {
    _commands[command.name] = command;
    command.runner =
        this; // Annetaan komennolle viittaus tähän CommandRunneriin
  }

  // Käsittelee käyttäjän antamat komentoriviargumentit
  ArgResults parse(List<String> input) {
    var results = ArgResults();
    // Ensimmäinen argumentti tulkitaan komennon nimeksi
    results.command = _commands[input.first];
    return results;
  }

  String get usage {
    // Haetaan ajettavan tiedoston nimi
    final exeFile = Platform.script.path.split('/').last;
    // Palautetaan käyttöohje tekstinä
    return 'Usage: dart bin/$exeFile <command> [commandArg?] [...options?]';
  }
}
