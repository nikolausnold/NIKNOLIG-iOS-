import SwiftUI
import UIKit

private enum AppPalette {
    static let background = Color(red: 9 / 255, green: 11 / 255, blue: 10 / 255)
    static let surface = Color(red: 21 / 255, green: 24 / 255, blue: 21 / 255)
    static let outline = Color(red: 64 / 255, green: 58 / 255, blue: 40 / 255)
    static let gold = Color(red: 228 / 255, green: 182 / 255, blue: 78 / 255)
    static let green = Color(red: 185 / 255, green: 244 / 255, blue: 111 / 255)
    static let secondary = Color(red: 183 / 255, green: 189 / 255, blue: 184 / 255)
}

private enum ResponseStyle: String, CaseIterable, Identifiable {
    case concise
    case stepByStep = "step_by_step"
    case detailed

    var id: String { rawValue }

    var title: String {
        switch self {
        case .concise: "Kurz und knapp"
        case .stepByStep: "Schritt für Schritt"
        case .detailed: "Mit mehr Hintergrund"
        }
    }

    var preview: String {
        switch self {
        case .concise: "Vorschau: „Öffne die Einstellungen und wähle Bluetooth.“"
        case .stepByStep: "Vorschau:\n1. Öffne die Einstellungen.\n2. Tippe auf Bluetooth."
        case .detailed:
            "Vorschau: Öffne die Einstellungen, wähle Bluetooth und prüfe dort, ob Bluetooth eingeschaltet ist. So kannst du verfügbare Geräte in der Nähe anzeigen lassen."
        }
    }
}

private struct AppCard<Content: View>: View {
    @ViewBuilder var content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            content
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(AppPalette.surface, in: RoundedRectangle(cornerRadius: 18))
        .overlay {
            RoundedRectangle(cornerRadius: 18)
                .stroke(AppPalette.outline, lineWidth: 1)
        }
    }
}

private struct SectionHeading: View {
    let title: String

    var body: some View {
        Text(title)
            .font(.subheadline.weight(.bold))
            .tracking(1.2)
            .foregroundStyle(AppPalette.gold)
            .accessibilityAddTraits(.isHeader)
    }
}

private struct PrimaryActionStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.body.weight(.semibold))
            .foregroundStyle(AppPalette.background)
            .frame(maxWidth: .infinity, minHeight: 48)
            .background(
                AppPalette.green.opacity(configuration.isPressed ? 0.75 : 1),
                in: RoundedRectangle(cornerRadius: 12)
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
    }
}

private extension View {
    func screenBackground() -> some View {
        background(AppPalette.background.ignoresSafeArea())
            .tint(AppPalette.gold)
    }

    func screenPadding() -> some View {
        padding(.horizontal, 24)
    }
}

struct HomeView: View {
    @State private var showingMailUnavailable = false

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        HStack(spacing: 10) {
                            LogoMark()
                                .frame(width: 40, height: 40)
                            Text("NIKNOLIG")
                                .font(.subheadline.weight(.bold))
                                .tracking(2)
                                .foregroundStyle(AppPalette.green)
                                .accessibilityAddTraits(.isHeader)
                        }

                        VStack(alignment: .leading, spacing: 8) {
                            Text("Elektro-Engel")
                                .font(.largeTitle.bold())
                                .foregroundStyle(.white)
                                .accessibilityAddTraits(.isHeader)
                            Text("Deine Assistenz für nachvollziehbare, kontrollierte Technik.")
                                .font(.body)
                                .foregroundStyle(AppPalette.secondary)
                        }

                        AppCard {
                            SectionHeading(title: "SYSTEMSTATUS")
                            Text("Entwicklungsgerüst")
                                .font(.title2.bold())
                                .foregroundStyle(AppPalette.green)
                            Text("Keine Geräte verbunden")
                                .font(.body)
                                .foregroundStyle(.white)
                            NavigationLink {
                                LearningProfileView()
                            } label: {
                                Text("Lernprofil und Datenschutz")
                            }
                            .buttonStyle(PrimaryActionStyle())
                            .padding(.top, 4)
                        }

                        AppCard {
                            SectionHeading(title: "TECHNISCHER SUPPORT")
                            Text("Bei technischen Fragen erreichst du uns unter n_nold@hotmail.com.")
                                .foregroundStyle(.white)
                            Text("Zahlungsfragen werden hier nicht bearbeitet. Bitte wende dich dafür direkt an den Zahlungsanbieter oder Händler. Sende keine Zahlungsdaten an den technischen Support.")
                                .font(.subheadline)
                                .foregroundStyle(AppPalette.secondary)
                            Button(action: contactSupport) {
                                Text("Technischen Support kontaktieren")
                            }
                            .buttonStyle(PrimaryActionStyle())
                            .padding(.top, 4)
                        }

                        AppCard {
                            Text("Vorschau – noch keine Geräteverbindung, Sicherheitsfreigabe oder produktive Funktion.")
                                .foregroundStyle(.white)
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 16)
                    .padding(.bottom, 104)
                }

                NavigationLink {
                    AssistantView()
                } label: {
                    Label("Elektro-Engel öffnen", systemImage: "sparkles")
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(AppPalette.background)
                        .padding(.horizontal, 18)
                        .frame(height: 52)
                        .background(AppPalette.green, in: Capsule())
                        .shadow(color: .black.opacity(0.45), radius: 12, y: 5)
                }
                .padding(20)
                .accessibilityHint("Öffnet die lokale Assistenzvorschau")
            }
            .screenBackground()
            .toolbar(.hidden, for: .navigationBar)
            .alert("Keine E-Mail-App gefunden.", isPresented: $showingMailUnavailable) {
                Button("OK", role: .cancel) {}
            }
        }
    }

    private func contactSupport() {
        var components = URLComponents()
        components.scheme = "mailto"
        components.path = "n_nold@hotmail.com"
        components.queryItems = [
            URLQueryItem(name: "subject", value: "Technische Supportanfrage – NIKNOLIG"),
            URLQueryItem(
                name: "body",
                value: "Bitte beschreibe dein technisches Problem. Sende keine Passwörter oder Zahlungsdaten."
            ),
        ]

        guard let url = components.url else {
            showingMailUnavailable = true
            return
        }

        UIApplication.shared.open(url) { success in
            if !success {
                showingMailUnavailable = true
            }
        }
    }
}

private struct LogoMark: View {
    var body: some View {
        ZStack {
            Ellipse()
                .stroke(AppPalette.green.opacity(0.8), lineWidth: 1.5)
                .frame(width: 34, height: 20)
                .rotationEffect(.degrees(-30))
            Text("N")
                .font(.system(size: 25, weight: .bold, design: .rounded))
                .foregroundStyle(AppPalette.green)
            Circle()
                .fill(AppPalette.green)
                .frame(width: 5, height: 5)
                .offset(x: 15, y: -13)
        }
        .accessibilityHidden(true)
    }
}

private struct AssistantView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var request = ""
    @State private var requestStatus = ""
    @State private var backendStatus = ""
    @State private var isCheckingBackend = false

    private var backendBaseURL: String {
        Bundle.main.object(forInfoDictionaryKey: "BackendBaseURL") as? String ?? ""
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                Text("Elektro-Engel")
                    .font(.largeTitle.bold())
                    .accessibilityAddTraits(.isHeader)
                Text("Lokale Vorschau innerhalb von NIKNOLIG. Deine Anfrage wird nicht an einen KI-Dienst oder Server gesendet.")
                    .foregroundStyle(AppPalette.secondary)

                SectionHeading(title: "WOBEI BRAUCHST DU HILFE?")
                Text("Gib eine Anfrage ein. Diese Vorschau zeigt sie nur hier an und erstellt keine automatische Antwort.")
                    .foregroundStyle(.white)
                NavigationLink {
                    LearningProfileView()
                } label: {
                    Text("Lernprofil und Datenschutz")
                }
                .buttonStyle(PrimaryActionStyle())

                TextField("Deine Anfrage (max. 500 Zeichen)", text: $request, axis: .vertical)
                    .lineLimit(4...7)
                    .padding(12)
                    .background(AppPalette.surface, in: RoundedRectangle(cornerRadius: 12))
                    .overlay {
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(AppPalette.outline, lineWidth: 1)
                    }
                    .onChange(of: request) { _, value in
                        if value.count > 500 {
                            request = String(value.prefix(500))
                        }
                    }
                    .accessibilityLabel("Deine Anfrage, maximal 500 Zeichen")

                Button {
                    let trimmedRequest = request.trimmingCharacters(in: .whitespacesAndNewlines)
                    requestStatus = trimmedRequest.isEmpty
                        ? "Bitte gib zuerst eine Anfrage ein."
                        : "Anfrage, nur hier angezeigt:\n\(trimmedRequest)\n\nEs wurde nichts übertragen und keine Aktion ausgeführt."
                } label: {
                    Text("Anfrage lokal anzeigen")
                }
                .buttonStyle(PrimaryActionStyle())

                if !requestStatus.isEmpty {
                    Text(requestStatus)
                        .foregroundStyle(.white)
                        .accessibilityLiveRegion(.polite)
                }

                SectionHeading(title: "AUFGABEN")
                    .padding(.top, 8)
                Text("Keine Aufgaben verfügbar. Eine Aufgabenverwaltung ist in dieser Vorschau nicht eingerichtet.")
                    .foregroundStyle(.white)

                SectionHeading(title: "GERÄTESTATUS")
                    .padding(.top, 8)
                Text("Unbekannt: Diese Vorschau erkennt keine Geräte und prüft keine Verbindungen.")
                    .foregroundStyle(.white)

                SectionHeading(title: "WARNUNGEN UND SICHERHEIT")
                    .padding(.top, 8)
                Text("Es gibt keine Geräteüberwachung oder automatische Warnungen. Erkennen, Verbinden und Steuern sind nicht verfügbar. Es werden keine Steuerbefehle gesendet.")
                    .foregroundStyle(.white)

                Button {
                    Task { await checkBackend() }
                } label: {
                    HStack {
                        if isCheckingBackend {
                            ProgressView()
                                .tint(AppPalette.background)
                        }
                        Text("Backend-Testverbindung prüfen")
                    }
                }
                .buttonStyle(PrimaryActionStyle())
                .disabled(backendBaseURL.isEmpty || isCheckingBackend)
                .padding(.top, 6)

                Text(backendStatus)
                    .font(.subheadline)
                    .foregroundStyle(AppPalette.secondary)
                    .accessibilityLiveRegion(.polite)

                Button("Zurück zu NIKNOLIG") {
                    dismiss()
                }
                .buttonStyle(PrimaryActionStyle())
            }
            .screenPadding()
            .padding(.top, 20)
            .padding(.bottom, 32)
        }
        .screenBackground()
        .toolbar(.hidden, for: .navigationBar)
        .onAppear {
            backendStatus = backendBaseURL.isEmpty
                ? "Backend nicht konfiguriert. Alle Vorschaufunktionen bleiben lokal."
                : "Optionaler Verbindungstest: Nur der Serverstatus wird abgefragt, keine Eingaben oder Profildaten werden gesendet."
        }
    }

    @MainActor
    private func checkBackend() async {
        guard !backendBaseURL.isEmpty else { return }
        isCheckingBackend = true
        backendStatus = "Testverbindung wird geprüft …"
        let healthy = await BackendHealthClient.check(baseURL: backendBaseURL)
        backendStatus = healthy
            ? "Sandbox erreichbar. KI, Profilsynchronisierung und Geräteaktionen bleiben deaktiviert."
            : "Testverbindung nicht verfügbar oder inkompatibel. Lokale Funktionen bleiben unverändert."
        isCheckingBackend = false
    }
}

private struct LearningProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("learning_enabled") private var learningEnabled = false
    @AppStorage("response_style") private var responseStyleRaw = ResponseStyle.concise.rawValue
    @AppStorage("helpful_count") private var helpfulCount = 0
    @AppStorage("unclear_count") private var unclearCount = 0
    @AppStorage("correction_count") private var correctionCount = 0
    @AppStorage("session_summary") private var sessionSummary = ""
    @State private var summaryDraft = ""
    @State private var summaryStatus = ""
    @State private var showingDeleteConfirmation = false

    private var responseStyle: ResponseStyle {
        ResponseStyle(rawValue: responseStyleRaw) ?? .concise
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Button {
                    dismiss()
                } label: {
                    Label("Zurück", systemImage: "chevron.left")
                }
                .foregroundStyle(AppPalette.green)

                VStack(alignment: .leading, spacing: 8) {
                    Text("Lernprofil")
                        .font(.largeTitle.bold())
                        .accessibilityAddTraits(.isHeader)
                    Text("Lege fest, wie Elektro-Engel dir antworten soll und ob einfache Rückmeldungen lokal gezählt werden dürfen.")
                        .foregroundStyle(AppPalette.secondary)
                }

                AppCard {
                    SectionHeading(title: "SITZUNG FORTSETZEN")
                    Text("Erstelle selbst eine kurze Zusammenfassung (max. 500 Zeichen), die du später wieder aufgreifen kannst. Sie wird nur nach Tippen auf „Zusammenfassung speichern“ lokal abgelegt. Bitte keine Passwörter, Zahlungsdaten oder andere sensible Angaben eintragen. Elektro-Engel verwendet sie in dieser Vorschau noch nicht automatisch.")
                        .font(.subheadline)
                        .foregroundStyle(.white)
                    TextField("Worum geht es, und was ist der nächste Schritt?", text: $summaryDraft, axis: .vertical)
                        .lineLimit(4...7)
                        .padding(12)
                        .background(AppPalette.background, in: RoundedRectangle(cornerRadius: 12))
                        .onChange(of: summaryDraft) { _, value in
                            if value.count > 500 {
                                summaryDraft = String(value.prefix(500))
                            }
                        }
                        .accessibilityLabel("Sitzungszusammenfassung, maximal 500 Zeichen")
                    if !summaryStatus.isEmpty {
                        Text(summaryStatus)
                            .font(.subheadline)
                            .foregroundStyle(AppPalette.secondary)
                            .accessibilityLiveRegion(.polite)
                    }
                    Button("Zusammenfassung speichern", action: saveSummary)
                        .buttonStyle(PrimaryActionStyle())
                }

                AppCard {
                    SectionHeading(title: "MENSCHEN ZUERST")
                    Text("Menschen fühlen – Technik soll unterstützen, nicht über Menschen bestimmen. Elektro-Engel antwortet standardmäßig kurz, fragt bei Unsicherheit nach und bleibt bei wichtigen Themen vorsichtig. Rückmeldungen ändern Antworten nicht automatisch.")
                        .font(.subheadline)
                        .foregroundStyle(.white)
                }

                AppCard {
                    SectionHeading(title: "DEINE DATEN BLEIBEN LOKAL")
                    Text("Diese Vorschau speichert deine gewählte Erklärungsart und – nur nach deiner Zustimmung – Gesamtzahlen für Feedback. Eine Sitzungskurzfassung speichert nur, was du bewusst eingibst. Es werden keine Gesprächsverläufe, Zeitpunkte oder Gerätekennungen gespeichert oder übertragen. Alles bleibt bis zum Löschen oder zur Deinstallation auf diesem Gerät. Die Zähler trainieren kein Modell und verändern keine Antworten.")
                        .font(.subheadline)
                        .foregroundStyle(.white)
                    Toggle("Lokale Rückmeldungen freiwillig zählen", isOn: $learningEnabled)
                        .tint(AppPalette.green)
                        .padding(.top, 4)
                }

                AppCard {
                    SectionHeading(title: "BEVORZUGTE ERKLÄRUNG")
                    ForEach(ResponseStyle.allCases) { style in
                        Button {
                            responseStyleRaw = style.rawValue
                        } label: {
                            HStack(spacing: 12) {
                                Image(systemName: responseStyle == style ? "largecircle.fill.circle" : "circle")
                                    .foregroundStyle(responseStyle == style ? AppPalette.green : AppPalette.secondary)
                                Text(style.title)
                                    .foregroundStyle(.white)
                                Spacer()
                            }
                            .frame(minHeight: 42)
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        .accessibilityAddTraits(responseStyle == style ? .isSelected : [])
                    }
                    Text(responseStyle.preview)
                        .font(.subheadline)
                        .foregroundStyle(AppPalette.secondary)
                        .padding(.top, 4)
                }

                AppCard {
                    SectionHeading(title: "FREIWILLIGE RÜCKMELDUNG")
                    Text("Teste die Rückmeldung an einer Beispielantwort. Gespeichert wird nur die jeweilige Gesamtzahl, und nur wenn du oben zugestimmt hast. Eine Korrektur wird nicht als Text gespeichert.")
                        .font(.subheadline)
                        .foregroundStyle(.white)
                    Text("Lokal gezählt: hilfreich \(helpfulCount) · unklar \(unclearCount) · Korrektur nötig \(correctionCount)")
                        .font(.subheadline)
                        .foregroundStyle(AppPalette.secondary)

                    feedbackButton("Beispiel: hilfreich", count: $helpfulCount)
                    feedbackButton("Beispiel: unklar", count: $unclearCount)
                    feedbackButton("Beispiel: Korrektur nötig", count: $correctionCount)
                }

                Button(role: .destructive) {
                    showingDeleteConfirmation = true
                } label: {
                    Text("Lernprofil, Zusammenfassung und Zähler löschen")
                }
                .buttonStyle(PrimaryActionStyle())
                .confirmationDialog(
                    "Lernprofil löschen?",
                    isPresented: $showingDeleteConfirmation,
                    titleVisibility: .visible
                ) {
                    Button("Löschen", role: .destructive, action: clearLearningData)
                    Button("Abbrechen", role: .cancel) {}
                } message: {
                    Text("Deine gespeicherte Erklärungsart, Sitzungskurzfassung und alle Rückmeldezähler werden von diesem Gerät gelöscht. Das lokale Zählen wird ausgeschaltet.")
                }
            }
            .screenPadding()
            .padding(.top, 16)
            .padding(.bottom, 32)
        }
        .screenBackground()
        .toolbar(.hidden, for: .navigationBar)
        .onAppear {
            summaryDraft = sessionSummary
        }
    }

    private func feedbackButton(_ title: String, count: Binding<Int>) -> some View {
        Button(title) {
            guard learningEnabled else { return }
            count.wrappedValue += 1
        }
        .buttonStyle(PrimaryActionStyle())
        .disabled(!learningEnabled)
    }

    private func saveSummary() {
        let summary = summaryDraft.trimmingCharacters(in: .whitespacesAndNewlines)
        if summary.isEmpty {
            sessionSummary = ""
            summaryStatus = "Leere Zusammenfassung – gespeicherte Fassung entfernt."
        } else {
            sessionSummary = String(summary.prefix(500))
            summaryDraft = sessionSummary
            summaryStatus = "Zusammenfassung lokal gespeichert."
        }
    }

    private func clearLearningData() {
        learningEnabled = false
        responseStyleRaw = ResponseStyle.concise.rawValue
        helpfulCount = 0
        unclearCount = 0
        correctionCount = 0
        sessionSummary = ""
        summaryDraft = ""
        summaryStatus = "Zusammenfassung und Lernprofil gelöscht."
    }
}
