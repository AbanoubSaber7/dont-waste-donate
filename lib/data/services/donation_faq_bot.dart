/// Lightweight FAQ-style matcher (NLTK-style intent: token overlap on curated pairs).
/// The upstream "AI-Chatbot-Final-Year-Project" repo does not ship runnable code; this
/// implements the same idea inside the Flutter app.
class DonationFaqBot {
  DonationFaqBot._();

  static final List<_FaqEntry> _entries = [
    _FaqEntry(
      triggers: {
        'تبرع', 'تبرعات', 'ازاي', 'كيف', 'donate', 'donation', 'give', 'help',
      },
      answerAr:
          'لإضافة تبرع: من الشاشة الرئيسية أو القائمة السفلية استخدم زر «تبرع الآن»، التقط صورة الغرض، راجع تصنيف الذكاء الاصطناعي، ثم أكمل الخطوات حتى الدفع.',
      answerEn:
          'To donate: tap “Donate now”, take a photo of your item, review AI category/condition, then continue through amount and payment.',
    ),
    _FaqEntry(
      triggers: {
        'صورة', 'كاميرا', 'camera', 'photo', 'image', 'ai', 'ذكاء', 'تحليل',
      },
      answerAr:
          'التطبيق يحلل صورة التبرع لتقدير الفئة (طعام، ملابس، …) والحالة. تأكد من إضاءة جيدة ووضوح الصورة.',
      answerEn:
          'The app analyzes your donation photo to suggest category and condition. Use good lighting and a clear shot.',
    ),
    _FaqEntry(
      triggers: {
        'امان', 'آمن', 'safe', 'food', 'طعام', 'فساد', 'صلاحية', 'expiry',
      },
      answerAr:
          'لا تتبرع بطعام منتهي أو غير آمن. راجع أسئلة التحقق بعد التحليل (طازج، مطبوخ، صلاحية) قبل الإرسال.',
      answerEn:
          'Do not donate expired or unsafe food. After AI analysis, confirm the food safety toggles before submitting.',
    ),
    _FaqEntry(
      triggers: {
        'فئات', 'category', 'categories', 'ملابس', 'clothes', 'صحة', 'health',
        'تعليم', 'education', 'مأوى', 'shelter',
      },
      answerAr:
          'يمكنك اختيار فئات مثل الطعام، الملابس، الصحة، التعليم، والمأوى. يمكن تعديل الفئة بعد تحليل الصورة.',
      answerEn:
          'You can pick Food, Clothes, Health, Education, Shelter. You may adjust the category after AI suggestions.',
    ),
    _FaqEntry(
      triggers: {
        'حساب', 'تسجيل', 'دخول', 'login', 'register', 'account', 'password',
      },
      answerAr:
          'استخدم شاشات تسجيل الدخول أو إنشاء حساب من البداية. بعد الدخول تظهر الشاشة الرئيسية والتبرعات المحفوظة.',
      answerEn:
          'Use Login or Register from the start. After sign-in you get home, history, and profile.',
    ),
    _FaqEntry(
      triggers: {
        'خرائط', 'موقع', 'map', 'location', 'قريب', 'nearby',
      },
      answerAr:
          'قسم «بالقرب منك» يعرض منظمات مقترحة. تأكد من تفعيل أذونات الموقع من إعدادات الجهاز.',
      answerEn:
          '“Nearby” lists sample organizations. Grant location permissions in system settings if prompted.',
    ),
  ];

  /// Returns a canned answer if confidence is high enough; otherwise null (use AI).
  static String? match(String raw) {
    final tokens = _tokenize(raw);
    if (tokens.isEmpty) return null;

    _FaqEntry? best;
    var bestScore = 0;
    for (final e in _entries) {
      final s = e.score(tokens);
      if (s > bestScore) {
        bestScore = s;
        best = e;
      }
    }
    if (best == null || bestScore < 2) return null;
    final prefersArabic = _prefersArabic(raw);
    return prefersArabic ? best.answerAr : best.answerEn;
  }

  static bool _prefersArabic(String s) {
    var arabic = 0;
    var latin = 0;
    for (final r in s.runes) {
      if (r >= 0x0600 && r <= 0x06FF) {
        arabic++;
      } else if ((r >= 0x0041 && r <= 0x005A) || (r >= 0x0061 && r <= 0x007A)) {
        latin++;
      }
    }
    return arabic >= latin;
  }

  static final RegExp _letter = RegExp(r'[a-z\u0600-\u06ff]');

  static Set<String> _tokenize(String raw) {
    final buf = StringBuffer();
    for (final c in raw.toLowerCase().split('')) {
      if (_letter.hasMatch(c)) {
        buf.write(c);
      } else {
        buf.write(' ');
      }
    }
    return buf
        .toString()
        .split(RegExp(r'\s+'))
        .map((t) => _stemLight(t))
        .where((t) => t.length > 1)
        .toSet();
  }

  static String _stemLight(String t) {
    if (!RegExp(r'^[a-z]+$').hasMatch(t)) return t;
    if (t.length <= 4) return t;
    const suffixes = ['ing', 'tion', 's', 'es'];
    for (final suf in suffixes) {
      if (t.endsWith(suf) && t.length > suf.length + 2) {
        return t.substring(0, t.length - suf.length);
      }
    }
    return t;
  }
}

class _FaqEntry {
  _FaqEntry({
    required this.triggers,
    required this.answerAr,
    required this.answerEn,
  });

  final Set<String> triggers;
  final String answerAr;
  final String answerEn;

  int score(Set<String> tokens) {
    var n = 0;
    for (final tok in tokens) {
      if (triggers.contains(tok)) n += 3;
      for (final tr in triggers) {
        if (tr.contains(tok) || tok.contains(tr)) n += 1;
      }
    }
    return n;
  }
}
