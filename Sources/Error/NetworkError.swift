import Foundation

// MARK: - NetworkError

/// An enum representing various network errors.
public enum NetworkError: Error, Sendable {
    case unknown
    case urlError(URLError)
    case decodingError(Error)
    case customError(Int,Data)
    case responseError(Error)
}

// MARK: LocalizedError

extension NetworkError: LocalizedError {
    public var localizedErrorDescription: String? {
        switch self {
        case .urlError(let error):
            return error.localizedDescription
        case .decodingError(let error):
            return error.localizedDescription
        case .customError(_,_):
            return self.localizedDescription
        case .responseError(let error):
            return error.localizedDescription
        case .unknown:
            return self.localizedDescription
        }
    }
}
