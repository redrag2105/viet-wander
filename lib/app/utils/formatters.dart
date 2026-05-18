class Formatters {
  static String formatNumber(num number, {int? fractionDigits}) {
    String str;
    if (fractionDigits != null && number is double) {
      str = number.toStringAsFixed(fractionDigits);
    } else {
      str = number.toString();
    }

    List<String> parts = str.split('.');
    String intPart = parts[0];
    String decPart = parts.length > 1 ? parts[1] : '';

    String formattedInt = '';
    int count = 0;
    for (int i = intPart.length - 1; i >= 0; i--) {
      formattedInt = intPart[i] + formattedInt;
      count++;
      if (count == 3 && i > 0 && intPart[i - 1] != '-') {
        formattedInt = ' $formattedInt';
        count = 0;
      }
    }

    if (decPart.isNotEmpty) {
      return '$formattedInt,$decPart';
    }
    return formattedInt;
  }
}
