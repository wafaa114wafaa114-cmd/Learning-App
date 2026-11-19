import SwiftUI

// حالات الهدف: الشاشة تقرأها وتقرر وش تعرض
enum GoalState {
    case active      // الهدف شغال
    case completed   // خلصت المدة وما انكسر الـ Streak
    case notMet      // انكسر الـ Streak
}

// MARK: - ActivityViewModel
// العقل حق شاشة Activity: يتذكر الحالة ويقرر القواعد.
// الـ View ما يحسب شي بنفسه، يسأل هذا الملف ويعرض الجواب.
@Observable   // لما أي قيمة تتغير، SwiftUI يعيد رسم الشاشة تلقائياً
class ActivityViewModel {

    // السجل كامل (الأيام، الـ Streak، الـ Freezes).
    // private(set): الشاشة تقرأه بس، والتعديل لازم يمر على الدوال تحت.
    private(set) var log: LearningLog

    // المدة اللي اختارها المستخدم في Onboarding. منها نعرف الحد الأقصى للـ Freezes.
    let duration: Duration

    // وقت بداية الهدف (انحفظ من Onboarding)
    let goalStartedAt: Date

    // دالة ترجع "الوقت الحين". الافتراضي الوقت الحقيقي،
    var now: () -> Date

    init(now: @escaping () -> Date = { Date() }) {
        self.now = now
        let raw = UserDefaults.standard.string(forKey: "duration") ?? Duration.week.rawValue
        self.duration = Duration(rawValue: raw) ?? .week
        self.goalStartedAt = (UserDefaults.standard.object(forKey: "goalStartedAt") as? Date) ?? now()
        self.log = LearningLog.load()   // نحمّل اللي انحفظ قبل
        breakStreakIfNeeded()           // نفحص: هل عدّت 32 ساعة؟
    }

    // MARK: - قيم تقرأها الشاشة (ما تخزن شي، بس تجيب من log)

    var streak: Int { log.streak }
    var freezesUsed: Int { log.freezesUsed }
    var maxFreezes: Int { duration.maxFreezes }   // 2 / 8 / 96 حسب المدة

    // حالة اليوم: .learned أو .frozen أو nil (ما سجّل شي)
    var todayStatus: DayStatus? { log.status(on: now()) }

    // MARK: - حالة الهدف

    private let calendar: Calendar = {
        var c = Calendar(identifier: .gregorian)
        c.firstWeekday = 1
        return c
    }()

    // نهاية الهدف: بداية يوم البداية + المدة
    private var goalEndDate: Date {
        let start = calendar.startOfDay(for: goalStartedAt)
        let (component, value) = duration.calendarComponent
        return calendar.date(byAdding: component, value: value, to: start) ?? start
    }

    var state: GoalState {
        if log.streakBroken { return .notMet }        // انكسر
        if now() >= goalEndDate { return .completed } // خلصت المدة وما انكسر
        return .active
    }

    var isActive: Bool { state == .active }

    // MARK: - متى تشتغل الأزرار
    // القاعدة: الزر المختار حالياً يتعطل، والثاني يبقى شغال (عشان التبديل).

    var canLog: Bool { isActive && todayStatus != .learned }

    // Freeze يشتغل لو اليوم مو مجمّد أصلاً، وباقي له Freeze
    var canFreeze: Bool {
        isActive && todayStatus != .frozen && freezesUsed < maxFreezes
    }

    // السؤال اللي تسأله كل شاشة (الشريط والتقويم الشهري): وش حالة هذا اليوم؟
    func status(on date: Date) -> DayStatus? { log.status(on: date) }

    // MARK: - الأوامر

    func logAsLearned() {
        breakStreakIfNeeded()          // ← نفحص قبل التسجيل (لو عدّت 32 ساعة ما ينقبل)
        guard canLog else { return }   // حماية: لو ما يقدر، اخرج

        // لو كان مجمّد وبدّل لـ Learned، نرجّع له الـ Freeze
        if todayStatus == .frozen {
            log.freezesUsed = max(0, log.freezesUsed - 1)
        }
        log.days[LearningLog.key(for: now())] = .learned
        log.streak += 1
        log.lastLoggedAt = now()   // منه نحسب الـ 32 ساعة
        log.save()                 // نكتب في التخزين عشان ما يضيع
    }

    func freezeToday() {
        breakStreakIfNeeded()          // ← نفحص قبل التسجيل
        guard canFreeze else { return }

        // لو كان متعلَّم وبدّل لـ Freeze، نلغي الـ Streak اللي زاد
        if todayStatus == .learned {
            log.streak = max(0, log.streak - 1)
        }
        log.days[LearningLog.key(for: now())] = .frozen
        log.freezesUsed += 1
        log.lastLoggedAt = now()
        log.save()
    }

    // MARK: - انكسار الـ Streak
    // قاعدة التصميم: أكثر من 32 ساعة من آخر تسجيل (Learned أو Freeze) = ينكسر.
    // ← شلنا شرط goalEndDate: الانكسار يتسجل حتى لو فتحنا التطبيق بعد نهاية الهدف،
    func breakStreakIfNeeded() {
        guard !log.streakBroken else { return }   // لو انكسر قبل، ما نكرره
        // لو ما سجّل أبداً، العدّ يبدأ من بداية الهدف
        let reference = log.lastLoggedAt ?? goalStartedAt
        let hours = now().timeIntervalSince(reference) / 3600
        if hours > 32 {
            log.streak = 0
            log.streakBroken = true   // نسجّل إنه انكسر (الهدف ما تحقق)
            log.save()
        }
    }
}
