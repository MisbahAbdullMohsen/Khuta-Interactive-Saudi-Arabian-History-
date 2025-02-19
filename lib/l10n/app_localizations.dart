import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class AppLocalizations {
  final Locale locale;
  String get suggestions => 'Some suggestions'; // تأكد من وجود هذا التعريف
  String get noResults => 'No results found'; // تأكد من وجود هذا التعريف
  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  // Text translations
  String get appTitle {
    return locale.languageCode == 'ar' ? 'خطاء' : 'Error';
  }

  String get homeTitle {
    return locale.languageCode == 'ar' ? 'الصفحة الرئيسية' : 'Home Page';
  }

  String get timeline {
    return locale.languageCode == 'ar' ? 'الخط الزمني' : 'Timeline';
  }

  String get likes {
    return locale.languageCode == 'ar' ? 'الإعجابات' : 'Likes';
  }

  String get search {
    return locale.languageCode == 'ar' ? 'البحث' : 'Search';
  }

  String get settings {
    return locale.languageCode == 'ar' ? 'الإعدادات' : 'Settings';
  }

  String get aboutUs {
    return locale.languageCode == 'ar' ? 'من نحن' : 'About Us';
  }

  String get selectLanguage {
    return locale.languageCode == 'ar' ? 'اختر اللغة' : 'Select Language';
  }

  String get darkMode {
    return locale.languageCode == 'ar' ? 'الوضع المظلم' : 'Dark Mode';
  }

  String get notifications {
    return locale.languageCode == 'ar' ? 'الإشعارات' : 'Notifications';
  }

  String get switchLanguage {
    return locale.languageCode == 'ar' ? 'تغيير اللغة' : 'Change Language';
  }

  String get welcome {
    return locale.languageCode == 'ar'
        ? 'مرحبا بك في تطبيقنا!'
        : 'Welcome to our app!';
  }
}
