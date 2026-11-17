import SwiftUI

struct ActivityView: View {
    // الربط بالعقل
    @State private var viewModel: ActivityViewModel

    // الانتقالات: يحددها AppRoot
    var onCalendar: () -> Void = {}
    var onGoal: () -> Void = {}

    // يخلينا نمرر ViewModel جاهز (بوقت مزيّف) للـ Preview.
    init(
        viewModel: ActivityViewModel = ActivityViewModel(),
        onCalendar: @escaping () -> Void = {},
        onGoal: @escaping () -> Void = {}
    ) {
        _viewModel = State(initialValue: viewModel)
        self.onCalendar = onCalendar
        self.onGoal = onGoal
    }

    private let cardGray = Color(red: 0.07, green: 0.07, blue: 0.07)

    private let calendar: Calendar = {
        var c = Calendar(identifier: .gregorian)
        c.firstWeekday = 1
        return c
    }()

    private var today: Date { viewModel.now() }

    private var weekDays: [Date] {
        guard let start = calendar.dateInterval(of: .weekOfYear, for: today)?.start else { return [] }
        return (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: start) }
    }

    private var dateText: String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US")
        f.dateFormat = "EEEE, d MMMM"
        return f.string(from: today)
    }

    private func dayWord(_ n: Int) -> String { n == 1 ? "day" : "days" }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {

                HStack {
                    Text("Activity")
                        .font(.system(size: 34, weight: .bold))
                        .foregroundStyle(.white)
                    Spacer()
                    HStack(spacing: 12) {
                        circleIcon("calendar") { onCalendar() }
                        circleIcon("pencil.and.outline") { onGoal() }
                    }
                }

                Text(dateText)
                    .font(.system(size: 17))
                    .foregroundStyle(Color.appGray)
                    .padding(.top, 4)

                HStack(spacing: 0) {
                    ForEach(weekDays, id: \.self) { day in
                        weekDayView(day)
                    }
                }
                .padding(.top, 20)

                HStack(spacing: 14) {
                    statCard(icon: "flame.fill", color: .appOrange,
                             value: "\(viewModel.streak) \(dayWord(viewModel.streak))",
                             label: "Learned")
                    statCard(icon: "snowflake", color: .appCyan,
                             value: "\(viewModel.freezesUsed) \(dayWord(viewModel.freezesUsed))",
                             label: "Freezed")
                }
                .padding(.top, 14)

                if viewModel.isActive {
                    Spacer()

                    Button {
                        viewModel.logAsLearned()
                    } label: {
                        Text(viewModel.todayStatus == .learned ? "Logged as Learned" : "Log as Learned")
                            .font(.system(size: 22, weight: .bold))
                            .frame(width: 290, height: 290)
                    }
                    .glassButton()
                    .buttonBorderShape(.circle)
                    .disabled(!viewModel.canLog)
                    .frame(maxWidth: .infinity)

                    Spacer()

                    VStack(spacing: 14) {
                        Button {
                            viewModel.freezeToday()
                        } label: {
                            Text(viewModel.todayStatus == .frozen ? "Freezed for a day" : "Freeze for a day")
                                .font(.system(size: 20, weight: .medium))
                                .frame(width: 290, height: 50)
                        }
                        .glassButton(tint: .appCyan)
                        .buttonBorderShape(.capsule)
                        .disabled(!viewModel.canFreeze)

                        Text("\(viewModel.freezesUsed) out of \(viewModel.maxFreezes) Freezes used")
                            .font(.system(size: 14))
                            .foregroundStyle(Color.appGray)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.bottom, 30)
                } else {
                    goalEndView(completed: viewModel.state == .completed)
                        .padding(.top, 70)

                    Button {
                        onGoal()
                    } label: {
                        Label("Set a goal", systemImage: "pencil.and.outline")
                            .font(.system(size: 20, weight: .medium))
                            .padding(.horizontal, 20)
                            .padding(.vertical, 6)
                    }
                    .glassButton()
                    .buttonBorderShape(.capsule)
                    .frame(maxWidth: .infinity)
                    .padding(.top, 80)

                    Spacer()
                }
            }
            .padding(.horizontal, 16)
        }
    }

    private func goalEndView(completed: Bool) -> some View {
        VStack(spacing: 6) {
            Image(systemName: completed ? "hands.sparkles.fill" : "xmark.seal")
                .font(.system(size: 44))
                .foregroundStyle(Color.appOrange)
                .padding(.bottom, 8)
            Text(completed ? "Well done!" : "You didn't reach your goal this time.")
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(.white)
            Text(completed ? "Ready for your next goal?" : "Want to set another goal?")
                .font(.system(size: 17))
                .foregroundStyle(Color.appGray)
        }
        .frame(maxWidth: .infinity)
    }

    // أيقونة التقويم والهدف
    private func circleIcon(_ name: String, action: @escaping () -> Void) -> some View {
        Button {
            action()
        } label: {
            Image(systemName: name)
                .font(.system(size: 18))
                .frame(width: 28, height: 28)
        }
        .glassButton(selected: false)
        .buttonBorderShape(.circle)
    }

    private func weekDayView(_ day: Date) -> some View {
        let isToday = calendar.isDate(day, inSameDayAs: today)
        let weekdayIndex = calendar.component(.weekday, from: day) - 1
        let letter = ["S", "M", "T", "W", "T", "F", "S"][weekdayIndex]
        let number = calendar.component(.day, from: day)
        let status = viewModel.status(on: day)

        let textColor: Color = {
            if status == .frozen { return .appCyan }
            if status == .learned { return .appOrange }
            return .white
        }()

        let fillColor: Color = {
            if status == .learned { return Color(red: 0.22, green: 0.13, blue: 0.05) }
            if status == .frozen { return Color(red: 0.05, green: 0.15, blue: 0.20) }
            if isToday { return .appOrange }
            return .clear
        }()

        return VStack(spacing: 8) {
            Text(letter)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(.white)
            Text("\(number)")
                .font(.system(size: 22, weight: .medium))
                .foregroundStyle(textColor)
                .frame(width: 44, height: 44)
                .background(Circle().fill(fillColor))
        }
        .frame(maxWidth: .infinity)
    }

    private func statCard(icon: String, color: Color, value: String, label: String) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundStyle(color)
            Text(value)
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(.white)
            Text(label)
                .font(.system(size: 13))
                .foregroundStyle(.white)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 100)
        .background(
            RoundedRectangle(cornerRadius: 28)
                .fill(cardGray)
                .overlay(
                    RoundedRectangle(cornerRadius: 28)
                        .strokeBorder(
                            LinearGradient(
                                colors: [Color.white.opacity(0.18), Color.white.opacity(0.03)],
                                startPoint: .top,
                                endPoint: .bottom
                            ),
                            lineWidth: 1
                        )
                )
        )
    }
}

// MARK: - Previews
// كل معاينة تكتب بيانات مثل التصميم، فما تتأثر ببعضها.

private func previewViewModel(
    daysAgo: [(Int, DayStatus)],
    streak: Int,
    freezes: Int,
    broken: Bool,
    startedDaysAgo: Int,
    now: Date
) -> ActivityViewModel {
    let cal = Calendar(identifier: .gregorian)
    UserDefaults.standard.set("Week", forKey: "duration")
    UserDefaults.standard.set(cal.date(byAdding: .day, value: -startedDaysAgo, to: now), forKey: "goalStartedAt")

    var log = LearningLog()
    for (ago, status) in daysAgo {
        if let d = cal.date(byAdding: .day, value: -ago, to: now) {
            log.days[LearningLog.key(for: d)] = status
        }
    }
    log.streak = streak
    log.freezesUsed = freezes
    log.streakBroken = broken
    log.lastLoggedAt = now.addingTimeInterval(-3600)
    log.save()
    return ActivityViewModel(now: { now })
}

#Preview("Goal completed") {
    let now = Date()
    let vm = previewViewModel(
        daysAgo: [(6, .learned), (5, .learned), (4, .learned), (2, .frozen), (1, .frozen)],
        streak: 3, freezes: 2, broken: false, startedDaysAgo: 8, now: now
    )
    return ActivityView(viewModel: vm)
}

#Preview("Goal not met") {
    let now = Date()
    let vm = previewViewModel(
        daysAgo: [(4, .learned), (3, .learned), (1, .frozen), (0, .frozen)],
        streak: 2, freezes: 2, broken: true, startedDaysAgo: 5, now: now
    )
    return ActivityView(viewModel: vm)
}

#Preview("Active") {
    let now = Date()
    let vm = previewViewModel(
        daysAgo: [], streak: 0, freezes: 0, broken: false, startedDaysAgo: 0, now: now
    )
    return ActivityView(viewModel: vm)
}
