import SwiftUI

struct HomeView: View {
    @Environment(\.openURL) private var openURL
    @State private var showingSupportConfirmation = false
    @State private var showingWebsite = false
    @State private var supportStatus: String?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                HStack(spacing: 12) {
                    Image(systemName: "bolt.fill")
                        .font(.title2.weight(.bold))
                        .foregroundStyle(NIKNOLIGTheme.gold)
                        .frame(width: 48, height: 48)
                        .background(NIKNOLIGTheme.elevatedSurface, in: RoundedRectangle(cornerRadius: 16))
                    VStack(alignment: .leading, spacing: 2) {
                        Text("NIKNOLIG")
                            .font(.system(.headline, design: .rounded).weight(.heavy))
                            .tracking(1.8)
                            .foregroundStyle(NIKNOLIGTheme.text)
                        Text("DIGITAL LEARNING")
                            .font(NIKNOLIGTheme.labelFont)
                            .tracking(1.5)
                            .foregroundStyle(NIKNOLIGTheme.mutedText)
                    }
                    Spacer()
                    Text("iOS")
                        .font(NIKNOLIGTheme.labelFont)
                        .tracking(1)
                        .foregroundStyle(NIKNOLIGTheme.neonGreen)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 7)
                        .background(NIKNOLIGTheme.neonGreen.opacity(0.1), in: Capsule())
                }

                VStack(alignment: .leading, spacing: 10) {
                    Text("LERNEN.")
                        .foregroundStyle(NIKNOLIGTheme.gold)
                    Text("mit Energie.")
                        .foregroundStyle(NIKNOLIGTheme.text)
                    Text("Eine lokale Vorschau für Elektro-Engel.")
                        .font(.body)
                        .foregroundStyle(NIKNOLIGTheme.mutedText)
                }
                .font(NIKNOLIGTheme.displayFont)
                .padding(.vertical, 8)

                VStack(alignment: .leading, spacing: 18) {
                    Text("DEIN PRIVATER LERNRAUM")
                        .font(NIKNOLIGTheme.labelFont)
                        .tracking(1.4)
                        .foregroundStyle(NIKNOLIGTheme.gold)
                    featureRow(
                        "Antwortstil und Lernprofil bleiben auf diesem Gerät.",
                        symbol: "iphone",
                        color: NIKNOLIGTheme.gold
                    )
                    featureRow(
                        "Der Assistent sendet keine Eingaben an einen KI-Dienst.",
                        symbol: "lock.shield",
                        color: NIKNOLIGTheme.neonGreen
                    )
                    featureRow(
                        "Ein Backend-Test startet nur auf ausdrücklichen Tastendruck.",
                        symbol: "network",
                        color: NIKNOLIGTheme.gold
                    )
                }
                .padding(20)
                .niknoligCard()

                VStack(spacing: 12) {
                    Button {
                        showingWebsite = true
                    } label: {
                        Label("NIKNOLIG-Website", systemImage: "arrow.up.right")
                            .frame(maxWidth: .infinity, minHeight: 30)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(NIKNOLIGTheme.neonGreen)

                    Button {
                        showingSupportConfirmation = true
                    } label: {
                        Label("Technischen Support kontaktieren", systemImage: "envelope")
                            .frame(maxWidth: .infinity, minHeight: 30)
                    }
                    .buttonStyle(.bordered)
                    .tint(NIKNOLIGTheme.gold)
                }

                VStack(alignment: .leading, spacing: 10) {
                    Label("Deine Kontrolle bleibt bei dir", systemImage: "checkmark.shield")
                        .font(NIKNOLIGTheme.headingFont)
                        .foregroundStyle(NIKNOLIGTheme.text)
                    Text("Die App erstellt nach Bestätigung einen E-Mail-Entwurf. Sie versendet keine Nachricht und bietet kein Ticket-Tracking.")
                        .font(.footnote)
                        .foregroundStyle(NIKNOLIGTheme.mutedText)
                    if let supportStatus {
                        Text(supportStatus)
                            .font(.footnote.weight(.medium))
                            .foregroundStyle(NIKNOLIGTheme.neonGreen)
                            .accessibilityLiveRegion(.polite)
                    }
                }
                .padding(18)
                .niknoligCard()
            }
            .padding(.horizontal, 22)
            .padding(.top, 18)
            .padding(.bottom, 28)
        }
        .scrollIndicators(.hidden)
        .niknoligBackdrop()
        .niknoligNavigationStyle()
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingWebsite) {
            NavigationStack {
                OfficialWebsiteView()
            }
            .preferredColorScheme(.dark)
        }
        .confirmationDialog(
            "E-Mail-Entwurf öffnen?",
            isPresented: $showingSupportConfirmation,
            titleVisibility: .visible
        ) {
            Button("E-Mail-Entwurf öffnen") {
                guard let url = URL(string: "mailto:n_nold@hotmail.com") else {
                    supportStatus = "Der E-Mail-Link ist ungültig."
                    return
                }
                openURL(url) { accepted in
                    if accepted {
                        supportStatus = "Der Entwurf wurde an deine Mail-App übergeben. Die App kann den Versand nicht feststellen."
                    } else {
                        supportStatus = "Keine geeignete Mail-App verfügbar."
                    }
                }
            }
            Button("Abbrechen", role: .cancel) {}
        } message: {
            Text("NIKNOLIG öffnet nur einen E-Mail-Entwurf. Sende keine Passwörter oder Zahlungsdaten.")
        }
    }

    private func featureRow(_ title: String, symbol: String, color: Color) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: symbol)
                .font(.body.weight(.semibold))
                .foregroundStyle(color)
                .frame(width: 24)
                .accessibilityHidden(true)
            Text(title)
                .font(.subheadline)
                .foregroundStyle(NIKNOLIGTheme.text)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}
