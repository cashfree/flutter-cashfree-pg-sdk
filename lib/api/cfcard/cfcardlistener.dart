class CFCardListener {

  int? _numberOfCharacters;
  String? _message;
  String? _type;

  CFCardListener(int? numberOfCharacters, String? message, String? type) {
    _numberOfCharacters = numberOfCharacters;
    _type = type;
    _message = message;
  }

  int? getNumberOfCharacters() {
    return _numberOfCharacters;
  }

  String? getMessage() {
    return _message;
  }

  String? getType() {
    return _type;
  }

}