import 'dart:async';
import 'package:command_runner/command_runner.dart'; // Tuodaan oma command_runner-paketti käyttöön

// PrettyEcho perii Command-luokan
class PrettyEcho extends Command {
  PrettyEcho() {
    // Lisätään flagi: jos käyttäjä antaa -b tai --blue-only
    addFlag(
      'blue-only',
      abbr: 'b',
      help: 'When true, the echoed text will all be blue.',
    );
  }

  @override
  String get name => 'echo';

  @override
  bool get requiresArgument => true; // Komento tarvitsee argumentin

  @override
  String get description => 'Print input, but colorful.'; // Lyhyt kuvaus komennosta

  @override
  String? get help =>
      'echos a String provided as an argument with ANSI coloring,'; // Tarkempi ohjeteksti

  @override
  String? get valueHelp => 'STRING';

  @override
  FutureOr<String> run(ArgResults arg) {
    // Tarkistetaan, että käyttäjä antoi tekstin komennolle
    if (arg.commandArg == null) {
      throw ArgumentException(
        'This argument requires one positional argument',
        name,
      );
    }
    // Lista värjätyille sanoille
    List<String> prettyWords = [];

    // Jaetaan käyttäjän antama teksti sanoihin
    var words = arg.commandArg!.split(' ');

    // Käydään sanat läpi yksi kerrallaan
    for (var i = 0; i < words.length; i++) {
      var word = words[i];
      // Vaihdetaan tekstin tyyliä sanan järjestysnumeron perusteella
      switch (i % 3) {
        case 0:
          prettyWords.add(word.titleText);
        case 1:
          prettyWords.add(word.instructionText);
        case 2:
          prettyWords.add(word.errorText);
      }
    }
    // Yhdistetään sanat takaisin yhdeksi tekstiksi
    return prettyWords.join(' ');
  }
}

void main(List<String> arguments) {
  // Luodaan CommandRunner ja lisätään PrettyEcho-komento
  final runner = CommandRunner()..addCommand(PrettyEcho());

  // Käynnistetään sovellus käyttäjän antamilla argumenteilla
  runner.run(arguments);
}
