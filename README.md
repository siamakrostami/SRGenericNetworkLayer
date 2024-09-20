# SRGenericNetworkLayer

SRGenericNetworkLayer is a powerful and flexible networking layer for Swift applications. It provides a generic, protocol-oriented approach to handling API requests, supporting both Combine and async/await paradigms. This package is designed to be easy to use, highly customizable, and compatible with Swift 6 and the Sendable protocol.

## Features

- Generic API client supporting various types of network requests
- Protocol-oriented design for easy customization and extensibility
- Support for both Combine and async/await
- Robust error handling with custom error types
- Retry mechanism for failed requests
- File upload support with progress tracking
- Flexible parameter encoding (URL and JSON)
- Comprehensive logging system
- MIME type detection for file uploads
- Thread-safe design with Sendable protocol support
- Swift 6 compatible

## Requirements

- iOS 13.0+ / macOS 10.15+
- Swift 5.5+
- Xcode 13.0+

## Installation

### Swift Package Manager

Add the following to your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/siamakrostami/SRGenericNetworkLayer.git", from: "1.0.0")
]
```

## Usage

### Initializing APIClient

The `APIClient` can be initialized in several ways to suit different use cases:

```swift
// Basic initialization with default settings
let defaultClient = APIClient<MyErrorType>()

// Initialization with custom QoS (Quality of Service)
let backgroundClient = APIClient<MyErrorType>(qos: .background)

// Initialization with custom log level
let verboseClient = APIClient<MyErrorType>(logLevel: .verbose)

// Initialization with both custom QoS and log level
let customClient = APIClient<MyErrorType>(qos: .userInitiated, logLevel: .standard)

// Initialization with a custom retry handler
let retryClient = APIClient<MyErrorType>()
retryClient.set(interceptor: MyCustomRetryHandler())

// Initialization with custom settings and chained configuration
let fullyCustomClient = APIClient<MyErrorType>(qos: .userInitiated, logLevel: .minimal)
    .set(interceptor: MyCustomRetryHandler())
    .setLog(level: .verbose)
```

### Defining an API Endpoint

```swift
struct UserAPI: NetworkRouter {
    typealias Parameters = UserParameters
    typealias QueryParameters = UserQueryParameters

    var baseURLString: String { return "https://api.example.com" }
    var method: RequestMethod? { return .get }
    var path: String { return "/users" }
    var headers: [String: String]? { return HeaderHandler.shared.addAcceptHeaders(type: .applicationJson).addContentTypeHeader(type: .applicationJson).build() }
    var params: Parameters? { return UserParameters(id: 123) }
    var queryParams: QueryParameters? { return UserQueryParameters(includeDetails: true) }
}
```

### Making a Request with Combine

```swift
let apiClient = APIClient<MyErrorType>()

apiClient.request(UserAPI())
    .sink(receiveCompletion: { completion in
        switch completion {
        case .finished:
            print("Request completed successfully")
        case .failure(let error):
            print("Request failed with error: \(error)")
        }
    }, receiveValue: { (response: UserResponse) in
        print("Received user: \(response)")
    })
    .store(in: &cancellables)
```

### Making a Request with async/await

```swift
let apiClient = APIClient<MyErrorType>()

do {
    let response: UserResponse = try await apiClient.asyncRequest(UserAPI())
    print("Received user: \(response)")
} catch {
    print("Request failed with error: \(error)")
}
```

### File Upload

```swift
let apiClient = APIClient<MyErrorType>()

let fileData = // ... your file data ...
let endpoint = UploadAPI()

apiClient.uploadRequest(endpoint, withName: "file", data: fileData) { progress in
    print("Upload progress: \(progress)")
}
.sink(receiveCompletion: { completion in
    // Handle completion
}, receiveValue: { (response: UploadResponse) in
    print("Upload completed: \(response)")
})
.store(in: &cancellables)
```

## Customization

### Custom Error Handling

Implement the `CustomErrorProtocol` to define your own error types:

```swift
struct MyErrorType: CustomErrorProtocol {
    var errorDescription: String
    // Add other properties as needed
}
```

### Retry Handling

Customize retry behavior by implementing the `RetryHandlerProtocol`:

```swift
class MyRetryHandler: RetryHandlerProtocol {
    // Implement retry logic
}

apiClient.set(interceptor: MyRetryHandler())
```

## Logging

Control logging verbosity:

```swift
apiClient.setLog(level: .verbose)
```

## Contributing

Contributions to SRGenericNetworkLayer are welcome! Please feel free to submit a Pull Request.

## License

SRGenericNetworkLayer is available under the MIT license. See the LICENSE file for more info.
