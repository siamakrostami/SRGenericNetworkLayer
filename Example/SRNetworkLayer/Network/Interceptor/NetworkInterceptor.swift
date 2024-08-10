import Combine
import Foundation
import SRGenericNetworkLayer

// MARK: - NetworkInterceptor

class NetworkInterceptor<ErrorType: CustomErrorProtocol>: Interceptor<ErrorType> {
    // MARK: Internal

    override func shouldRetry(request: URLRequest, error: NetworkError<ErrorType>) -> Bool {
        if numberOfRetries > 0, case .customError(let customError) = error as? NetworkError<GeneralErrorResponse>,
           customError.code == 403,
           (request.allHTTPHeaderFields?.keys.contains("Authorization")) != nil {
            return true
        } else {
            return false
        }
    }

    override func shouldRetryAsync(request: URLRequest, error: NetworkError<ErrorType>) async -> Bool {
        if numberOfRetries > 0, case .customError(let customError) = error as? NetworkError<GeneralErrorResponse>,
           customError.code == 403,
           (request.allHTTPHeaderFields?.keys.contains("Authorization")) != nil {
            return true
        } else {
            return false
        }
    }

    override func modifyRequestForRetry(client: APIClient<ErrorType>, request: URLRequest, error: NetworkError<ErrorType>) -> (URLRequest, NetworkError<ErrorType>?) {
        var newRequest = request
        var returnError: NetworkError<ErrorType>?
        if case .customError(let customError) = error as? NetworkError<GeneralErrorResponse>, customError.code == 403,
           (request.allHTTPHeaderFields?.keys.contains("Authorization")) != nil {
            let semaphore = DispatchSemaphore(value: 0)
            syncQueue.sync {
                refreshToken(client: client)?.sink(receiveCompletion: { [weak self] completion in
                    guard let _ = self else {
                        return
                    }
                    switch completion {
                        case .finished:
                            break
                        case let .failure(failure):
                            returnError = failure
                    }
                    semaphore.signal()
                }, receiveValue: { [weak self] model in
                    // Save your token here
                    newRequest.setValue("Bearer \(model.token ?? "")", forHTTPHeaderField: "Authorization")
                    semaphore.signal()
                }).store(in: &cancellabels)
            }
            semaphore.wait()
        }
        return (newRequest, returnError)
    }

    override func modifyRequestForRetryAsync(client: APIClient<ErrorType>, request: URLRequest, error: NetworkError<ErrorType>) async throws -> URLRequest {
        var newRequest = request
        do {
            let newToken = try await asyncRefreshToken(client: client)
            syncQueue.sync {
                // Save your token here
            }
            newRequest.setValue("Bearer \(newToken)", forHTTPHeaderField: "Authorization")
        } catch let error as NetworkError<ErrorType> {
            throw error
        }
        return newRequest
    }

    // MARK: Private

    private var cancellabels = Set<AnyCancellable>()
    private let syncQueue = DispatchQueue(label: "com.networkInterceptor.syncQueue")
}

extension NetworkInterceptor {
    func refreshToken(client: APIClient<ErrorType>) -> AnyPublisher<RefreshTokenModel, NetworkError<ErrorType>>? {
        return RefreshTokenServices(client: client).refreshToken(token: "YOUR_REFRESH_TOKEN").eraseToAnyPublisher()
    }

    @MainActor
    func asyncRefreshToken(client: APIClient<ErrorType>) async throws -> String {
        do {
            let refresh = try await RefreshTokenServices(client: client).asyncRefreshToken(token: "YOUR_REFRESH_TOKEN")
            return refresh.token ?? ""
        } catch {
            throw NetworkError<ErrorType>.decodingError(error)
        }
    }
}
