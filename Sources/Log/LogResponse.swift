import Foundation

class URLSessionLogger {
    // MARK: Lifecycle

    private init() {}

    // MARK: Internal

    static let shared = URLSessionLogger() // Singleton instance

    func logRequest(_ request: URLRequest) {
        print("\n🚀🚀🚀 REQUEST 🚀🚀🚀")
        print("🔈 \(request.httpMethod ?? "UNKNOWN") \(request.url?.absoluteString ?? "Invalid URL")")
        print("Headers:")
        request.allHTTPHeaderFields?.forEach { print("💡 \($0.key): \($0.value)") }
        if let body = request.httpBody, let bodyString = String(data: body, encoding: .utf8) {
            print("{\n  \(bodyString)\n}")
        }
        print("🔼🔼🔼 END REQUEST 🔼🔼🔼")
    }

    func logResponse(_ response: URLResponse?, data: Data?, error: Error?) {
        if let httpResponse = response as? HTTPURLResponse {
            if 200 ..< 300 ~= httpResponse.statusCode {
                print("\n✅✅✅ SUCCESS RESPONSE ✅✅✅")
                print("🔈 \(httpResponse.url?.absoluteString ?? "Invalid URL")")
                print("🔈 Status code: \(httpResponse.statusCode)")
                print("Headers:")
                httpResponse.allHeaderFields.forEach { print("💡 \($0.key): \($0.value)") }
                if let data = data, let responseBody = String(data: data, encoding: .utf8) {
                    print("{\n  \(responseBody)\n}")
                }
                print("🔼🔼🔼 END SUCCESS RESPONSE 🔼🔼🔼")
            } else {
                print("\n🛑🛑🛑 REQUEST ERROR 🛑🛑🛑")
                print("🔈 \(httpResponse.url?.absoluteString ?? "Invalid URL")")
                print("🔈 Status code: \(httpResponse.statusCode)")
                print("Headers:")
                httpResponse.allHeaderFields.forEach { print("💡 \($0.key): \($0.value)") }
                if let data = data, let responseBody = String(data: data, encoding: .utf8) {
                    print("{\n  \(responseBody)\n}")
                }
                print("🔈 \(String(describing: error?.localizedDescription))")
                print("🔼🔼🔼 END REQUEST ERROR 🔼🔼🔼")
            }

        } else if let error = error {
            print("\n🛑🛑🛑 REQUEST ERROR 🛑🛑🛑")
            print("🔈 \(error.localizedDescription)")
            print("🔼🔼🔼 END REQUEST ERROR 🔼🔼🔼")
        }
    }
}
