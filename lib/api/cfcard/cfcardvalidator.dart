enum CFCardBrand {
  visa,
  mastercard,
  amex,
  discover,
  rupay,
  jcb,
  other,
}

// Detect Card Brand through API

class CFCardValidator {

  CFCardBrand detectCardBrand(String scheme) {
  if (scheme == "visa") {
  return CFCardBrand.visa;
  } else if (scheme == "mastercard") {
  return CFCardBrand.mastercard;
  } else if (scheme == "amex") {
  return CFCardBrand.amex;
  } else if (scheme == "discover") {
  return CFCardBrand.discover;
  } else if (scheme == "rupay") {
    return CFCardBrand.rupay;
  } else if (scheme == "jcb") {
    return CFCardBrand.jcb;
  } else {
  return CFCardBrand.other;
  }
  }

  bool luhnCheck(String cardNumber) {
    if (cardNumber.isEmpty) {
      return false;
    }

    cardNumber = cardNumber.replaceAll(RegExp(r'\s'), ''); // Remove spaces

    int sum = 0;
    bool isAlternate = false;

    for (int i = cardNumber.length - 1; i >= 0; i--) {
      int digit = int.parse(cardNumber[i]);

      if (isAlternate) {
        digit *= 2;
        if (digit > 9) {
          digit -= 9;
        }
      }

      sum += digit;
      isAlternate = !isAlternate;
    }

    return sum % 10 == 0;
  }

}