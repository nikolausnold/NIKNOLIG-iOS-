import SwiftUI
import WebKit
import NIKNOLIGCore

struct OfficialWebsiteView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL
    @State private var loadState: WebsiteLoadState = .loading
    @State private var reloadID = 0

    var body: some View {
        ZStack {
            WebsiteWebView(
                url: OfficialWebsite.url,
                reloadID: reloadID,
                loadState: $loadState,
                onOpenExternalURL: openExternalURL
            )

            switch loadState {
            case .loading:
                ProgressView("Website wird geladen …")
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(.background.opacity(0.9))
            case .loaded:
                EmptyView()
            case .failed(let message):
                VStack(spacing: 16) {
                    Label("Website nicht verfügbar", systemImage: "wifi.exclamationmark")
                        .font(.headline)
                    Text(message)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.secondary)
                    Button("Erneut versuchen") {
                        reloadID += 1
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(.background)
            }
        }
        .navigationTitle("Website")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Schließen") {
                    dismiss()
                }
            }
        }
    }

    private func openExternalURL(_ url: URL) {
        let isHTTPS = url.scheme?.lowercased() == "https"
            && url.host != nil
            && url.user == nil
            && url.password == nil
        let isEmail = url.scheme?.lowercased() == "mailto"
            && !url.path.isEmpty
            && url.host == nil

        guard isHTTPS || isEmail else {
            loadState = .failed("Dieser unsichere oder ungültige Link wurde blockiert.")
            return
        }

        openURL(url) { accepted in
            if !accepted {
                loadState = .failed("Der externe Link konnte nicht geöffnet werden.")
            } else if case .loading = loadState {
                loadState = .failed("Die Website hat zu einem externen Link weitergeleitet, der in Safari geöffnet wurde.")
            }
        }
    }
}

private enum WebsiteLoadState {
    case loading
    case loaded
    case failed(String)
}

private struct WebsiteWebView: UIViewRepresentable {
    let url: URL
    let reloadID: Int
    @Binding var loadState: WebsiteLoadState
    let onOpenExternalURL: (URL) -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(loadState: $loadState, onOpenExternalURL: onOpenExternalURL)
    }

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView(frame: .zero)
        webView.navigationDelegate = context.coordinator
        webView.uiDelegate = context.coordinator
        context.coordinator.load(url, reloadID: reloadID, in: webView)
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        context.coordinator.update(loadState: $loadState, onOpenExternalURL: onOpenExternalURL)
        if context.coordinator.reloadID != reloadID {
            context.coordinator.load(url, reloadID: reloadID, in: webView)
        }
    }

    final class Coordinator: NSObject, WKNavigationDelegate, WKUIDelegate {
        private var loadState: Binding<WebsiteLoadState>
        private var onOpenExternalURL: (URL) -> Void
        private(set) var reloadID: Int?

        init(loadState: Binding<WebsiteLoadState>, onOpenExternalURL: @escaping (URL) -> Void) {
            self.loadState = loadState
            self.onOpenExternalURL = onOpenExternalURL
        }

        func update(
            loadState: Binding<WebsiteLoadState>,
            onOpenExternalURL: @escaping (URL) -> Void
        ) {
            self.loadState = loadState
            self.onOpenExternalURL = onOpenExternalURL
        }

        func load(_ url: URL, reloadID: Int, in webView: WKWebView) {
            self.reloadID = reloadID
            loadState.wrappedValue = .loading
            var request = URLRequest(url: url)
            request.timeoutInterval = 30
            webView.load(request)
        }

        func webView(
            _ webView: WKWebView,
            decidePolicyFor navigationAction: WKNavigationAction,
            decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
        ) {
            guard let url = navigationAction.request.url else {
                decisionHandler(.cancel)
                return
            }

            if isOfficialHTTPSURL(url) {
                decisionHandler(.allow)
            } else {
                onOpenExternalURL(url)
                decisionHandler(.cancel)
            }
        }

        func webView(
            _ webView: WKWebView,
            decidePolicyFor navigationResponse: WKNavigationResponse,
            decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void
        ) {
            guard navigationResponse.isForMainFrame,
                  let url = navigationResponse.response.url
            else {
                decisionHandler(.allow)
                return
            }

            guard isOfficialHTTPSURL(url) else {
                onOpenExternalURL(url)
                decisionHandler(.cancel)
                return
            }

            if let response = navigationResponse.response as? HTTPURLResponse,
               response.statusCode >= 400 {
                loadState.wrappedValue = .failed(
                    "Die Website hat einen Fehler gemeldet (HTTP \(response.statusCode))."
                )
                decisionHandler(.cancel)
                return
            }

            decisionHandler(.allow)
        }

        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation?) {
            loadState.wrappedValue = .loading
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation?) {
            loadState.wrappedValue = .loaded
        }

        func webView(
            _ webView: WKWebView,
            didFailProvisionalNavigation navigation: WKNavigation?,
            withError error: Error
        ) {
            show(error)
        }

        func webView(
            _ webView: WKWebView,
            didFail navigation: WKNavigation?,
            withError error: Error
        ) {
            show(error)
        }

        func webView(
            _ webView: WKWebView,
            createWebViewWith configuration: WKWebViewConfiguration,
            for navigationAction: WKNavigationAction,
            windowFeatures: WKWindowFeatures
        ) -> WKWebView? {
            if let url = navigationAction.request.url {
                onOpenExternalURL(url)
            }
            return nil
        }

        private func isOfficialHTTPSURL(_ url: URL) -> Bool {
            url.scheme?.lowercased() == "https"
                && url.host?.lowercased() == OfficialWebsite.url.host
                && url.user == nil
                && url.password == nil
        }

        private func show(_ error: Error) {
            let error = error as NSError
            guard error.code != NSURLErrorCancelled else { return }

            let message: String
            switch error.code {
            case NSURLErrorNotConnectedToInternet, NSURLErrorNetworkConnectionLost:
                message = "Keine Internetverbindung. Prüfe deine Verbindung und versuche es erneut."
            case NSURLErrorCannotFindHost, NSURLErrorDNSLookupFailed:
                message = "Die Website-Adresse konnte nicht gefunden werden. Versuche es später erneut."
            case NSURLErrorSecureConnectionFailed, NSURLErrorServerCertificateUntrusted,
                 NSURLErrorServerCertificateHasBadDate, NSURLErrorServerCertificateHasUnknownRoot,
                 NSURLErrorServerCertificateNotYetValid:
                message = "Die sichere HTTPS-Verbindung ist fehlgeschlagen. Die Verbindung wurde nicht umgangen."
            case NSURLErrorTimedOut:
                message = "Das Laden hat zu lange gedauert. Prüfe deine Verbindung und versuche es erneut."
            default:
                message = "Die Website konnte nicht geladen werden. Prüfe deine Verbindung und versuche es erneut."
            }
            loadState.wrappedValue = .failed(message)
        }
    }
}
