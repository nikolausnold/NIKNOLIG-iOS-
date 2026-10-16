import Foundation

private final class NoRedirectDelegate: NSObject, URLSessionTaskDelegate {
    func urlSession(
        _ session: URLSession,
        task: URLSessionTask,
        willPerformHTTPRedirection response: HTTPURLResponse,
        newRequest request: URLRequest,
        completionHandler: @escaping (URLRequest?) -> Void
    ) {
        completionHandler(nil)
    }
}

enum BackendHealthClient {
    private static let session = URLSession(
        configuration: .ephemeral,
        delegate: NoRedirectDelegate(),
        delegateQueue: nil
    )

    static func check(baseURL: String) async -> Bool {
        guard var components = URLComponents(string: baseURL),
              components.scheme?.lowercased() == "https",
              let host = components.host,
              !host.isEmpty,
              components.user == nil,
              components.password == nil,
              components.port == nil,
              components.path.isEmpty || components.path == "/",
              components.query == nil,
              components.fragment == nil
        else {
            return false
        }

        components.path = "/v1/health"
        guard let url = components.url else { return false }

        var request = URLRequest(url: url, timeoutInterval: 5)
        request.httpMethod = "GET"
        request.cachePolicy = .reloadIgnoringLocalCacheData
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("NIKNOLIG-SandboxCheck/1", forHTTPHeaderField: "User-Agent")

        do {
            let (data, response) = try await session.data(for: request)
            guard data.count <= 4_096,
                  let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200,
                  httpResponse.mimeType == "application/json",
                  let body = try JSONSerialization.jsonObject(with: data) as? [String: Any]
            else {
                return false
            }

            return body["status"] as? String == "ok"
                && body["apiVersion"] as? String == "v1"
                && body["mode"] as? String == "sandbox"
        } catch {
            return false
        }
    }
}
