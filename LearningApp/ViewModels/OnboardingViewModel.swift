import SwiftUI

@Observable
class OnboardingViewModel {
    var goal: String = ""
    var selectedDuration: Duration = .week

    func select(_ duration: Duration) {
        selectedDuration = duration
    }

    // الزر ما ينضغط إلا لو كتب هدف
    var canStart: Bool {
        !goal.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    func startLearning() {
        UserDefaults.standard.set(goal.trimmingCharacters(in: .whitespacesAndNewlines), forKey: "goal")
        UserDefaults.standard.set(selectedDuration.rawValue, forKey: "duration")
        UserDefaults.standard.set(Date(), forKey: "goalStartedAt")
        LearningLog.reset()
    }
}
