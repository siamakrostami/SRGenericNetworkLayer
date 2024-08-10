import Foundation
import SRGenericNetworkLayer

class NetworkRepositories<Error: CustomErrorProtocol> {
    // MARK: Lifecycle

    init(client: APIClient<Error>) {
        self.client = client
    }

    // MARK: Internal

    var loginServices: LoginService<Error>? {
        initializationQueue.sync {
            if _loginServices == nil {
                _loginServices = LoginService(client: client)
            }
            return _loginServices
        }
    }

    // MARK: Private

    private let client: APIClient<Error>
    private let initializationQueue = DispatchQueue(label: "com.networkRepositories.initializationQueue")
    
    // MARK: - Auth

    private var _loginServices: LoginService<Error>?
}
