import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfcard/cfcardvalidator.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfnetwork/CFNetworkManager.dart';
import 'dart:convert';
import '../cferrorresponse/cferrorresponse.dart';
import '../cfsession/cfsession.dart';
import 'cfcardlistener.dart';

class CFCardWidget extends StatefulWidget {

  final InputDecoration? inputDecoration;
  final TextStyle? textStyle;
  final CFSession? cfSession;
  final void Function(CFCardListener) cardListener;

  const CFCardWidget({key = Key, required this.inputDecoration, required this.textStyle, required this.cardListener, required this.cfSession}): super(key: key);

  @override
  // ignore: no_logic_in_create_state
  State<CFCardWidget> createState() => CFCardWidgetState(inputDecoration, textStyle, cardListener, cfSession!);
}

class CFCardWidgetState extends State<CFCardWidget> {

  final TextEditingController _controller = TextEditingController();
  CFSession? _cfSession;
  InputDecoration? _inputDecoration;
  void Function(CFCardListener)? _cardListener;
  TextStyle? _textStyle;
  CFCardValidator cfCardValidator = CFCardValidator();
  dynamic _tdrJson = null;
  dynamic _cardbinJson = null;
  String _first_eight_digits = "";

  Image _suffixIcon = Image.asset('packages/flutter_cashfree_pg_sdk/assets/credit-card-default.png',
    width: 30,
    height: 25,
    fit: BoxFit.fitHeight,
  );

  CFCardWidgetState(InputDecoration? inputDecoration, TextStyle? textStyle, Function(CFCardListener) cardListener, CFSession cfSession) {
    _inputDecoration = inputDecoration;
    _cardListener = cardListener;
    _textStyle = textStyle;
    _cfSession = cfSession;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: const EdgeInsets.symmetric(horizontal: 20.0),
        child: TextField(
          controller: _controller,
          keyboardType: TextInputType.number,
          style: _textStyle,
          decoration: InputDecoration(
            icon: _inputDecoration?.icon,
            iconColor: _inputDecoration?.iconColor,
            label: _inputDecoration?.label,
            labelText: _inputDecoration?.labelText,
            labelStyle: _inputDecoration?.labelStyle,
            floatingLabelStyle: _inputDecoration?.floatingLabelStyle,
            helperText: _inputDecoration?.helperText,
            helperStyle: _inputDecoration?.helperStyle,
            helperMaxLines: _inputDecoration?.helperMaxLines,
            hintText: "XXXX XXXX XXXX XXXX",
            hintStyle: _inputDecoration?.hintStyle,
            hintTextDirection: _inputDecoration?.hintTextDirection,
            hintMaxLines: 1,
            errorText: _inputDecoration?.errorText,
            errorStyle: _inputDecoration?.errorStyle,
            errorMaxLines: 1,
            floatingLabelBehavior: _inputDecoration?.floatingLabelBehavior,
            floatingLabelAlignment: _inputDecoration?.floatingLabelAlignment,
            isCollapsed: _inputDecoration?.isCollapsed ?? false,
            contentPadding: _inputDecoration?.contentPadding,
            prefixIcon: _inputDecoration?.prefixIcon,
            prefixIconConstraints: _inputDecoration?.prefixIconConstraints,
            prefix: _inputDecoration?.prefix,
            prefixText: _inputDecoration?.prefixText,
            prefixStyle: _inputDecoration?.prefixStyle,
            prefixIconColor: _inputDecoration?.prefixIconColor,
            suffixIcon: Transform.translate(
                offset: const Offset(-10.0, 0.0),
                child: _suffixIcon
            ),
            suffix: _inputDecoration?.suffix,
            suffixText: _inputDecoration?.suffixText,
            suffixStyle: _inputDecoration?.suffixStyle,
            suffixIconColor: _inputDecoration?.suffixIconColor,
            suffixIconConstraints: const BoxConstraints(minWidth: 25, minHeight: 25, maxWidth: 30, maxHeight: 25),
            counter: _inputDecoration?.counter,
            counterText: _inputDecoration?.counterText,
            counterStyle: _inputDecoration?.counterStyle,
            filled: _inputDecoration?.filled,
            fillColor: _inputDecoration?.fillColor,
            focusColor: _inputDecoration?.focusColor,
            hoverColor: _inputDecoration?.hoverColor,
            errorBorder: _inputDecoration?.errorBorder,
            focusedBorder: _inputDecoration?.focusedBorder,
            focusedErrorBorder: _inputDecoration?.focusedErrorBorder,
            disabledBorder: _inputDecoration?.disabledBorder,
            enabledBorder: _inputDecoration?.enabledBorder,
            border: _inputDecoration?.border,
            enabled: _inputDecoration!.enabled,
            semanticCounterText: _inputDecoration?.semanticCounterText,
            alignLabelWithHint: _inputDecoration?.alignLabelWithHint,
            constraints: _inputDecoration?.constraints,
          ),
          maxLines: 1,
          onChanged: _handleTextChanged,
          maxLength: 19,
        ),
    );
  }

  Future<void> _handleTextChanged(String newText) async {
    // Remove any existing spaces from the input
    var completeResponse = {};
    String textWithoutSpaces = newText.replaceAll(' ', '');

    // Add spaces after every 4 characters
    String formattedText = '';
    for (int i = 0; i < textWithoutSpaces.length; i += 4) {
      int end = i + 4;
      if (end > textWithoutSpaces.length) {
        end = textWithoutSpaces.length;
      }
      formattedText += textWithoutSpaces.substring(i, end);
      if (end != textWithoutSpaces.length) {
        formattedText += ' ';
      }
    }

    // Update the text field's content
    if (formattedText != _controller.text) {
      _controller.value = TextEditingValue(
        text: formattedText,
        selection: TextSelection.collapsed(offset: formattedText.length),
      );
    }
    if(textWithoutSpaces.length == 8) {
      _first_eight_digits = textWithoutSpaces;
      var tdrResponse = await CFNetworkManager().getTDR(_cfSession!, textWithoutSpaces);
      var cardbinResponse = await CFNetworkManager().getCardBin(_cfSession!, textWithoutSpaces);
      _tdrJson = null;
      _cardbinJson = null;
      if(tdrResponse.statusCode == 200) {
        _tdrJson = json.decode(tdrResponse.body);
        completeResponse["tdr_info"] = _tdrJson;
      }
      if(cardbinResponse.statusCode == 200) {
        _cardbinJson = jsonDecode(cardbinResponse.body);
        completeResponse["card_bin_info"] = _cardbinJson;
      }
    } else if (textWithoutSpaces.length > 8) {
      if(_first_eight_digits == textWithoutSpaces.substring(0, 8)) {
        completeResponse["tdr_info"] = _tdrJson;
        completeResponse["card_bin_info"] = _cardbinJson;
      } else {
        _first_eight_digits = textWithoutSpaces.substring(0, 8);
        var tdrResponse = await CFNetworkManager().getTDR(_cfSession!, _first_eight_digits);
        var cardbinResponse = await CFNetworkManager().getCardBin(_cfSession!, _first_eight_digits);
        _tdrJson = null;
        _cardbinJson = null;
        if(tdrResponse.statusCode == 200) {
          _tdrJson = json.decode(tdrResponse.body);
          completeResponse["tdr_info"] = _tdrJson;
        }
        if(cardbinResponse.statusCode == 200) {
          _cardbinJson = jsonDecode(cardbinResponse.body);
          completeResponse["card_bin_info"] = _cardbinJson;
        }
      }
    }
    if (textWithoutSpaces.length < 8) {
      _cardbinJson = null;
      _tdrJson = null;
    }
    if(_cardbinJson != null) {
      var scheme = _cardbinJson["scheme"] as String;
      var brand = cfCardValidator.detectCardBrand(scheme);
      switch(brand) {
        case CFCardBrand.mastercard:
          setState(() {
            _suffixIcon = Image.asset('packages/flutter_cashfree_pg_sdk/assets/mastercard.png',
              width: 30,
              height: 25,
              fit: BoxFit.fitWidth,
            );
          });
          break;
        case CFCardBrand.jcb:
          setState(() {
            _suffixIcon = Image.asset('packages/flutter_cashfree_pg_sdk/assets/jcb.png',
              width: 30,
              height: 25,
              fit: BoxFit.fitWidth,
            );
          });
          break;
        case CFCardBrand.discover:
          setState(() {
            _suffixIcon = Image.asset('packages/flutter_cashfree_pg_sdk/assets/discover.png',
              width: 30,
              height: 25,
              fit: BoxFit.fitWidth,
            );
          });
          break;
        case CFCardBrand.amex:
          setState(() {
            _suffixIcon = Image.asset('packages/flutter_cashfree_pg_sdk/assets/amex.png',
              width: 30,
              height: 25,
              fit: BoxFit.fitWidth,
            );
          });
          break;
        case CFCardBrand.visa:
          setState(() {
            _suffixIcon =
                Image.asset('packages/flutter_cashfree_pg_sdk/assets/visa.png',
                  width: 30,
                  height: 25,
                  fit: BoxFit.fitWidth,
                );
          });
          break;
        case CFCardBrand.rupay:
          setState(() {
            _suffixIcon =
                Image.asset('packages/flutter_cashfree_pg_sdk/assets/rupay.png',
                  width: 30,
                  height: 25,
                  fit: BoxFit.fitWidth,
                );
          });
          break;
        default:
          setState(() {
            _suffixIcon = Image.asset('packages/flutter_cashfree_pg_sdk/assets/credit-card-default.png',
              width: 30,
              height: 25,
              fit: BoxFit.fitHeight,
            );
          });
          break;
      }
    } else {
      if (textWithoutSpaces.length == 7) {
        setState(() {
          _suffixIcon = Image.asset(
            'packages/flutter_cashfree_pg_sdk/assets/credit-card-default.png',
            width: 30,
            height: 25,
            fit: BoxFit.fitHeight,
          );
        });
      }
    }
    completeResponse["luhn_check_info"] = "SUCCESS";
    if(!cfCardValidator.luhnCheck(textWithoutSpaces)){
      completeResponse["luhn_check_info"] = "FAIL";
    }
    completeResponse["card_length"] = textWithoutSpaces.length;
    _cardListener!(CFCardListener(textWithoutSpaces.length, "This contains all the information about the card.", "card_info", completeResponse));
  }

  void completePayment(final void Function(String) verifyPayment,
      final void Function(CFErrorResponse, String) onError,
      String card_cvv,
      String card_holder_name,
      String card_expiry_month,
      String card_expiry_year,
      Map<String, dynamic> session,
      bool save_payment_method,
      String? instrument_id) {

    Map<String, String> card = {};

    if(instrument_id != null) {
      card = {
        "instrument_id": instrument_id,
        "card_cvv": card_cvv,
      };
    } else {
      card = {
        "card_holder_name": card_holder_name,
        "card_cvv": card_cvv,
        "card_expiry_month": card_expiry_month,
        "card_expiry_year": card_expiry_year,
        "card_number": _controller.text.replaceAll(' ', ''),
      };
    }

    Map<String, dynamic> data = {
      "session": session,
      "card": card,
      "save_payment_method": save_payment_method,
    };

    // Create Method channel here
    MethodChannel methodChannel = const MethodChannel(
        'flutter_cashfree_pg_sdk');
      methodChannel.invokeMethod("doCardPayment", data).then((value) {
        if(value != null) {
          final body = json.decode(value);
          var status = body["status"] as String;
          switch (status) {
            case "exception":
              var data = body["data"] as Map<String, dynamic>;
              var cfErrorResponse = CFErrorResponse("FAILED", data["message"] as String, "invalid_request", "invalid_request");
              onError(cfErrorResponse, session["order_id"] ?? "order_id_not_found");
              break;
            case "success":
              var data = body["data"] as Map<String, dynamic>;
              verifyPayment(data["order_id"] as String);
              break;
            case "failed":
              var data = body["data"] as Map<String, dynamic>;
              var errorResponse = CFErrorResponse(
                  data["status"] as String, data["message"] as String,
                  data["code"] as String, data["type"] as String);
              onError(errorResponse, data["order_id"] as String);
              break;
          }
        }
      });
  }

}

