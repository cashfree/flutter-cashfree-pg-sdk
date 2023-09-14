class CFCardListener {

  int? _numberOfCharacters;
  String? _message;
  String? _type;
  dynamic _meta_data;

  CFCardListener(int? numberOfCharacters, String? message, String? type, dynamic meta_data) {
    _numberOfCharacters = numberOfCharacters;
    _type = type;
    _message = message;
    _meta_data = meta_data;
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

  dynamic getMetaData() {
    return _meta_data;
  }

}