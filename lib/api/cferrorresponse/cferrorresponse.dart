class CFErrorResponse {

  String? _status;
  String? _message;
  String? _code;
  String? _type;

  CFErrorResponse(String? status, String? message, String? code, String? type) {
    _status = status;
    _code = code;
    _type = type;
    _message = message;
  }

  String? getStatus() {
    return _status;
  }

  String? getMessage() {
    return _message;
  }

  String? getCode() {
    return _code;
  }

  String? getType() {
    return _type;
  }

}