import Foundation

extension Data {
    /// Appends a string to the Data instance.
    /// - Parameter string: The string to append.
    mutating func appendString(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
}
