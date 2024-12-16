
# SRNetworkManager 🚀

**SRNetworkManager** is a **powerful** and **flexible networking layer** for Swift applications. It provides a **generic, protocol-oriented** approach to handling API requests, supporting both **Combine** and **async/await** paradigms. This package is designed to be **easy to use**, **highly customizable**, and **fully compatible** with **Swift 6** and the **Sendable protocol**.

---

![Platform](https://img.shields.io/badge/platform-iOS%20|%20tvOS%20|%20macOS-blue)
![Swift](https://img.shields.io/badge/swift-6.0-orange)
![License](https://img.shields.io/github/license/siamakrostami/SRNetworkManager)
![Version](https://img.shields.io/github/v/tag/siamakrostami/SRNetworkManager?label=version)


## 🎯 **Features**

- 🔗 **Generic API Client** for various types of network requests
- 🧩 **Protocol-Oriented Design** for easy customization and extensibility
- ⚡ **Support for Combine & async/await**
- 🛡️ **Robust Error Handling** with custom error types
- 🔄 **Retry Mechanism** for failed requests
- 📤 **File Upload Support** with progress tracking
- 🔧 **Flexible Parameter Encoding** (URL & JSON)
- 🧾 **Comprehensive Logging System**
- 📦 **MIME Type Detection** for file uploads
- 🔒 **Thread-Safe Design** with Sendable protocol support
- 🚀 **Swift 6 Compatibility**

---

## 📋 **Requirements**

- **iOS 13.0+ / macOS 10.15+**
- **Swift 5.5+**
- **Xcode 13.0+**

---

## 📦 **Installation**

### Swift Package Manager (SPM)
Add the following to your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/siamakrostami/SRNetworkManager.git", from: "1.0.0")
]
```

Or use **Xcode:**
1. Go to **File > Add Packages...**
2. Search for:
   ```
   https://github.com/siamakrostami/SRNetworkManager.git
   ```
3. Select the latest version and add it to your project.

---

## 📚 **Usage**

### Initializing APIClient

```swift

let client = APIClient() // Basic initialization with default settings

let client = APIClient(qos: .background) // Initialization with custom QoS (Quality of Service)

let client = APIClient(logLevel: .verbose) // Initialization with custom log level

let client = APIClient(qos: .userInitiated, logLevel: .standard) // Initialization with both custom QoS and log level

let client = APIClient(retryHandler: MyCustomRetryHandler()) // Initialization with a custom retry handler

let client = APIClient(decoder: MyCustomDecoder()) // Initialization with a custom decoder

```

---

### Defining an API Endpoint 🌐

```swift
struct UserAPI: NetworkRouter {
    typealias Parameters = UserParameters
    typealias QueryParameters = UserQueryParameters

    var baseURLString: String { "https://api.example.com" }
    var method: RequestMethod? { .get }
    var path: String { "/users" }
    var headers: [String: String]? { HeaderHandler.shared.addAcceptHeaders(type: .applicationJson).addContentTypeHeader(type: .applicationJson).build() }
    var params: Parameters? { UserParameters(id: 123) }
    var queryParams: QueryParameters? { UserQueryParameters(includeDetails: true) }
}
```

Or 

```swift
public protocol SampleRepositoryProtocols: Sendable {
    func getInvoice(documentID: String) -> AnyPublisher<SomeModel, NetworkError>
    func getInvoice(documentID: String) async throws -> SomeModel
    
    func getReceipt(transactionId: String) -> AnyPublisher<SomeModel, NetworkError>
    func getReceipt(transactionId: String) async throws -> SomeModel
}


public final class SampleRepository: Sendable {
    // MARK: Lifecycle

    public init(client: APIClient) {
        self.client = client
    }

    // MARK: Private

    private let client: APIClient
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

---

### Making a Request (async/await) ⚡

```swift
Task {
    do {
        let user: UserAPI = try await client.asyncRequest(UserAPI())
        print("Received user: \(user)")
    } catch {
        print("Request failed: \(error)")
    }
}
```

---

### Making a Request (Combine) 🔗

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

---

### File Upload 📤

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

---

## 🔧 **Customization**

### Retry Handling 🔄

```swift
struct CustomRetryHandler: RetryHandler {
    // MARK: Lifecycle

    init(numberOfRetries: Int) {
        self.numberOfRetries = numberOfRetries
    }

    // MARK: Public

    let numberOfRetries: Int

    func shouldRetry(request: URLRequest, error: NetworkError) -> Bool {}

    func modifyRequestForRetry(client: APIClient, request: URLRequest, error: NetworkError) -> (URLRequest, NetworkError?) {}
}
```

---

## 📱 **Sample SwiftUI App**

To help you get started with **SRNetworkManager**, we've created a sample SwiftUI app that demonstrates how to use this package in a real-world scenario.

### 🎨 **Features of the Sample App**
- Setup and usage of `APIClient`
- Defining API endpoints using `NetworkRouter`
- Making network requests and handling responses in SwiftUI
- Basic error handling

### 🚀 **Getting the Sample App**
1. Clone this repository.
2. Navigate to the `Example/SRNetworkManagerExampleApp` directory.
3. Open `SRNetworkManagerExampleApp.xcodeproj` in Xcode.
4. Run the project.

---

## 🤝 **Contributing**
We welcome contributions! Please feel free to submit a Pull Request.

---

## 📄 **License**
**SRNetworkManager** is available under the **MIT license**. See the [LICENSE](LICENSE) file for more details.

---

