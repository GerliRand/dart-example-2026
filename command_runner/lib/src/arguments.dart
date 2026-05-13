import 'dart:async';
import 'dart:collection'; // Tarvitaan UnmodifiableSetView-listaa varten
import '../command_runner.dart'; // Tuodaan CommandRunner käyttöön

// Määrittelee vaihtoehdon tyypin: flag = kyllä/ei, option = arvoa tarvitseva valinta
enum OptionType { flag, option }

// Abstrakti perusluokka kaikille argumenteille
abstract class Argument {
  String get name;
  String? get help;
  Object? get defaultValue;
  String? get valueHelp;
  String get usage;
}

// Option-luokka kuvaa komentorivillä käytettävää valintaa
class Option extends Argument {
  Option(
    this.name, {
    required this.type,
    this.help,
    this.abbr,
    this.defaultValue,
    this.valueHelp,
  });

  @override
  final String name; // Option nimi, esim. verbose
  final OptionType type; // Onko kyseessä flag vai option

  @override
  final String? help; // Selitys option käytöstä
  final String? abbr; // Lyhyt muoto, esim. -v

  @override
  final Object? defaultValue; // Oletusarvo

  @override
  final String? valueHelp; // Ohje arvon muodolle

  @override
  String get usage {
    // Jos lyhenne on annettu, näytetään sekä lyhyt että pitkä muoto
    if (abbr != null) {
      return '-$abbr,--$name: $help';
    }
    // Muuten näytetään vain pitkä muoto
    return '--$name: $help';
  }
}

// Abstrakti Command-luokka toimii pohjana eri komennoille
abstract class Command extends Argument {
  @override
  String get name; // Komennon nimi

  String get description; // Komennon kuvaus

  bool get requiresArgument => false; // Tarvitseeko komento argumentin

  late CommandRunner runner; // Viittaus CommandRunner-luokkaan

  @override
  String? help; // Komennon ohjeteksti

  @override
  String? defaultValue; // Oletusarvo

  @override
  String? valueHelp; // Ohje arvon muodolle

  final List<Option> _options = []; // Komennon sisäinen option-lista

  // Palauttaa optiot niin, ettei niitä voi muokata ulkopuolelta
  UnmodifiableSetView<Option> get options =>
      UnmodifiableSetView(_options.toSet());

  // Lisää boolean-tyyppisen option eli flagin
  void addFlag(String name, {String? help, String? abbr, String? valueHelp}) {
    _options.add(
      Option(
        name,
        help: help,
        abbr: abbr,
        defaultValue: false, // Flagin oletusarvo on false
        valueHelp: valueHelp,
        type: OptionType.flag,
      ),
    );
  }

  // Lisää option, joka ottaa vastaan arvon
  void addOption(
    String name, {
    String? help,
    String? abbr,
    String? defaultValue,
    String? valueHelp,
  }) {
    _options.add(
      Option(
        name,
        help: help,
        abbr: abbr,
        defaultValue: defaultValue,
        valueHelp: valueHelp,
        type: OptionType.option,
      ),
    );
  }

  // Jokaisella komennolla pitää olla oma run-metodi
  FutureOr<Object?> run(ArgResults args);

  @override
  String get usage {
    return '$name:  $description'; // Palauttaa komennon käyttöohjeen
  }
}

// Luokka, johon tallennetaan komentorivin käsittelyn tulokset
class ArgResults {
  Command? command; // Valittu komento
  String? commandArg; // Komennolle annettu argumentti
  Map<Option, Object?> options = {}; // Käyttäjän antamat optiot ja niiden arvot

  // Palauttaa true, jos annettu flag löytyy ja se on käytössä
  bool flag(String name) {
    // Käydään läpi vain flag-tyyppiset optiot
    for (var option in options.keys.where(
      (option) => option.type == OptionType.flag,
    )) {
      if (option.name == name) {
        return options[option] as bool;
      }
    }
    return false;
  }

  // Tarkistaa, löytyykö tietyn niminen option
  bool hasOption(String name) {
    return options.keys.any((option) => option.name == name);
  }

  // Hakee option joko nimen tai lyhenteen perusteella
  ({Option option, Object? input}) getOption(String name) {
    var mapEntry = options.entries.firstWhere(
      (entry) => entry.key.name == name || entry.key.abbr == name,
    );

    // Palauttaa sekä optionin että siihen annetun arvon
    return (option: mapEntry.key, input: mapEntry.value);
  }
}
