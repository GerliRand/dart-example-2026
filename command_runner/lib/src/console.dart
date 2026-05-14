import 'dart:io';

// ANSI escape -merkki, jota käytetään terminaalin värien muuttamiseen
const String ansiEscapeLiteral = '\x1B';

// Tulostaa tekstin riveittäin pienellä viiveellä
// [duration] määrittää, kuinka monta millisekuntia on tulostettujen rivien välillä
Future<void> write(String text, {int duration = 50}) async {
  final List<String> lines = text.split('\n');
  for (final String l in lines) {
    await _delayedPrint('$l \n', duration: duration);
  }
}

// Tulostaa yhden rivin viiveellä
Future<void> _delayedPrint(String text, {int duration = 0}) async {
  return Future<void>.delayed(
    Duration(milliseconds: duration),
    () => stdout.write(text),
  );
}
// RGB-värit, joita käytetään syötteen tyylittelyyn
// Kaikki värit Dartin brändityylioppaasta

// Määrittelee terminaalissa käytettävät RGB-värit
enum ConsoleColor {
  /// Sky blue - #b8eafe
  lightBlue(184, 234, 254),

  // Accent colors from Dart's brand guidelines
  // Warm red - #F25D50
  red(242, 93, 80),

  // Light yellow - #F9F8C4
  yellow(249, 248, 196),

  // Light grey, good for text, #F8F9FA
  grey(240, 240, 240),

  white(255, 255, 255);

  const ConsoleColor(this.r, this.g, this.b);

  final int r; // Punaisen määrä
  final int g; // Vihreän määrä
  final int b; // Sinisen määrä

  // Asettaa tekstin värin terminaalissa
  String get enableForeground => '$ansiEscapeLiteral[38;2;$r;$g;${b}m';

  // Asettaa taustavärin terminaalissa
  String get enableBackground => '$ansiEscapeLiteral[48;2;$r;$g;${b}m';

  // Palauta tekstin ja taustan värit
  static String get reset => '$ansiEscapeLiteral[0m';

  // Asettaa syötteen tekstin värin
  String applyForeground(String text) {
    return '$ansiEscapeLiteral[38;2;$r;$g;${b}m$text$reset';
  }

  // Lisää annetulle tekstille taustavärin
  String applyBackground(String text) {
    return '$ansiEscapeLiteral[48;2;$r;$g;${b}m$text$ansiEscapeLiteral[0m';
  }
}

// Laajentaa String-luokkaa omilla tekstityyleillä
extension TextRenderUtils on String {
  String get errorText => ConsoleColor.red.applyForeground(this);
  String get instructionText => ConsoleColor.yellow.applyForeground(this);
  String get titleText => ConsoleColor.lightBlue.applyForeground(this);

  // Jakaa pitkän tekstin usealle riville annetun merkkimäärän mukaan
  List<String> splitLinesByLength(int length) {
    final List<String> words = split(' ');
    final List<String> output = <String>[];
    final StringBuffer strBuffer = StringBuffer();

    for (int i = 0; i < words.length; i++) {
      final String word = words[i];

      // Lisätään sana nykyiselle riville, jos se mahtuu
      if (strBuffer.length + word.length <= length) {
        strBuffer.write(word.trim());

        if (strBuffer.length + 1 <= length) {
          strBuffer.write(' ');
        }
      }
      // Jos seuraava sana ei mahdu riville, aloitetaan seuraava rivi
      if (i + 1 < words.length &&
          words[i + 1].length + strBuffer.length + 1 > length) {
        output.add(strBuffer.toString().trim());
        strBuffer.clear();
      }
    }
    // Lisätään viimeinen jäljellä oleva rivi
    output.add(strBuffer.toString().trim());
    return output;
  }
}
