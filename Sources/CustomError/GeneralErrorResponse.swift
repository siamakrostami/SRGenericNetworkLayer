
import Foundation

// MARK: - GeneralErrorResponse

public struct GeneralErrorResponse: CustomErrorProtocol {
    let code: Int
    let details: String
    let message: String
    let path: String
    let suggestion: String
    let timestamp: String

    public var errorDescription: String {
        return message
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
