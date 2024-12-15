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
let defaultClient = APIClient()

// Initialization with custom QoS (Quality of Service)
let backgroundClient = APIClient(qos: .background)

// Initialization with custom log level
let verboseClient = APIClient(logLevel: .verbose)

// Initialization with both custom QoS and log level
let customClient = APIClient(qos: .userInitiated, logLevel: .standard)

// Initialization with a custom retry handler
let retryClient = APIClient(interceptor: MyCustomRetryHandler())

// Initialization with a custom decoder
let retryClient = APIClient(decoder: MyCustomDecoder())

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

OR


public protocol SampleRepositoryProtocols: Sendable {
    func getInvoice(documentID: String) -> AnyPublisher<SomeModel, NetworkError>
    func getInvoice(documentID: String) async throws -> SomeModel
    
    func getReceipt(transactionId: String) -> AnyPublisher<SomeModel, NetworkError>
    func getReceipt(transactionId: String) async throws -> SomeModel
}


public final class SampleRepository: Sendable {
    // MARK: Lifecycle

    public init(client: APIClient<ErrorResponse>) {
        self.client = client
    }

    // MARK: Private

    private let client: APIClient<ErrorResponse>
}


extension SampleRepository {
    enum Router: NetworkRouter {
        case getInvoice(documentID: String)
        case getReceipt(transactionId: String)

        var path: String {
            switch self {
            case .getInvoice(let documentID):
                return "your/path/\(documentID)"
            default:
                return "your/path/\(documentID)"
            }
        }

        var method: RequestMethod? {
            switch self {
            case .getInvoice:
                return .get
            default:
                return .post
            }
        }

        var headers: [String: String]? {
            var handler = HeaderHandler.shared
                .addAuthorizationHeader()
                .addAcceptHeaders(type: .applicationJson)
                .addDeviceId()
            
            switch self {
            case .getInvoice:
                break
            default:
                handler = handler.addContentTypeHeader(type: .applicationJson)
            }
            
            return handler.build()
        }
        
        var queryParams: SampleRepositoryQueryParamModel? {
            switch self {
            case .getInvoice(let trxId):
                return SampleRepositoryQueryParamModel(trxId: trxId)
            default:
                return nil
            }
        }
        
        var params: SampleRepositoryQueryParamModel? {
            switch self {
            case .getInvoice(let documentID):
                return SampleRepositoryQueryParamModel(
                    documentId: documentID,
                    stepId: "Some Id",
                    subStepId: "Some Id"
                )
            default:
                return nil
            }
        }
    }
}


extension SampleRepository: SampleRepositoryProtocols {
    public func getInvoice(documentID: String) -> AnyPublisher<SomeModel, NetworkError> {
        client.request(Router.getInvoice(documentID: documentID))
    }
    
    public func getInvoice(documentID: String) async throws -> SomeModel {
        try await client.asyncRequest(Router.getInvoice(documentID: documentID))
    }
    
    public func getReceipt(transactionId: String) -> AnyPublisher<SomeModel, NetworkError> {
        client.request(Router.getReceipt(transactionId: transactionId))
    }
    
    public func getReceipt(transactionId: String) async throws -> SomeModel {
        try await client.asyncRequest(Router.getReceipt(transactionId: transactionId))
    }
}


public struct SampleRepositoryQueryParamModel: Codable, Sendable {
    
    public init(documentId: String? = nil,
                stepId: String? = nil,
                subStepId: String? = nil,
                trxId: String? = nil) {
        self.documentId = documentId
        self.stepId = stepId
        self.subStepId = subStepId
        self.trxId = trxId
    }
    
    
    public let documentId: String?
    public let stepId: String?
    public let subStepId: String?
    public let trxId: String?
}
```

### Making a Request with Combine

```swift
let apiClient = APIClient()

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
let apiClient = APIClient()

do {
    let response: UserResponse = try await apiClient.asyncRequest(UserAPI())
    print("Received user: \(response)")
} catch {
    print("Request failed with error: \(error)")
}
```

### File Upload

```swift
let apiClient = APIClient()

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

### Retry Handling

Customize retry behavior by implementing the `RetryHandlerProtocol`:

```swift
class MyRetryHandler: RetryHandlerProtocol {
    // Implement retry logic
}

```
## Sample SwiftUI App

To help you get started with SRGenericNetworkLayer, we've created a sample SwiftUI app that demonstrates how to use this package in a real-world scenario. The sample app fetches and displays a list of posts from a mock API.

### Features of the Sample App

- Demonstrates setup and usage of `APIClient`
- Shows how to define API endpoints using `NetworkRouter`
- Illustrates making network requests and handling responses in SwiftUI
- Provides an example of basic error handling

### Getting the Sample App

You can find the sample app in the `Example/SRGenericNetworkLayerExampleApp` directory of this repository. To use it:

1. Clone this repository
2. Navigate to the `Example/SRGenericNetworkLayerExampleApp` directory
3. Open the `SRGenericNetworkLayerExampleApp.xcodeproj` file in Xcode
4. Run the project

### Structure of the Sample App

The sample app consists of the following key files:

- `ContentView.swift`: Main view displaying the list of posts
- `PostsViewModel.swift`: View model managing state and network calls
- `Post.swift`: Model representing a post
- `PostsAPI.swift`: Definition of the API endpoint for fetching posts
- `SRGenericNetworkLayerExampleApp.swift`: Main app structure

## Contributing

Contributions to SRGenericNetworkLayer are welcome! Please feel free to submit a Pull Request.

## License

SRGenericNetworkLayer is available under the MIT license. See the LICENSE file for more info.
