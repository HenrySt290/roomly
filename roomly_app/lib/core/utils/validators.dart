class Validators {
  Validators._();

  static String? Function(String?) get required => (value) {
        if (value == null || value.trim().isEmpty) {
          return 'This field is required';
        }
        return null;
      };

  static String? Function(String?) email = (value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Let required validator handle this
    }
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Invalid email address';
    }
    return null;
  };

  static String? Function(String?) phone = (value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }
    final phoneRegex = RegExp(r'^[6-9]\d{9}$');
    if (!phoneRegex.hasMatch(value.trim())) {
      return 'Invalid phone number (10 digits required)';
    }
    return null;
  };

  static String? Function(String?) password = (value) {
    if (value == null || value.isEmpty) {
      return null;
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain at least one uppercase letter';
    }
    if (!value.contains(RegExp(r'[a-z]'))) {
      return 'Password must contain at least one lowercase letter';
    }
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least one number';
    }
    return null;
  };

  static String? Function(String?) confirmPassword(String password) => (value) {
        if (value == null || value.isEmpty) {
          return null;
        }
        if (value != password) {
          return 'Passwords do not match';
        }
        return null;
      };

  static String? Function(String?) minLength(int min) => (value) {
        if (value == null || value.isEmpty) {
          return null;
        }
        if (value.length < min) {
          return 'Must be at least $min characters';
        }
        return null;
      };

  static String? Function(String?) maxLength(int max) => (value) {
        if (value == null || value.isEmpty) {
          return null;
        }
        if (value.length > max) {
          return 'Must not exceed $max characters';
        }
        return null;
      };

  static String? Function(String?) number = (value) {
        if (value == null || value.isEmpty) {
          return null;
        }
        if (double.tryParse(value) == null) {
          return 'Must be a valid number';
        }
        return null;
      };

  static String? Function(String?) positiveNumber = (value) {
        if (value == null || value.isEmpty) {
          return null;
        }
        final number = double.tryParse(value);
        if (number == null) {
          return 'Must be a valid number';
        }
        if (number <= 0) {
          return 'Must be greater than zero';
        }
        return null;
      };

  static String? Function(String?) url = (value) {
        if (value == null || value.isEmpty) {
          return null;
        }
        final urlRegex = RegExp(
          r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$',
        );
        if (!urlRegex.hasMatch(value.trim())) {
          return 'Invalid URL';
        }
        return null;
      };

  static String? Function(String?) createRangeValidator(
    num min,
    num max,
  ) =>
      (value) {
        if (value == null || value.isEmpty) {
          return null;
        }
        final number = double.tryParse(value);
        if (number == null) {
          return 'Must be a valid number';
        }
        if (number < min || number > max) {
          return 'Must be between $min and $max';
        }
        return null;
      };
}
