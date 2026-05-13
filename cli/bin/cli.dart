import 'dart:io';

const version = '0.0.1';

void main(List<String> arguments) {
  if (arguments.isEmpty || arguments.first == 'help') {
    printUsage();
  }
  // jos ensimmäinen argumentti listassa on version, silloin tulostetaan ...
  // dart run .\bin\cli.dart version
  else if (arguments.first == 'version') {
    print('Current version is: $version');
  } else if (arguments.first == 'search') {
    // jos listan (item) määrä on suurempi kuin 1, silloin tehdään sublist
    // muuten asetetaan null inputArgs:in
    final inputArgs = arguments.length > 1 ? arguments.sublist(1) : null;
    searchWikipedia(inputArgs);
  } else {
    printUsage();
  }
}

// ? - tietotyyppi on joko lista tai null
void searchWikipedia(List<String>? arguments) {
  // final - lisätään kerran muuttuja jota ei pysty myöhemmin muutamaan
  final String articleTitle;

  // jos arguments on null tai tyhjä, silloin kysytään title ja tulostetaan se
  if (arguments == null || arguments.isEmpty) {
    print('Please provide an article title: ');
    articleTitle = stdin.readLineSync() ?? '';
  } else {
    articleTitle = arguments.join(' ');
  }
  print('Current article title: $articleTitle');
}

void printUsage() {
  print(
    "The following commands are valid: 'help', 'version', 'search <ARTICLE-TITLE>'",
  );
}
