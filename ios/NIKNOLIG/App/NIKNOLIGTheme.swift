import SwiftUI

enum NIKNOLIGTheme {
    static let background = Color(hex: 0x08090D)
    static let surface = Color(hex: 0x12151C)
    static let elevatedSurface = Color(hex: 0x191D26)
    static let gold = Color(hex: 0xF4C95D)
    static let neonGreen = Color(hex: 0x39F58A)
    static let text = Color(hex: 0xF2F2F5)
    static let mutedText = Color(hex: 0xA2A7B2)
    static let border = Color.white.opacity(0.09)
    static let cornerRadius: CGFloat = 22

    static let displayFont = Font.system(.largeTitle, design: .rounded).weight(.bold)
    static let headingFont = Font.system(.title3, design: .rounded).weight(.semibold)
    static let labelFont = Font.system(.caption, design: .rounded).weight(.semibold)
}

private extension Color {
    init(hex: UInt32) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: 1
        )
    }
}

extension View {
    func niknoligBackdrop() -> some View {
        background {
            ZStack(alignment: .topTrailing) {
                NIKNOLIGTheme.background
                RadialGradient(
                    colors: [NIKNOLIGTheme.gold.opacity(0.12), .clear],
                    center: .topTrailing,
                    startRadius: 12,
                    endRadius: 300
                )
                RadialGradient(
                    colors: [NIKNOLIGTheme.neonGreen.opacity(0.06), .clear],
                    center: .bottomLeading,
                    startRadius: 0,
                    endRadius: 260
                )
            }
            .ignoresSafeArea()
        }
    }

    func niknoligCard() -> some View {
        background(NIKNOLIGTheme.surface, in: RoundedRectangle(cornerRadius: NIKNOLIGTheme.cornerRadius))
            .overlay {
                RoundedRectangle(cornerRadius: NIKNOLIGTheme.cornerRadius)
                    .strokeBorder(NIKNOLIGTheme.border, lineWidth: 1)
            }
    }

    func niknoligNavigationStyle() -> some View {
        toolbarColorScheme(.dark, for: .navigationBar)
            .toolbarBackground(NIKNOLIGTheme.background, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
}
