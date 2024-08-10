import Combine
import Foundation

// MARK: - RetryHandlerProtocol

open protocol RetryHandlerProtocol {
    associatedtype ErrorType: CustomErrorProtocol
    var numberOfRetries: Int { get }
    func shouldRetry(request: URLRequest, error: NetworkError<ErrorType>) -> Bool
    func modifyRequestForRetry(client: APIClient<ErrorType>, request: URLRequest, error: NetworkError<ErrorType>) -> (URLRequest, NetworkError<ErrorType>?)
    func shouldRetryAsync(request: URLRequest, error: NetworkError<ErrorType>) async -> Bool
    func modifyRequestForRetryAsync(client: APIClient<ErrorType>, request: URLRequest, error: NetworkError<ErrorType>) async throws -> URLRequest
}

// MARK: - DefaultRetryHandler

open class Interceptor<ErrorType: CustomErrorProtocol>: RetryHandlerProtocol {
    let numberOfRetries: Int

    init(numberOfRetries: Int) {
        self.numberOfRetries = numberOfRetries
    }

    @discardableResult
    open func shouldRetry(request: URLRequest, error: NetworkError<ErrorType>) -> Bool {
        return numberOfRetries > 0
    }

    @discardableResult
    open func modifyRequestForRetry(client: APIClient<ErrorType>, request: URLRequest, error: NetworkError<ErrorType>) -> (URLRequest, NetworkError<ErrorType>?) {
        return (request, error)
    }

    @discardableResult
    open func shouldRetryAsync(request: URLRequest, error: NetworkError<ErrorType>) async -> Bool {
        return numberOfRetries > 0
    }

    @discardableResult
    open func modifyRequestForRetryAsync(client: APIClient<ErrorType>, request: URLRequest, error: NetworkError<ErrorType>) async throws -> URLRequest {
        return request
    }
}
