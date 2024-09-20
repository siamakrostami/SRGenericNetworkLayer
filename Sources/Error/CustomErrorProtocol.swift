import Foundation

// MARK: - CustomErrorProtocol

/// A protocol for custom error types.
public protocol CustomErrorProtocol: Codable, Error, Sendable {
    /// A description of the error.
    var errorDescription: String { get }
}
