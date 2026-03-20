
enum Language {
  russian,
  english,
  german,
  french,
  japanese,
  spanish,
  italian,
  chinese;

  String get flag {
    switch (this) {
      case Language.russian: return "🇷🇺";
      case Language.english: return "🇺🇸";
      case Language.german: return "🇩🇪";
      case Language.french: return "🇫🇷";
      case Language.japanese: return "🇯🇵";
      case Language.spanish: return "🇪🇸";
      case Language.italian: return "🇮🇹";
      case Language.chinese: return "🇨🇳";
    }
  }

  String get displayName {
    switch (this) {
      case Language.russian: return "Русский";
      case Language.english: return "English";
      case Language.german: return "Deutsch";
      case Language.french: return "Français";
      case Language.japanese: return "日本語";
      case Language.spanish: return "Español";
      case Language.italian: return "Italiano";
      case Language.chinese: return "中文";
    }
  }

  String get nameInRussian {
    switch (this) {
      case Language.russian: return "Русский";
      case Language.english: return "Английский";
      case Language.german: return "Немецкий";
      case Language.french: return "Французский";
      case Language.japanese: return "Японский";
      case Language.spanish: return "Испанский";
      case Language.italian: return "Итальянский";
      case Language.chinese: return "Китайский";
    }
  }

  String get code {
    switch (this) {
      case Language.russian: return "ru-RU";
      case Language.english: return "en-US";
      case Language.german: return "de-DE";
      case Language.french: return "fr-FR";
      case Language.japanese: return "ja-JP";
      case Language.spanish: return "es-ES";
      case Language.italian: return "it-IT";
      case Language.chinese: return "zh-CN";
    }
  }
}
