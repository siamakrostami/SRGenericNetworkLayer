import Combine
import Foundation

// MARK: - APIClient

class APIClient<ErrorType: CustomErrorProtocol> {
    // MARK: - Properties

    private let apiQueue = DispatchQueue(label: "com.apiQueue", qos: .background)
    private var retryHandler: Interceptor = Interceptor<ErrorType>(numberOfRetries: 0)
    private var requestsToRetry: [URLRequest] = []
}

// MARK: - APIClient+Interceptor

extension APIClient {
    @discardableResult
    func set(interceptor: Interceptor<ErrorType>) -> Self {
        apiQueue.sync(flags: .barrier) {
            retryHandler = interceptor
        }
        return self
    }
}

// MARK: - APIClient+CombineRequest

extension APIClient {
    // MARK: - Combine Network Request

    func request<T: Codable>(_ endpoint: NetworkRouter) -> AnyPublisher<T, NetworkError<ErrorType>> {
        guard let urlRequest = try? endpoint.asURLRequest() else {
            return Fail(error: .unknown).eraseToAnyPublisher()
        }

        return makeRequest(urlRequest: urlRequest, retryCount: 3)
    }

    private func makeRequest<T: Codable>(urlRequest: URLRequest, retryCount: Int) -> AnyPublisher<T, NetworkError<ErrorType>> {
        URLSessionLogger.shared.logRequest(urlRequest)

        let session = configuredSession()

        return session.dataTaskPublisher(for: urlRequest)
            .subscribe(on: apiQueue)
            .tryMap { [weak self] output in
                URLSessionLogger.shared.logResponse(output.response, data: output.data, error: nil)
                guard let httpResponse = output.response as? HTTPURLResponse else {
                    throw NetworkError<ErrorType>.unknown
                }
                if 200 ..< 300 ~= httpResponse.statusCode {
                    return output.data
                } else {
                    guard let error = self?.mapErrorResponse(output.data, statusCode: httpResponse.statusCode) else {
                        throw NetworkError<ErrorType>.unknown
                    }
                    URLSessionLogger.shared.logResponse(output.response, data: output.data, error: error)
                    throw error
                }
            }
            .decode(type: T.self, decoder: JSONDecoder())
            .mapError { [weak self] error -> NetworkError<ErrorType> in
                URLSessionLogger.shared.logResponse(nil, data: nil, error: error)
                return self?.mapErrorToNetworkError(error) ?? .unknown
            }
            .catch { [weak self] error -> AnyPublisher<T, NetworkError<ErrorType>> in
                guard let self = self else {
                    return Fail(error: .unknown).eraseToAnyPublisher()
                }
                return self.handleRetry(urlRequest: urlRequest, retryCount: retryCount, error: error)
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

    private func handleRetry<T: Codable>(urlRequest: URLRequest, retryCount: Int, error: NetworkError<ErrorType>) -> AnyPublisher<T, NetworkError<ErrorType>> {
        if retryCount > 0 && retryHandler.shouldRetry(request: urlRequest, error: error) {
            apiQueue.sync(flags: .barrier) {
                requestsToRetry.append(urlRequest)
            }
            let (newUrlRequest, newError) = retryHandler.modifyRequestForRetry(client: self, request: requestsToRetry.last ?? urlRequest, error: error)
            if let newError = newError {
                return Fail(error: newError).eraseToAnyPublisher()
            }
            apiQueue.sync(flags: .barrier) {
                requestsToRetry.removeAll()
            }
            return makeRequest(urlRequest: newUrlRequest, retryCount: retryCount - 1)
        } else {
            return Fail(error: error).eraseToAnyPublisher()
        }
    }
}

// MARK: - APIClient+CombineUploadRequest

extension APIClient {
    func uploadRequest<T: Codable>(_ endpoint: NetworkRouter, withName: String, file: Data?, progressCompletion: @escaping (Double) -> Void) -> AnyPublisher<T, NetworkError<ErrorType>> {
        guard let urlRequest = try? endpoint.asURLRequest(), let file = file else {
            return Fail(error: NetworkError<ErrorType>.unknown).eraseToAnyPublisher()
        }

        return makeUploadRequest(urlRequest: urlRequest, params: endpoint.params, withName: withName, file: file, progressCompletion: progressCompletion, retryCount: 3)
            .subscribe(on: apiQueue)
            .eraseToAnyPublisher()
    }

    private func makeUploadRequest<T: Codable>(urlRequest: URLRequest, params: [String: Any]?, withName: String, file: Data, progressCompletion: @escaping (Double) -> Void, retryCount: Int) -> AnyPublisher<T, NetworkError<ErrorType>> {
        URLSessionLogger.shared.logRequest(urlRequest)
        let (newUrlRequest, bodyData) = createBody(urlRequest: urlRequest, parameters: params, data: file, filename: withName)

        return Future<Data, NetworkError<ErrorType>> { [weak self] promise in
            guard let self = self else {
                return
            }
            let progressDelegate = UploadProgressDelegate()
            progressDelegate.progressHandler = progressCompletion
            let session = self.configuredSession(delegate: progressDelegate)

            let task = session.uploadTask(with: newUrlRequest, from: bodyData) { data, response, error in
                URLSessionLogger.shared.logResponse(response, data: data, error: error)
                if let error = error {
                    promise(.failure(self.mapErrorToNetworkError(error)))
                } else if let httpResponse = response as? HTTPURLResponse, let responseData = data {
                    if 200 ..< 300 ~= httpResponse.statusCode {
                        promise(.success(responseData))
                    } else {
                        URLSessionLogger.shared.logResponse(response, data: data, error: error)
                        promise(.failure(self.mapErrorResponse(responseData, statusCode: httpResponse.statusCode)))
                    }
                } else {
                    URLSessionLogger.shared.logResponse(response, data: data, error: error)
                    promise(.failure(.unknown))
                }
            }
            task.resume()
        }
        .flatMap { [weak self] data -> AnyPublisher<T, NetworkError<ErrorType>> in
            guard let self = self else {
                return Fail(error: .unknown).eraseToAnyPublisher()
            }
            return Just(data)
                .decode(type: T.self, decoder: JSONDecoder())
                .mapError { self.mapErrorToNetworkError($0) }
                .catch { error -> AnyPublisher<T, NetworkError<ErrorType>> in
                    self.handleRetry(urlRequest: urlRequest, retryCount: retryCount, error: error)
                }
                .eraseToAnyPublisher()
        }
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }
}

// MARK: - APIClient+Async/Await

extension APIClient {
    // MARK: - Async/Await Network Request

    func asyncRequest<T: Codable>(_ endpoint: NetworkRouter) async throws -> T {
        guard let urlRequest = try? endpoint.asURLRequest() else {
            throw NetworkError<ErrorType>.unknown
        }

        return try await withCheckedThrowingContinuation { [weak self] continuation in
            guard let self = self else {
                continuation.resume(throwing: NetworkError<ErrorType>.unknown)
                return
            }
            apiQueue.async {
                Task {
                    do {
                        let result: T = try await self.makeAsyncRequest(urlRequest: urlRequest, retryCount: 3)
                        continuation.resume(returning: result)
                    } catch let error as NetworkError<ErrorType> {
                        continuation.resume(throwing: error)
                    } catch {
                        continuation.resume(throwing: NetworkError<ErrorType>.unknown)
                    }
                }
            }
        }
    }

    private func makeAsyncRequest<T: Codable>(urlRequest: URLRequest, retryCount: Int) async throws -> T {
        URLSessionLogger.shared.logRequest(urlRequest)

        let session = configuredSession()

        do {
            let (data, response) = try await session.data(for: urlRequest)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError<ErrorType>.unknown
            }

            URLSessionLogger.shared.logResponse(response, data: data, error: nil)

            if 200 ..< 300 ~= httpResponse.statusCode {
                do {
                    let decodedResponse = try JSONDecoder().decode(T.self, from: data)
                    return decodedResponse
                } catch {
                    throw mapErrorToNetworkError(error)
                }
            } else {
                let error = mapErrorResponse(data, statusCode: httpResponse.statusCode)
                throw error
            }
        } catch {
            return try await handleAsyncRetry(urlRequest: urlRequest, retryCount: retryCount, error: error)
        }
    }

    private func handleAsyncRetry<T: Codable>(urlRequest: URLRequest, retryCount: Int, error: Error) async throws -> T {
        let networkError = error as? NetworkError<ErrorType> ?? mapErrorToNetworkError(error)

        return try await withCheckedThrowingContinuation { continuation in
            Task {
                do {
                    let shouldRetry = await retryHandler.shouldRetryAsync(request: urlRequest, error: networkError)

                    if retryCount > 0 && shouldRetry {
                        apiQueue.sync(flags: .barrier) {
                            requestsToRetry.append(urlRequest)
                        }

                        let newUrlRequest = try await retryHandler.modifyRequestForRetryAsync(client: self, request: requestsToRetry.last ?? urlRequest, error: networkError)

                        apiQueue.sync(flags: .barrier) {
                            requestsToRetry.removeAll()
                        }

                        do {
                            let result: T = try await makeAsyncRequest(urlRequest: newUrlRequest, retryCount: retryCount - 1)
                            continuation.resume(returning: result)
                        } catch {
                            continuation.resume(throwing: error)
                        }
                    } else {
                        continuation.resume(throwing: networkError)
                    }
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}

// MARK: - APIClient+Async/Await Upload

extension APIClient {
    // MARK: - Async/Await Upload Request

    func asyncUploadRequest<T: Codable>(_ endpoint: NetworkRouter, withName: String, file: Data?, progressCompletion: @escaping (Double) -> Void) async throws -> T {
        guard let urlRequest = try? endpoint.asURLRequest(), let file = file else {
            throw NetworkError<ErrorType>.unknown
        }

        return try await withCheckedThrowingContinuation { [weak self] continuation in
            guard let self = self else {
                continuation.resume(throwing: NetworkError<ErrorType>.unknown)
                return
            }
            apiQueue.async {
                Task {
                    do {
                        let result: T = try await self.makeAsyncUploadRequest(urlRequest: urlRequest, params: endpoint.params, withName: withName, file: file, progressCompletion: progressCompletion, retryCount: 3)
                        continuation.resume(returning: result)
                    } catch let error as NetworkError<ErrorType> {
                        continuation.resume(throwing: error)
                    } catch {
                        continuation.resume(throwing: NetworkError<ErrorType>.unknown)
                    }
                }
            }
        }
    }

    private func makeAsyncUploadRequest<T: Codable>(urlRequest: URLRequest, params: [String: Any]?, withName: String, file: Data, progressCompletion: @escaping (Double) -> Void, retryCount: Int) async throws -> T {
        URLSessionLogger.shared.logRequest(urlRequest)
        let (newUrlRequest, bodyData) = createBody(urlRequest: urlRequest, parameters: params, data: file, filename: withName)

        let progressDelegate = UploadProgressDelegate()
        progressDelegate.progressHandler = progressCompletion
        let session = configuredSession(delegate: progressDelegate)

        do {
            let (data, response) = try await session.upload(for: newUrlRequest, from: bodyData)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError<ErrorType>.unknown
            }

            URLSessionLogger.shared.logResponse(response, data: data, error: nil)

            if 200 ..< 300 ~= httpResponse.statusCode {
                do {
                    let decodedResponse = try JSONDecoder().decode(T.self, from: data)
                    return decodedResponse
                } catch {
                    throw mapErrorToNetworkError(error)
                }
            } else {
                let error = mapErrorResponse(data, statusCode: httpResponse.statusCode)
                throw error
            }
        } catch {
            return try await handleAsyncRetry(urlRequest: urlRequest, retryCount: retryCount, error: error)
        }
    }
}

// MARK: - APIClient+ErrorHandling

extension APIClient {
    // MARK: - Error Handling

    private func mapErrorToNetworkError(_ error: Error) -> NetworkError<ErrorType> {
        if let networkError = error as? NetworkError<ErrorType> {
            return networkError
        }
        switch error {
        case let urlError as URLError:
            return .urlError(urlError)
        case let decodingError as DecodingError:
            return .decodingError(decodingError)
        default:
            return .unknown
        }
    }

    private func mapErrorResponse(_ data: Data, statusCode: Int) -> NetworkError<ErrorType> {
        do {
            let errorResponse = try JSONDecoder().decode(ErrorType.self, from: data)
            return .customError(errorResponse)
        } catch {
            // If we can't decode the custom error type, we'll create a default ErrorResponse
            let defaultError = GeneralErrorResponse(
                code: statusCode,
                details: String(data: data, encoding: .utf8) ?? "No details available",
                message: HTTPURLResponse.localizedString(forStatusCode: statusCode),
                path: "",
                suggestion: "Please try again later or contact support if the problem persists",
                timestamp: ISO8601DateFormatter().string(from: Date())
            )
            return .customError(defaultError as! ErrorType)
        }
    }
}

// MARK: - APIClient+Helper Methods

extension APIClient {
    private func configuredSession(delegate: URLSessionDelegate? = nil) -> URLSession {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 120
        configuration.timeoutIntervalForResource = 120
        configuration.requestCachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        return URLSession(configuration: configuration, delegate: delegate, delegateQueue: nil)
    }

    private func createBody(urlRequest: URLRequest, parameters: [String: Any]?, data: Data, filename: String) -> (URLRequest, Data) {
        var newUrlRequest = urlRequest
        let boundary = "Boundary-\(UUID().uuidString)"
        let mime = Swime.mimeType(data: data)
        newUrlRequest.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        var body = Data()

        if let parameters = parameters, !parameters.isEmpty {
            for (key, value) in parameters {
                body.appendString("--\(boundary)\r\n")
                body.appendString("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
                body.appendString("\(value)\r\n")
            }
        }

        body.appendString("--\(boundary)\r\n")
        body.appendString("Content-Disposition: form-data; name=\"file\"; filename=\"\(filename).\(mime?.ext ?? "")\"\r\n")
        body.appendString("Content-Type: \(mime?.mime ?? "")\r\n\r\n")
        body.append(data)
        body.appendString("\r\n")
        body.appendString("--\(boundary)--\r\n")

        return (newUrlRequest, body)
    }
}
