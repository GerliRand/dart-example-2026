// Oma poikkeusluokka komentoriviargumenttien virhetilanteille.
class ArgumentException extends FormatException {
  final String? command;

  final String? argumentName;

  // Annetaan virheviesti ja mahdolliset lisätiedot.
  ArgumentException(
    super.message, [
    this.command,
    this.argumentName,
    super.source,
    super.offset,
  ]);

  @override
  String toString() {
    // Määrittää, miten virhe tulostetaan käyttäjälle.
    return 'ArgumentException: $message';
  }
}
