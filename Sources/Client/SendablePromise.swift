import Combine

/// A struct that wraps a promise to make it Sendable.
struct SendablePromise<T> {
    // MARK: Lifecycle

    /// Initializes a new SendablePromise.
    /// - Parameter promise: A closure that takes a Result and returns Void.
    init(_ promise: @escaping (Result<T,NetworkError>) -> Void) {
        self.promise = promise
    }

    // MARK: Internal

    /// Resolves the promise with a result.
    /// - Parameter result: The Result to resolve the promise with.
    func resolve(_ result: Result<T, NetworkError>) {
        promise(result)
    }

    // MARK: Private

    /// The underlying promise closure.
    private let promise: (Result<T, NetworkError>) -> Void
}

// MARK: Sendable

extension SendablePromise: @unchecked Sendable {}
