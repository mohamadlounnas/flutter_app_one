/// Validation utility functions
class Validators {
  Validators._();

  /// Validate phone number (basic validation)
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    // Basic phone validation - at least 8 digits
    final phoneRegex = RegExp(r'^\+?[\d\s-]{8,}$');
    if (!phoneRegex.hasMatch(value)) {
      return 'Please enter a valid phone number';
    }
    return null;
  }

  /// Validate password
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  /// Validate name
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }
    if (value.length < 2) {
      return 'Name must be at least 2 characters';
    }
    return null;
  }

  /// Validate post title
  static String? validateTitle(String? value) {
    if (value == null || value.isEmpty) {
      return 'Title is required';
    }
    if (value.length < 3) {
      return 'Title must be at least 3 characters';
    }
    if (value.length > 200) {
      return 'Title must be less than 200 characters';
    }
    return null;
  }

  /// Validate post body
  static String? validateBody(String? value) {
    if (value == null || value.isEmpty) {
      return 'Content is required';
    }
    if (value.length < 10) {
      return 'Content must be at least 10 characters';
    }
    return null;
  }

  /// Validate comment
  static String? validateComment(String? value) {
    if (value == null || value.isEmpty) {
      return 'Comment is required';
    }
    if (value.length > 1000) {
      return 'Comment must be less than 1000 characters';
    }
    return null;
  }

  /// Validate URL
  static String? validateUrl(String? value) {
    if (value == null || value.isEmpty) {
      return null; // URL is optional in most cases
    }
    final urlRegex = RegExp(
      r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$',
    );
    if (!urlRegex.hasMatch(value)) {
      return 'Please enter a valid URL';
    }
    return null;
  }

  /// Validate required field
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  /// Validate max length
  static String? validateMaxLength(String? value, int maxLength, String fieldName) {
    if (value != null && value.length > maxLength) {
      return '$fieldName must be less than $maxLength characters';
    }
    return null;
  }

  /// Validate min length
  static String? validateMinLength(String? value, int minLength, String fieldName) {
    if (value != null && value.length < minLength) {
      return '$fieldName must be at least $minLength characters';
    }
    return null;
  }
}
