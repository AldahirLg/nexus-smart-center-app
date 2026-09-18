class FormValidators {
  static String? required(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Este campo es obligatorio';
    }

    return null;
  }

  static String? positiveInteger(String? value) {
    final requiredError = required(value);

    if (requiredError != null) {
      return requiredError;
    }

    final number = int.tryParse(value!.trim());

    if (number == null) {
      return 'Ingresa un número válido';
    }

    if (number <= 0) {
      return 'Debe ser mayor que 0';
    }

    return null;
  }

  static String? percentage(String? value) {
    final requiredError = required(value);

    if (requiredError != null) {
      return requiredError;
    }

    final number = int.tryParse(value!.trim());

    if (number == null) {
      return 'Ingresa un número válido';
    }

    if (number < 0 || number > 100) {
      return 'Debe estar entre 0 y 100';
    }

    return null;
  }
}
