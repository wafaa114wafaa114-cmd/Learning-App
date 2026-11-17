import Foundation

// حالة اليوم المسجّل
enum DayStatus: String, Codable {
    case learned
    case frozen
}

// MARK: - LearningLog
// المصدر المشترك للأيام المسجلة. شريط الأسبوع والتقويم الشهري يقرآن منه.
// لا أحد ثاني يحتفظ بقائمة أيام خاصة فيه، ومن هنا ينتج الترابط بين الشاشات.
struct LearningLog: Codable {
    // كل يوم مسجّل. المفتاح نص بصيغة yyyy-MM-dd (مثل "2026-11-15")
    var days: [String: DayStatus] = [:]

    // وقت آخر تسجيل (Learned أو Freeze). منه نحسب قاعدة الـ 32 ساعة.
    var lastLoggedAt: Date? = nil

    var streak: Int = 0
    var freezesUsed: Int = 0
    // true أول ما ينكسر الـ Streak. ما يرجع false إلا بهدف جديد.
    var streakBroken: Bool = false

    private static let storageKey = "learningLog"

    // يحوّل أي تاريخ لمفتاح ثابت. نستخدم en_US_POSIX والتقويم الميلادي
    // عشان المفتاح ما يتغير لو لغة الجوال أو تقويمه اختلف.
    static func key(for date: Date) -> String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US_POSIX")
        f.calendar = Calendar(identifier: .gregorian)
        f.dateFormat = "yyyy-MM-dd"
        return f.string(from: date)
    }

    // وش حالة هذا اليوم؟ nil = ما سجّل شي
    func status(on date: Date) -> DayStatus? {
        days[Self.key(for: date)]
    }

    // قراءة من التخزين. لو ما فيه شي محفوظ نرجع سجل فاضي.
    static func load() -> LearningLog {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let log = try? JSONDecoder().decode(LearningLog.self, from: data) else {
            return LearningLog()
        }
        return log
    }

    // كتابة في التخزين (تنحفظ حتى بعد إغلاق التطبيق)
    func save() {
        if let data = try? JSONEncoder().encode(self) {
            UserDefaults.standard.set(data, forKey: Self.storageKey)
        }
    }

    // يصفّر كل شي. نستخدمه لما يبدأ المستخدم هدف جديد من Onboarding.
    static func reset() {
        UserDefaults.standard.removeObject(forKey: storageKey)
    }
}
