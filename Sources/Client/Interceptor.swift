import Combine
import Foundation

// MARK: - RetryHandlerProtocol

protocol RetryHandlerProtocol {
    associatedtype ErrorType: CustomErrorProtocol
    var numberOfRetries: Int { get }
    func shouldRetry(request: URLRequest, error: NetworkError<ErrorType>) -> Bool
    func modifyRequestForRetry(client: APIClient<ErrorType>, request: URLRequest, error: NetworkError<ErrorType>) -> (URLRequest, NetworkError<ErrorType>?)
    func shouldRetryAsync(request: URLRequest, error: NetworkError<ErrorType>) async -> Bool
    func modifyRequestForRetryAsync(client: APIClient<ErrorType>, request: URLRequest, error: NetworkError<ErrorType>) async throws -> URLRequest
}

// MARK: - DefaultRetryHandler

class Interceptor<ErrorType: CustomErrorProtocol>: RetryHandlerProtocol {
    let numberOfRetries: Int

    init(numberOfRetries: Int) {
        self.numberOfRetries = numberOfRetries
    }

    @discardableResult
    func shouldRetry(request: URLRequest, error: NetworkError<ErrorType>) -> Bool {
        return numberOfRetries > 0
    }

    @discardableResult
    func modifyRequestForRetry(client: APIClient<ErrorType>, request: URLRequest, error: NetworkError<ErrorType>) -> (URLRequest, NetworkError<ErrorType>?) {
        return (request, error)
    }

    @discardableResult
    func shouldRetryAsync(request: URLRequest, error: NetworkError<ErrorType>) async -> Bool {
        return numberOfRetries > 0
    }

    @discardableResult
    func modifyRequestForRetryAsync(client: APIClient<ErrorType>, request: URLRequest, error: NetworkError<ErrorType>) async throws -> URLRequest {
        return request
    }
}
