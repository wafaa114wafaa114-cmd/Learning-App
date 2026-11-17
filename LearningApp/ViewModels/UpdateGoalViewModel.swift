import SwiftUI

// العقل حق شاشة Update Learning Goal: يحمّل الهدف الحالي ويعدّله وينفّذ التحديث.
@Observable
class UpdateGoalViewModel {
    var goal: String
    var selectedDuration: Duration
    var showAlert = false

    init() {
        self.goal = ""
        let raw = UserDefaults.standard.string(forKey: "duration") ?? Duration.week.rawValue
        self.selectedDuration = Duration(rawValue: raw) ?? .week
    }

    // الزر ✓ ما ينضغط إلا لو فيه نص (مسافات فقط ما تنحسب)
    var canSubmit: Bool {
        !goal.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    func select(_ duration: Duration) {
        selectedDuration = duration
    }

    // الضغط على ✓: يطلع التنبيه دايماً (حتى لو ما تغيّر شي)
    func submit() {
        guard canSubmit else { return }
        showAlert = true
    }

    // الضغط على Update في التنبيه: نحفظ ونصفّر الـ Streak (هدف جديد)
    func confirmUpdate() {
        UserDefaults.standard.set(goal.trimmingCharacters(in: .whitespacesAndNewlines), forKey: "goal")
        UserDefaults.standard.set(selectedDuration.rawValue, forKey: "duration")
        UserDefaults.standard.set(Date(), forKey: "goalStartedAt")
        LearningLog.reset()
    }
}
