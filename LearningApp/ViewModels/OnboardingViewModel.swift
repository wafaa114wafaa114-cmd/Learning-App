import SwiftUI

@Observable
class OnboardingViewModel {
    var goal: String = ""
    var selectedDuration: Duration = .week

    func select(_ duration: Duration) {
        selectedDuration = duration
    }

    func startLearning() {
        UserDefaults.standard.set(goal, forKey: "goal")
        UserDefaults.standard.set(selectedDuration.rawValue, forKey: "duration")
        UserDefaults.standard.set(Date(), forKey: "goalStartedAt")
        LearningLog.reset()
        print("Goal: \(goal), Duration: \(selectedDuration.rawValue)")
    }
}
