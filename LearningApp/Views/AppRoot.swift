import SwiftUI

// الشاشات اللي ننتقل لها
enum Route: Hashable {
    case calendar
    case goal
}

// الجذر: يربط الشاشات ببعض.
// لو فيه هدف محفوظ يبدأ من Activity، وإلا من Onboarding.
struct AppRoot: View {
    @State private var path: [Route] = []
    @State private var hasGoal = UserDefaults.standard.string(forKey: "goal") != nil
    // نغيّره عشان Activity تنبني من جديد وتقرأ التخزين
    @State private var refreshID = UUID()

    var body: some View {
        NavigationStack(path: $path) {
            Group {
                if hasGoal {
                    ActivityView(
                        onCalendar: { path.append(.calendar) },
                        onGoal: { path.append(.goal) }
                    )
                    .id(refreshID)
                } else {
                    OnboardingView(onStart: { hasGoal = true })
                }
            }
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(for: Route.self) { route in
                switch route {
                case .calendar:
                    CalendarView(onBack: { path.removeLast() })
                        .toolbar(.hidden, for: .navigationBar)
                case .goal:
                    UpdateGoalView(
                        onUpdated: {
                            // الهدف الجديد انحفظ: نرجع لـ Activity ونعيد بناءها
                            path.removeAll()
                            refreshID = UUID()
                        },
                        onBack: { path.removeLast() }
                    )
                    .toolbar(.hidden, for: .navigationBar)
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}

#Preview {
    AppRoot()
}
