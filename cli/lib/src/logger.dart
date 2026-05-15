import 'dart:io';
import 'package:logging/logging.dart';

// Luo loggerin, joka kirjoittaa lokiviestit tiedostoon
Logger initFileLogger(String name) {
  // Mahdollistaa myös child loggerien lokiviestien käsittelyn
  hierarchicalLoggingEnabled = true;

  // Luodaan loggeri annetulla nimellä
  final logger = Logger(name);
  // Haetaan nykyinen päivämäärä lokitiedoston nimeä varten
  final now = DateTime.now();

  // Haetaan käynnissä olevan scriptin sijainti
  final scriptFile = File(Platform.script.toFilePath());
  // Määritetään projektikansio scriptin sijainnin perusteella
  final projectDir = scriptFile.parent.parent.path;

  // Luodaan logs-kansio projektikansioon, jos sitä ei ole vielä olemassa
  final dir = Directory('$projectDir/logs');
  if (!dir.existsSync()) dir.createSync();

  // Luodaan lokitiedosto, jonka nimessä on päivämäärä ja loggerin nimi
  final logFile = File(
    '${dir.path}/${now.year}_${now.month}_${now.day}_$name.txt',
  );

  // Asetetaan loggerin tasoksi ALL, jotta kaikki lokiviestit tallennetaan
  logger.level = Level.ALL;

  // Kuunnellaan loggerin viestejä ja kirjoitetaan ne lokitiedostoon
  logger.onRecord.listen((record) {
    // Muodostetaan lokiviestin muoto: aika, loggerin nimi, taso ja viesti
    final msg =
        '[${record.time} - ${record.loggerName}] ${record.level.name}: ${record.message}';
    // Lisätään lokiviesti tiedoston loppuun
    logFile.writeAsStringSync('$msg \n', mode: FileMode.append);
  });

  return logger; // Palautetaan valmis loggeri käyttöön
}
