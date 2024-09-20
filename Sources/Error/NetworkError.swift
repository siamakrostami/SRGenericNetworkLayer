import Foundation

// MARK: - NetworkError

/// An enum representing various network errors.
public enum NetworkError<ErrorType: CustomErrorProtocol>: Error, Sendable {
    case unknown
    case urlError(URLError)
    case decodingError(Error)
    case customError(ErrorType)
    case responseError(Int, Data)
}

// MARK: LocalizedError

extension NetworkError: LocalizedError {
    public var localizedErrorDescription: String? {
        switch self {
        case .urlError(let error):
            return error.localizedDescription
        case .decodingError(let error):
            return error.localizedDescription
        case .customError(let error):
            return error.errorDescription
        case .unknown:
            return GeneralErrorResponse.unknown().errorDescription
        default:
            return nil
        }
    }
}
