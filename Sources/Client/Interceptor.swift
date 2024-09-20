import Combine
import Foundation

/// A protocol defining the retry handling behavior for network requests.
public protocol RetryHandlerProtocol {
    associatedtype ErrorType: CustomErrorProtocol
    
    /// The maximum number of retry attempts.
    var numberOfRetries: Int { get }
    
    /// Determines whether a retry should be attempted for a given request and error.
    /// - Parameters:
    ///   - request: The URLRequest that failed.
    ///   - error: The NetworkError that occurred.
    /// - Returns: A boolean indicating whether to retry the request.
    func shouldRetry(request: URLRequest, error: NetworkError<ErrorType>) -> Bool
    
    /// Modifies the request for a retry attempt.
    /// - Parameters:
    ///   - client: The APIClient instance.
    ///   - request: The original URLRequest.
    ///   - error: The NetworkError that occurred.
    /// - Returns: A tuple containing the modified URLRequest and an optional NetworkError.
    func modifyRequestForRetry(client: APIClient<ErrorType>, request: URLRequest, error: NetworkError<ErrorType>) -> (URLRequest, NetworkError<ErrorType>?)
    
    /// Asynchronously determines whether a retry should be attempted.
    /// - Parameters:
    ///   - request: The URLRequest that failed.
    ///   - error: The NetworkError that occurred.
    /// - Returns: A boolean indicating whether to retry the request.
    func shouldRetryAsync(request: URLRequest, error: NetworkError<ErrorType>) async -> Bool
    
    /// Asynchronously modifies the request for a retry attempt.
    /// - Parameters:
    ///   - client: The APIClient instance.
    ///   - request: The original URLRequest.
    ///   - error: The NetworkError that occurred.
    /// - Returns: The modified URLRequest.
    /// - Throws: An error if the modification fails.
    func modifyRequestForRetryAsync(client: APIClient<ErrorType>, request: URLRequest, error: NetworkError<ErrorType>) async throws -> URLRequest
}

/// A default implementation of the RetryHandlerProtocol.
open class Interceptor<ErrorType: CustomErrorProtocol>: RetryHandlerProtocol, @unchecked Sendable {
    /// The maximum number of retry attempts.
    public let numberOfRetries: Int

    /// Initializes a new Interceptor instance.
    /// - Parameter numberOfRetries: The maximum number of retry attempts.
    public init(numberOfRetries: Int) {
        self.numberOfRetries = numberOfRetries
    }

    /// Determines whether a retry should be attempted for a given request and error.
    /// - Parameters:
    ///   - request: The URLRequest that failed.
    ///   - error: The NetworkError that occurred.
    /// - Returns: A boolean indicating whether to retry the request.
    @discardableResult
    open func shouldRetry(request: URLRequest, error: NetworkError<ErrorType>) -> Bool {
        return numberOfRetries > 0
    }

    /// Modifies the request for a retry attempt.
    /// - Parameters:
    ///   - client: The APIClient instance.
    ///   - request: The original URLRequest.
    ///   - error: The NetworkError that occurred.
    /// - Returns: A tuple containing the modified URLRequest and an optional NetworkError.
    @discardableResult
    open func modifyRequestForRetry(client: APIClient<ErrorType>, request: URLRequest, error: NetworkError<ErrorType>) -> (URLRequest, NetworkError<ErrorType>?) {
        return (request, error)
    }

    /// Asynchronously determines whether a retry should be attempted.
    /// - Parameters:
    ///   - request: The URLRequest that failed.
    ///   - error: The NetworkError that occurred.
    /// - Returns: A boolean indicating whether to retry the request.
    @discardableResult
    open func shouldRetryAsync(request: URLRequest, error: NetworkError<ErrorType>) async -> Bool {
        return numberOfRetries > 0
    }

    /// Asynchronously modifies the request for a retry attempt.
    /// - Parameters:
    ///   - client: The APIClient instance.
    ///   - request: The original URLRequest.
    ///   - error: The NetworkError that occurred.
    /// - Returns: The modified URLRequest.
    @discardableResult
    open func modifyRequestForRetryAsync(client: APIClient<ErrorType>, request: URLRequest, error: NetworkError<ErrorType>) async throws -> URLRequest {
        return request
    }
}
