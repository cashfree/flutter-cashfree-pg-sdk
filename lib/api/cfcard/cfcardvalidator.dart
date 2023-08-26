enum CFCardBrand {
  visa,
  mastercard,
  amex,
  discover,
  other,
}

class CFCardValidator {

  CFCardBrand detectCardBrand(String cardNumber) {
  // Remove any spaces or dashes from the card number
  cardNumber = cardNumber.replaceAll(RegExp(r'[-\s]'), '');

  if (RegExp(r'^4[0-9]{12}(?:[0-9]{3})?$').hasMatch(cardNumber)) {
  return CFCardBrand.visa;
  } else if (RegExp(r'^5[1-5][0-9]{14}$').hasMatch(cardNumber)) {
  return CFCardBrand.mastercard;
  } else if (RegExp(r'^3[47][0-9]{13}$').hasMatch(cardNumber)) {
  return CFCardBrand.amex;
  } else if (RegExp(r'^6(?:011|5[0-9]{2})[0-9]{12}$').hasMatch(cardNumber)) {
  return CFCardBrand.discover;
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