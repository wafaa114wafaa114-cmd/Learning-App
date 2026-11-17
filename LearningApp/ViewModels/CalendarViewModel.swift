import SwiftUI

// العقل حق شاشة Calendar (التقويم الكامل): يقرأ من نفس السجل، ما يخزّن شي.
@Observable
class CalendarViewModel {
    private let log: LearningLog
    var now: () -> Date

    private let calendar: Calendar = {
        var c = Calendar(identifier: .gregorian)
        c.firstWeekday = 1   // الأحد
        return c
    }()

    // كم شهر نعرض قبل وبعد الشهر الحالي
    private let monthsRange = 24

    init(now: @escaping () -> Date = { Date() }) {
        self.now = now
        self.log = LearningLog.load()
    }

    // أول يوم في كل شهر من النطاق
    var months: [Date] {
        guard let currentStart = calendar.dateInterval(of: .month, for: now())?.start else { return [] }
        return (-monthsRange...monthsRange).compactMap {
            calendar.date(byAdding: .month, value: $0, to: currentStart)
        }
    }

    // الشهر الحالي (نمرر له عند الفتح)
    var currentMonth: Date {
        calendar.dateInterval(of: .month, for: now())?.start ?? now()
    }

    // أيام الشهر، مع nil للفراغات قبل اليوم 1 (عشان يصطف تحت اليوم الصح)
    func cells(for month: Date) -> [Date?] {
        guard let range = calendar.range(of: .day, in: .month, for: month) else { return [] }
        let firstWeekday = calendar.component(.weekday, from: month)   // 1 = الأحد
        let blanks = Array(repeating: nil as Date?, count: firstWeekday - 1)
        let days: [Date?] = range.compactMap { calendar.date(byAdding: .day, value: $0 - 1, to: month) }
        return blanks + days
    }

    // نفس السؤال المشترك: وش حالة هذا اليوم؟
    func status(on date: Date) -> DayStatus? { log.status(on: date) }

    func isToday(_ date: Date) -> Bool { calendar.isDate(date, inSameDayAs: now()) }

    func dayNumber(_ date: Date) -> Int { calendar.component(.day, from: date) }

    func title(for month: Date) -> String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US")
        f.dateFormat = "MMMM yyyy"
        return f.string(from: month)
    }
}
