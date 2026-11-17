import Foundation

enum Duration: String, CaseIterable {
    case week = "Week"
    case month = "Month"
    case year = "Year"

    // عدد الـ Freezes الكلي طول مدة الهدف
    var maxFreezes: Int {
        switch self {
        case .week: return 2
        case .month: return 8
        case .year: return 96
        }
    }
    
    // مكوّن التقويم اللي نضيفه على تاريخ البداية لنحصل على نهاية الهدف
        var calendarComponent: (Calendar.Component, Int) {
            switch self {
            case .week: return (.day, 7)
            case .month: return (.month, 1)
            case .year: return (.year, 1)
            }
        }
    }

