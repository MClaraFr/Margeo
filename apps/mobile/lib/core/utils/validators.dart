class Validators {
  static String? requiredField(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Este campo é obrigatório';
    }

    return null;
  }

  static String? positiveNumber(String? value) {
    final number = double.tryParse((value ?? '').trim().replaceAll(',', '.'));

    if (number == null || number <= 0) {
      return 'Informe um valor maior que zero';
    }

    return null;
  }

  static String? requiredSelection<T>(
    T? value, {
    String message = 'Selecione uma opção',
  }) {
    if (value == null) {
      return message;
    }

    return null;
  }
}
