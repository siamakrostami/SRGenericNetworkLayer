import Foundation

// MARK: - GeneralErrorResponse

/// A struct representing a general error response.
public struct GeneralErrorResponse: CustomErrorProtocol, Sendable {
    /// The error code.
    public let code: Int
    /// Detailed description of the error.
    public let details: String
    /// A short message describing the error.
    public let message: String
    /// The path where the error occurred.
    public let path: String
    /// The timestamp when the error occurred.
    public let timestamp: String

    /// A computed property that returns the error description.
    public var errorDescription: String {
        return message
    }
    
    /// Initializes a new GeneralErrorResponse instance.
    /// - Parameters:
    ///   - code: The error code.
    ///   - details: Detailed description of the error.
    ///   - message: A short message describing the error.
    ///   - path: The path where the error occurred.
    ///   - timestamp: The timestamp when the error occurred.
    public init(code: Int, details: String, message: String, path: String, timestamp: String) {
        self.code = code
        self.details = details
        self.message = message
        self.path = path
        self.timestamp = timestamp
    }
}

extension GeneralErrorResponse {
    /// Creates an unknown error response.
    /// - Returns: A GeneralErrorResponse instance representing an unknown error.
    public static func unknown() -> GeneralErrorResponse {
        return GeneralErrorResponse(
            code: 999,
            details: "An unknown error occurred",
            message: "An unknown error occurred",
            path: "",
            timestamp: ISO8601DateFormatter().string(from: Date())
        )
    }
}
