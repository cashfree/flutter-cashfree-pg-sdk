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
    String textWithoutSpaces = newText.replaceAll(' ', '');
    _cardListener!(CFCardListener(textWithoutSpaces.length, "", "card_length", null));

    if(textWithoutSpaces.length >= 4) {
      var brand = cfCardValidator.detectCardBrand(textWithoutSpaces);
      switch(brand) {
        case CFCardBrand.mastercard:
          setState(() {
            _suffixIcon = Image.asset('packages/flutter_cashfree_pg_sdk/assets/mastercard.png',
              width: 30,
              height: 25,
              fit: BoxFit.fitHeight,
            );
          });
          break;
        case CFCardBrand.amex:
          setState(() {
            _suffixIcon = Image.asset('packages/flutter_cashfree_pg_sdk/assets/amex.png',
              width: 30,
              height: 25,
              fit: BoxFit.fitHeight,
            );
          });
          break;
        case CFCardBrand.visa:
          setState(() {
            _suffixIcon =
                Image.asset('packages/flutter_cashfree_pg_sdk/assets/visa.png',
                  width: 30,
                  height: 25,
                  fit: BoxFit.fitHeight,
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
    }

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
    if(textWithoutSpaces.length == 16) {
      if(!cfCardValidator.luhnCheck(textWithoutSpaces)){
        _cardListener!(CFCardListener(textWithoutSpaces.length, "luhn check failed", "luhn_check_failed", null));
      }
    }
    if(textWithoutSpaces.length == 8) {
      var tdrResponse = await CFNetworkManager().getTDR(_cfSession!, textWithoutSpaces);
      var cardbinResponse = await CFNetworkManager().getCardBin(_cfSession!, textWithoutSpaces);
      var tdrJson = {};
      var cardbinJson = {};
      if(tdrResponse.statusCode == 200) {
        tdrJson = json.decode(tdrResponse.body);
        _cardListener!(CFCardListener(textWithoutSpaces.length, "tdr information sent in the response", "tdr_response", tdrJson));
      }
      if(cardbinResponse.statusCode == 200) {
        cardbinJson = jsonDecode(cardbinResponse.body);
        _cardListener!(CFCardListener(textWithoutSpaces.length, "card bin information sent in the response", "card_bin_response", cardbinJson));
      }
    }
  }

  void completePayment(final void Function(String) verifyPayment,
      final void Function(CFErrorResponse, String) onError,
      String card_cvv,
      String card_holder_name,
      String card_expiry_month,
      String card_expiry_year,
      Map<String, dynamic> session) {

    Map<String, String> card = {
      "card_holder_name": card_holder_name,
      "card_cvv": card_cvv,
      "card_expiry_month": card_expiry_month,
      "card_expiry_year": card_expiry_year,
      "card_number": _controller.text.replaceAll(' ', ''),
    };

    Map<String, dynamic> data = {
      "session": session,
      "card": card,
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

