
# SRGenericNetworkLayer

**SRGenericNetworkLayer** is a Swift-based network layer designed to simplify network communication in your iOS applications. It provides a robust and flexible structure for making network requests, handling responses, and managing dependencies.

## Features

- Asynchronous network requests using Combine and async/await.
- Support for file uploads with progress tracking.
- Retry logic with customizable interceptors.
- Dependency injection for better testability and modularity.
- Comprehensive error handling and logging.

## Requirements

- iOS 13.0+
- Swift 5.0+
- Xcode 11.0+

## Installation

You can add `SRGenericNetworkLayer` to your project using Swift Package Manager.

### Swift Package Manager

1. In Xcode, go to `File` > `Add Packages`.
2. Enter the repository URL: `https://github.com/siamakrostami/SRGenericNetworkLayer`.
3. Select the latest release version and add the package to your project.

## Usage

### Setting Up the Environment

Initialize the `AppEnvironment` in your `AppDelegate` or `SceneDelegate`:

```swift
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let _ = AppEnvironment.setup()
        return true
    }
}
```

### Making a Network Request

To make a network request, use the `NetworkRepositories` class:

```swift
import Combine
import Foundation

// MARK: - LoginViewModel

class LoginViewModel: BaseViewModel {
    @Published var userModel: UserResponseModel?
    @Published var isLoading: Bool = false
    var loginCancellableSet = Set<AnyCancellable>()
}

extension LoginViewModel {
    func login(email: String, password: String) {
        isLoading = true
        remoteRepositories.loginServices?
            .login(email: email, password: password)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .finished:
                    break
                case .failure(let failure):
                    self?.isLoading = false
                    self?.error.send(failure)
                }
            }, receiveValue: { [weak self] model in
                self?.isLoading = false
                self?.userModel = model
            }).store(in: &loginCancellableSet)
    }

    @MainActor
    func asyncLogin(email: String, password: String) {
        isLoading = true
        Task {
            do {
                let response = try await remoteRepositories.loginServices?.asyncLogin(email: email, password: password)
                userModel = response
                isLoading = false
            } catch let error as NetworkError {
                isLoading = false
                self.error.send(error)
            }
        }
    }
}
```

### Handling File Uploads

To upload a file, use the `asyncUploadRequest` method:

```swift
class UploadViewModel {

    @MainActor
    func uploadProfilePicture(file: Data?, fileName: String) {
        isLoading = true
        Task {
            do{
                let response = try await remoteRepositories.profilePictureServices?.asyncUpload(file: file, name: fileName, uploadProgress: { [weak self] progress in
                    guard let _ = self else {return}
                    debugPrint(progress)
                })
                self.isLoading = false
                self.uploadPhotoModel = response
            }catch let error as NetworkError{
                self.isLoading = false
                self.error.send(error)
            }
        }
    }
}
```

## Documentation

For full documentation, please refer to the source code and the comments within. Each method is documented to provide clarity on its purpose, parameters, return values, and potential errors.

## Example App

The repository includes an example app demonstrating how to use the `SRGenericNetworkLayer`. The example app is located in the `Examples/ExampleApp` directory. You can run this app to see the package in action.

To run the example app:

1. Open `Examples/ExampleApp/ExampleApp.xcodeproj` in Xcode.
2. Build and run the app on a simulator or device.

## License

SRGenericNetworkLayer is released under the MIT license. See [LICENSE](LICENSE) for details.
