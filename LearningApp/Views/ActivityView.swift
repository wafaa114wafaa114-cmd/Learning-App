import SwiftUI

struct ActivityView: View {
    private let cardGray = Color(red: 0.07, green: 0.07, blue: 0.07)

    // أرقام ثابتة مؤقتة، نبدلها بقيم من ActivityViewModel لاحقاً
    private let streak = 4
    private let freezes = 0
    private let maxFreezes = 2

    private let calendar: Calendar = {
        var c = Calendar(identifier: .gregorian)
        c.firstWeekday = 1 // الأحد
        return c
    }()

    private var today: Date { Date() }

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
                        circleIcon("calendar")
                        circleIcon("pencil.and.outline")
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
                             value: "\(streak) \(dayWord(streak))", label: "Learned")
                    statCard(icon: "snowflake", color: .appCyan,
                             value: "\(freezes) \(dayWord(freezes))", label: "Freezed")
                }
                
                .padding(.top, 14)

                Spacer()

                Button {
                    // نربطه بالمنطق لاحقاً
                } label: {
                    Text("Log as Learned")
                        .font(.system(size: 22, weight: .bold))
                        .frame(width: 290, height: 290)
                }
                .glassButton()
                .buttonBorderShape(.circle)
                .frame(maxWidth: .infinity)

                Spacer()

                VStack(spacing: 14) {
                    Button {
                        // نربطه بالمنطق لاحقاً
                    } label: {
                        Text("Freeze for a day")
                            .font(.system(size: 20, weight: .medium))
                            .frame(width: 290, height: 50)
                    }
                    .glassButton(tint: .appCyan)
                    .buttonBorderShape(.capsule)

                    Text("\(freezes) out of \(maxFreezes) Freezes used")
                        .font(.system(size: 14))
                        .foregroundStyle(Color.appGray)
                }
                .frame(maxWidth: .infinity)
                .padding(.bottom, 30)
            }
            .padding(.horizontal, 16)
        }
    }

    // أيقونة الهدف والتقويم: أزرار زجاجية دائرية داكنة
    private func circleIcon(_ name: String) -> some View {
        Button {
            // نربطها بالانتقال لاحقاً
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
        let isPast = day < calendar.startOfDay(for: today)
        let weekdayIndex = calendar.component(.weekday, from: day) - 1
        let letter = ["S", "M", "T", "W", "T", "F", "S"][weekdayIndex]
        let number = calendar.component(.day, from: day)

        return VStack(spacing: 8) {
            Text(letter)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(.white)
            Text("\(number)")
                .font(.system(size: 22, weight: .medium))
                .foregroundStyle(isToday ? Color.white : (isPast ? Color.appOrange : Color.white))
                .frame(width: 44, height: 44)
                .background(
                    Circle().fill(
                        isToday ? Color.appOrange :
                        (isPast ? Color(red: 0.16, green: 0.10, blue: 0.05) : Color.clear)
                    )
                )
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

#Preview {
    ActivityView()
}
