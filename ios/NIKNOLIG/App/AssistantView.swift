import NIKNOLIGCore
import SwiftUI

struct AssistantView: View {
    @AppStorage("backendOrigin") private var backendOrigin = ""
    @State private var requestText = ""
    @State private var healthStatus = "Nicht geprüft."
    @State private var isCheckingHealth = false
    @State private var healthTask: Task<Void, Never>?

    var body: some View {
        Form {
            Section {
                Text("Die Eingabe wird nur auf diesem Bildschirm angezeigt. Es gibt keinen aktiven KI-Dienst und keine automatische Übertragung.")
                    .font(.footnote)
                    .foregroundStyle(NIKNOLIGTheme.mutedText)
                TextField("Wobei brauchst du Unterstützung?", text: $requestText, axis: .vertical)
                    .lineLimit(3...6)
                    .accessibilityLabel("Lokale Vorschau-Eingabe")
            } header: {
                Text("Elektro-Engel Vorschau")
                    .foregroundStyle(NIKNOLIGTheme.gold)
            }
            .listRowBackground(NIKNOLIGTheme.surface)

            Section {
                Text("Nur ein HTTPS-Health-GET zu einer von dir angegebenen Serveradresse. Keine Anmeldung, Nutzereingabe oder Profildaten werden übertragen.")
                    .font(.footnote)
                    .foregroundStyle(NIKNOLIGTheme.mutedText)
                TextField("https://server.example", text: $backendOrigin)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .keyboardType(.URL)
                    .accessibilityLabel("HTTPS-Ursprung des Sandbox-Backends")
                Button {
                    checkBackendHealth()
                } label: {
                    if isCheckingHealth {
                        ProgressView("Prüfe Verbindung …")
                            .tint(NIKNOLIGTheme.background)
                    } else {
                        Text("Verbindung ausdrücklich prüfen")
                    }
                }
                .disabled(isCheckingHealth || backendOrigin.isEmpty)
                .buttonStyle(.borderedProminent)
                .tint(NIKNOLIGTheme.neonGreen)
                Text(healthStatus)
                    .font(.footnote)
                    .foregroundStyle(NIKNOLIGTheme.mutedText)
                    .accessibilityLiveRegion(.polite)
            } header: {
                Text("Optionaler Sandbox-Verbindungstest")
                    .foregroundStyle(NIKNOLIGTheme.gold)
            }
            .listRowBackground(NIKNOLIGTheme.surface)
        }
        .scrollContentBackground(.hidden)
        .niknoligBackdrop()
        .niknoligNavigationStyle()
        .tint(NIKNOLIGTheme.neonGreen)
        .navigationTitle("Elektro-Engel")
        .navigationBarTitleDisplayMode(.inline)
        .onDisappear {
            healthTask?.cancel()
        }
    }

    private func checkBackendHealth() {
        healthTask?.cancel()
        isCheckingHealth = true
        healthStatus = "Verbindung wird geprüft …"
        healthTask = Task {
            let result: String
            do {
                let endpoint = try BackendEndpoint(baseURL: backendOrigin)
                let isHealthy = try await BackendHealthClient(endpoint: endpoint).checkHealth()
                result = isHealthy
                    ? "Sandbox erreichbar. Das bestätigt nur den Health-Endpunkt."
                    : "Keine gültige Sandbox-Antwort erhalten."
            } catch is CancellationError {
                result = "Prüfung abgebrochen."
            } catch BackendEndpointError.invalidHTTPSOrigin {
                result = "Ungültig: Nur ein HTTPS-Ursprung ohne Port, Pfad, Zugangsdaten oder Zusätze ist erlaubt."
            } catch {
                result = "Sandbox nicht erreichbar. Lokale Funktionen bleiben verfügbar."
            }
            guard !Task.isCancelled else { return }
            healthStatus = result
            isCheckingHealth = false
        }
    }
}
