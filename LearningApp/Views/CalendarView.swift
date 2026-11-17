import SwiftUI

struct CalendarView: View {
    @State private var viewModel = CalendarViewModel()

    // الرجوع نربطه لاحقاً بالانتقال بين الشاشات
    var onBack: () -> Void = {}

    private let weekdayLabels = ["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"]
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 0), count: 7)

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 0) {

                // الشريط العلوي: رجوع + عنوان
                ZStack {
                    Text("Activities")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(.white)

                    HStack {
                        Button {
                            onBack()
                        } label: {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 17, weight: .semibold))
                                .frame(width: 28, height: 28)
                        }
                        .glassButton(selected: false)
                        .buttonBorderShape(.circle)

                        Spacer()
                    }
                }
                .padding(.horizontal, 16)

                // الأشهر: تتمرر عمودياً، وتفتح على الشهر الحالي
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 0) {
                            ForEach(viewModel.months, id: \.self) { month in
                                monthView(month)
                                    .id(month)
                            }
                        }
                    }
                    .onAppear {
                        proxy.scrollTo(viewModel.currentMonth, anchor: .top)
                    }
                }
            }
        }
    }

    // شهر كامل: فاصل + العنوان + أيام الأسبوع + الشبكة
    private func monthView(_ month: Date) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Rectangle()
                .fill(Color.white.opacity(0.12))
                .frame(height: 1)

            Text(viewModel.title(for: month))
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(.white)
                .padding(.top, 20)
                .padding(.horizontal, 16)

            // SUN MON TUE ...
            HStack(spacing: 0) {
                ForEach(weekdayLabels, id: \.self) { label in
                    Text(label)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(Color.appGray)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.top, 16)
            .padding(.horizontal, 16)

            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(Array(viewModel.cells(for: month).enumerated()), id: \.offset) { _, day in
                    if let day {
                        dayView(day)
                    } else {
                        Color.clear.frame(width: 44, height: 44)
                    }
                }
            }
            .padding(.top, 12)
            .padding(.horizontal, 16)
            .padding(.bottom, 24)
        }
    }

    // يوم واحد: نفس ألوان شريط الأسبوع. الحالة المسجلة أول، وبعدها "اليوم".
    private func dayView(_ day: Date) -> some View {
        let status = viewModel.status(on: day)

        let textColor: Color = {
            if status == .frozen { return .appCyan }
            if status == .learned { return .appOrange }
            return .white
        }()

        let fillColor: Color = {
            if status == .learned { return Color(red: 0.22, green: 0.13, blue: 0.05) }
            if status == .frozen { return Color(red: 0.05, green: 0.15, blue: 0.20) }
            if viewModel.isToday(day) { return .appOrange }
            return .clear
        }()

        return Text("\(viewModel.dayNumber(day))")
            .font(.system(size: 20, weight: .medium))
            .foregroundStyle(viewModel.isToday(day) && status == nil ? Color.white : textColor)
            .frame(width: 44, height: 44)
            .background(Circle().fill(fillColor))
    }
}

#Preview {
    CalendarView()
}
