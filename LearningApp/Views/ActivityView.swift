import SwiftUI

struct ActivityView: View {
    // الربط بالعقل. هذا السطر هو اللي يخلي الشاشة تقرأ من الـ ViewModel.
    @State private var viewModel: ActivityViewModel

    // يخلينا نمرر ViewModel جاهز (بوقت مزيّف) للـ Preview.
    // الافتراضي ينشئ واحد عادي، فباقي التطبيق ما يتأثر.
    init(viewModel: ActivityViewModel = ActivityViewModel()) {
        _viewModel = State(initialValue: viewModel)
    }

    private let cardGray = Color(red: 0.07, green: 0.07, blue: 0.07)

    // تقويم ثابت: الأسبوع يبدأ الأحد (حسب التصميم)
    private let calendar: Calendar = {
        var c = Calendar(identifier: .gregorian)
        c.firstWeekday = 1
        return c
    }()

    // اليوم يجي من الـ ViewModel مو من Date() مباشرة،
    private var today: Date { viewModel.now() }

    // الأيام السبعة من الأحد، محسوبة من تاريخ اليوم (مو أرقام ثابتة)
    private var weekDays: [Date] {
        guard let start = calendar.dateInterval(of: .weekOfYear, for: today)?.start else { return [] }
        return (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: start) }
    }

    private var dateText: String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US")   // إنجليزي حتى لو الجوال عربي
        f.dateFormat = "EEEE, d MMMM"
        return f.string(from: today)
    }

    // قاعدة التصميم: الرقم 1 = "day"، غيره = "days"
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
                        circleIcon("calendar")
                        circleIcon("pencil.and.outline")
                    }
                }

                Text(dateText)
                    .font(.system(size: 17))
                    .foregroundStyle(Color.appGray)
                    .padding(.top, 4)

                // شريط الأسبوع: يكرر weekDayView لكل يوم من الأيام السبعة
                HStack(spacing: 0) {
                    ForEach(weekDays, id: \.self) { day in
                        weekDayView(day)
                    }
                }
                .padding(.top, 20)

                // بطاقتا Streak و Freeze: الأرقام من الـ ViewModel وتتحدث تلقائياً
                HStack(spacing: 14) {
                    statCard(icon: "flame.fill", color: .appOrange,
                             value: "\(viewModel.streak) \(dayWord(viewModel.streak))",
                             label: "Learned")
                    statCard(icon: "snowflake", color: .appCyan,
                             value: "\(viewModel.freezesUsed) \(dayWord(viewModel.freezesUsed))",
                             label: "Freezed")
                }
                .padding(.top, 14)

                // الجزء الأسفل يتبدل حسب حالة الهدف.
                // الشريط والبطاقات فوق ثابتين، واللي يتغير بس الجزء اللي تحتهم.
                if viewModel.isActive {
                    // الهدف شغال: الشاشة العادية
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
                    .disabled(!viewModel.canLog)   // التعطيل يقرره الـ ViewModel
                    .frame(maxWidth: .infinity)

                    Spacer()

                    VStack(spacing: 14) {
                        // زر Freeze: نفس فكرة زر Log
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
                    // الهدف خلص (نجح أو انكسر الـ Streak): نفس الشاشة، الجزء الأوسط يتبدل
                    goalEndView(completed: viewModel.state == .completed)
                        .padding(.top, 70)   // المسافة تحت البطاقات (كانت تجي من Spacer)

                    Button {
                        // TODO: نرجع لـ Onboarding (نربطه مع الانتقال بين الشاشات)
                    } label: {
                        Label("Set a goal", systemImage: "pencil.and.outline")
                            .font(.system(size: 20, weight: .medium))
                            .padding(.horizontal, 20)
                            .padding(.vertical, 6)
                    }
                    .glassButton()
                    .buttonBorderShape(.capsule)
                    .frame(maxWidth: .infinity)
                    .padding(.top, 85 )   
                    Spacer()
                }
            }
            .padding(.horizontal, 16)
        }
    }

    // الجزء الأوسط لما الهدف خلص (أيقونة + عنوان + نص)
    private func goalEndView(completed: Bool) -> some View {
        VStack(spacing: 6) {                       // قرّبنا النصوص من بعض (كانت 8)
            Image(systemName: completed ? "hands.sparkles.fill" : "xmark.seal")
                .font(.system(size: 44))           // صغّرنا الأيقونة (كانت 56)
                .foregroundStyle(Color.appOrange)
                .padding(.bottom, 8)               // قرّبنا النص من الأيقونة (كان 20)
            Text(completed ? "Well done!" : "You didn't reach your goal this time.")
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(.white)
            Text(completed ? "Ready for your next goal?" : "Want to set another goal?")
                .font(.system(size: 17))
                .foregroundStyle(Color.appGray)
        }
        .frame(maxWidth: .infinity)
    }

    // أيقونة التقويم والهدف (الانتقال نربطه لاحقاً)
    private func circleIcon(_ name: String) -> some View {
        Button {
            // TODO: الانتقال للشاشة
        } label: {
            Image(systemName: name)
                .font(.system(size: 18))
                .frame(width: 28, height: 28)
        }
        .glassButton(selected: false)
        .buttonBorderShape(.circle)
    }

    // MARK: - يوم واحد في شريط الأسبوع
    // أهم فكرة: الدالة ما تعرف أي يوم تعلّمته. تسأل الـ ViewModel وتلوّن حسب الجواب.
    // شاشة التقويم الشهري بتسوي نفس الشي بالضبط.
    private func weekDayView(_ day: Date) -> some View {
        let isToday = calendar.isDate(day, inSameDayAs: today)
        let weekdayIndex = calendar.component(.weekday, from: day) - 1
        let letter = ["S", "M", "T", "W", "T", "F", "S"][weekdayIndex]   // ثابتة بالإنجليزي
        let number = calendar.component(.day, from: day)

        // السؤال الأهم: وش حالة هذا اليوم؟ (.learned / .frozen / nil)
        let status = viewModel.status(on: day)

        // لون الرقم حسب الحالة
        let textColor: Color = {
            if status == .frozen { return .appCyan }
            if status == .learned { return .appOrange }
            return .white
        }()

        // لون الخلفية. الترتيب مهم: نفحص الحالة المسجلة أول، وبعدها "اليوم"،
        // عشان لما تسجل اليوم يتغير من برتقالي ممتلئ إلى اللون الداكن.
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
// كل معاينة تصفّر السجل وتكتب بيانات مثل التصميم، فما تتأثر ببعضها.

// دالة مساعدة: تجهز السجل والوقت وترجع ViewModel جاهز
private func previewViewModel(
    daysAgo: [(Int, DayStatus)],   // (كم يوم قبل "اليوم"، الحالة)
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

// نجاح: 3 متعلَّم + 2 مجمّد (مثل التصميم)
#Preview("Goal completed") {
    let now = Date()
    let vm = previewViewModel(
        daysAgo: [(6, .learned), (5, .learned), (4, .learned), (2, .frozen), (1, .frozen)],
        streak: 3, freezes: 2, broken: false, startedDaysAgo: 8, now: now
    )
    return ActivityView(viewModel: vm)
}

// فشل: 2 متعلَّم + 2 مجمّد، وانكسر الـ Streak (مثل التصميم)
#Preview("Goal not met") {
    let now = Date()
    let vm = previewViewModel(
        daysAgo: [(4, .learned), (3, .learned), (1, .frozen), (0, .frozen)],
        streak: 2, freezes: 2, broken: true, startedDaysAgo: 5, now: now
    )
    return ActivityView(viewModel: vm)
}

// عادية: هدف جديد بدون تسجيل
#Preview("Active") {
    let now = Date()
    let vm = previewViewModel(
        daysAgo: [], streak: 0, freezes: 0, broken: false, startedDaysAgo: 0, now: now
    )
    return ActivityView(viewModel: vm)
}
