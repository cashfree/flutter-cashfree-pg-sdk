/// Represents an error or failure response from the Cashfree payment gateway.
///
/// Returned via the `onError` callback registered in [CFPaymentGatewayService.setCallback].
class CFErrorResponse {

  String? _status;
  String? _message;
  String? _code;
  String? _type;

  /// Creates a [CFErrorResponse] with the given [status], [message], [code], and [type].
  CFErrorResponse(String? status, String? message, String? code, String? type) {
    _status = status;
    _code = code;
    _type = type;
    _message = message;
  }

  /// Returns the status string (e.g., `"FAILED"`).
  String? getStatus() {
    return _status;
  }

  /// Returns the human-readable error message.
  String? getMessage() {
    return _message;
  }

  /// Returns the error code (e.g., `"invalid_request"`).
  String? getCode() {
    return _code;
  }

  /// Returns the error type (e.g., `"invalid_request"`).
  String? getType() {
    return _type;
  }

}
