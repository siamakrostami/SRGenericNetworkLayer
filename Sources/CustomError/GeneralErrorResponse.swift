
import Foundation

// MARK: - GeneralErrorResponse

public struct GeneralErrorResponse: CustomErrorProtocol {
    public let code: Int
    public let details: String
    public let message: String
    public let path: String
    public let suggestion: String
    public let timestamp: String

    public var errorDescription: String {
        return message
    }
    
    public init(code: Int, details: String, message: String, path: String, suggestion: String, timestamp: String) {
        self.code = code
        self.details = details
        self.message = message
        self.path = path
        self.suggestion = suggestion
        self.timestamp = timestamp
    }
}

extension GeneralErrorResponse {
    public static func unknown() -> GeneralErrorResponse {
        return GeneralErrorResponse(
            code: 999,
            details: "An unknown error occurred",
            message: "An unknown error occurred",
            path: "",
            suggestion: "Please try again later or contact support if the problem persists",
            timestamp: ISO8601DateFormatter().string(from: Date())
        )
    }
}
