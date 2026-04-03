class AppDictionary {
  static Map<String, Map<String, String>> translations = {
    'English': {
      'patient_title': 'Patient Dashboard',
      'caregiver_title': 'Caregiver Dashboard',
      'welcome_patient': 'Welcome!',
      'welcome_caregiver': 'Monitoring Patient Status...',
      'help_btn': 'I NEED HELP',
      'logout': 'Logout',
      'link_success': 'Linked successfully!',
      'link_not_found': 'Patient email not found.',
      'link_error': 'An error occurred during linking.',
    },
    'Egyptian Arabic': {
      'patient_title': 'لوحة تحكم المريض',
      'caregiver_title': 'متابعة الحالة',
      'welcome_patient': 'أهلاً بك',
      'welcome_caregiver': 'بـنـتـابع حالة المريض دلوقتي...',
      'help_btn': 'إلـحـقـنـي',
      'logout': 'خروج',
      'link_success': 'تم الربط بنجاح!',
      'link_not_found': 'الايميل ده مش موجود عندنا.',
      'link_error': 'حصل مشكلة واحنا بنربط الحساب.',
    }
  };

  static String getString(String language, String key) {
    return translations[language]?[key] ?? translations['English']![key]!;
  }
}