import SwiftUI

extension Color {
    static let appOrange = Color(red: 1.0, green: 0.57, blue: 0.19)
    static let appCyan = Color(red: 0.40, green: 0.80, blue: 0.97)
    static let appGray = Color(red: 0.6, green: 0.6, blue: 0.6)
}

extension View {
    @ViewBuilder
    func glassButton(selected: Bool = true, tint: Color = .appOrange) -> some View {
        if selected {
            self
                .buttonStyle(.glassProminent)
                .tint(tint.opacity(1.0))
                .brightness(0.12)
                .saturation(1.15)
        } else {
            self
                .buttonStyle(.glass)
                .environment(\.colorScheme, .dark)
        }
    }
}
