import 'dart:async'; // Tarvitaan FutureOr-tyyppiä varten
import 'dart:collection';
import 'dart:io'; // Tarvitaan Platform-luokkaa varten
import 'arguments.dart'; // Tuodaan Argument-, Command- ja ArgResults-luokat käyttöön
import 'exceptions.dart'; // Tuodaan oma ArgumentException-luokka käyttöön

class CommandRunner {
  // Lisätty konstruktori, joka ottaa vastaan vapaaehtoisen virheenkäsittelyfunktion
  CommandRunner({this.onError});
  // Tallentaa komennot Map-rakenteeseen: komennon nimi -> Command-olio
  final Map<String, Command> _commands = <String, Command>{};

  // Palauttaa komennot niin, ettei niitä voi muokata luokan ulkopuolelta
  UnmodifiableSetView<Command> get commands =>
      UnmodifiableSetView<Command>(<Command>{..._commands.values});

  // Lisätty onError-property
  // Tämän avulla voidaan määrittää, miten virheet käsitellään sovelluksessa
  FutureOr<void> Function(Object)? onError;

  // Käynnistää komentorivisovelluksen logiikan
  Future<void> run(List<String> input) async {
    // try - catch lohko
    try {
      // Parsitaan käyttäjän antamat komentoriviargumentit
      final ArgResults results = parse(input);
      // Jos komento löytyy, suoritetaan sen run-metodi
      if (results.command != null) {
        Object? output = await results.command!.run(results);
        print(output.toString()); // Tulostetaan komennon palauttama tulos
      }
    } on Exception catch (exception) {
      // Jos onError on määritelty, käytetään sitä virheen käsittelyyn
      if (onError != null) {
        onError!(exception);
      } else {
        // Jos omaa virheenkäsittelyä ei ole määritelty, heitetään virhe uudelleen
        rethrow;
      }
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
    ArgResults results = ArgResults();
    // Jos käyttäjä ei anna argumentteja, palautetaan tyhjä tulos
    if (input.isEmpty) return results;

    // Lisätty validointi: tarkistetaan, onko ensimmäinen sana tunnettu komento
    if (_commands.containsKey(input.first)) {
      results.command = _commands[input.first];
      input = input.sublist(1); // Poistetaan komento input-listasta
    } else {
      // Jos komentoa ei tunneta, heitetään oma ArgumentException
      throw ArgumentException(
        'The first word of input must be a command.',
        null,
        input.first,
      );
    }

    // Lisätty validointi: käyttäjä ei saa antaa useampaa komentoa samaan aikaan
    if (results.command != null &&
        input.isNotEmpty &&
        _commands.containsKey(input.first)) {
      throw ArgumentException(
        'Input can only contain one command. Got ${input.first} and ${results.command!.name}',
        null,
        input.first,
      );
    }

    // Lisätty optionien ja flagien käsittely
    Map<Option, Object?> inputOptions = {};
    int i = 0;
    while (i < input.length) {
      // Jos argumentti alkaa viivalla, se tulkitaan optioniksi tai flagiksi
      if (input[i].startsWith('-')) {
        var base = _removeDash(input[i]);

        // Tarkistetaan, löytyykö annettu option kyseisen komennon option-listasta
        var option = results.command!.options.firstWhere(
          (option) => option.name == base || option.abbr == base,
          orElse: () {
            // Jos optionia ei löydy, heitetään virhe
            throw ArgumentException(
              'Unknown option ${input[i]}',
              results.command!.name,
              input[i],
            );
          },
        );

        // Jos kyseessä on flag, sen arvoksi asetetaan true
        if (option.type == OptionType.flag) {
          inputOptions[option] = true;
          i++;
          continue;
        }

        // Jos kyseessä on option, sen pitää saada arvo
        if (option.type == OptionType.option) {
          // Tarkistetaan, että optionin jälkeen tulee arvo
          if (i + 1 >= input.length) {
            throw ArgumentException(
              'Option ${option.name} requires an argument',
              results.command!.name,
              option.name,
            );
          }

          // Tarkistetaan, ettei optionin arvona ole toinen option
          if (input[i + 1].startsWith('-')) {
            throw ArgumentException(
              'Option ${option.name} requires an argument, but got another option ${input[i + 1]}',
              results.command!.name,
              option.name,
            );
          }

          // Tallennetaan optionille annettu arvo
          var arg = input[i + 1];
          inputOptions[option] = arg;
          i++;
        }
      } else {
        // Jos argumentti ei ala viivalla, se tulkitaan tavalliseksi komennon argumentiksi

        // Lisätty validointi: komennolla saa olla vain yksi positional argument
        if (results.commandArg != null && results.commandArg!.isNotEmpty) {
          throw ArgumentException(
            'Commands can only have up to one argument.',
            results.command!.name,
            input[i],
          );
        }
        // Tallennetaan komennon argumentti
        results.commandArg = input[i];
      }
      i++;
    }
    // Tallennetaan löydetyt optiot tuloksiin
    results.options = inputOptions;

    return results;
  }

  // Apumetodi, joka poistaa option alusta viivat
  // "--v" -> "v" ja "-v" -> "v"
  String _removeDash(String input) {
    if (input.startsWith('--')) {
      return input.substring(2);
    }
    if (input.startsWith('-')) {
      return input.substring(1);
    }
    return input;
  }

  // Palauttaa ohjelman käyttöohjeen
  String get usage {
    // Haetaan ajettavan tiedoston nimi
    final exeFile = Platform.script.path.split('/').last;
    // Palautetaan käyttöohje tekstinä
    return 'Usage: dart bin/$exeFile <command> [commandArg?] [...options?]';
  }
}
