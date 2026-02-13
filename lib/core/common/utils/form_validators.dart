class AppFormValidator {
  AppFormValidator._();

  static String? isNotEmpty(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'This field cannot be empty.';
    }
    return null;
  }

  static String? startDateBeforeEndDate(DateTime? startDate, DateTime? endDate) {
    if (startDate != null && endDate != null && startDate.isAfter(endDate)) {
      return 'Start date must be before the end date.';
    }
    return null;
  }
}
