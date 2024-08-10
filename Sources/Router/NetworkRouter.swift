
import Foundation

// MARK: - RequestMethod

enum RequestMethod: String {
    case get
    case post
    case put
    case patch
    case trace
    case delete
    case head
}

// MARK: - NetworkRouterError

enum NetworkRouterError: Error {
    case invalidURL
    case encodingFailed
}

// MARK: - NetworkRouter

protocol NetworkRouter {
    var baseURLString: String { get }
    var method: RequestMethod? { get }
    var path: String { get }
    var headers: [String: String]? { get }
    var params: [String: Any]? { get }
    var queryParams: [String: Any]? { get }
    func asURLRequest() throws -> URLRequest
}

// MARK: - Network Router Protocols impl

extension NetworkRouter {
    var baseURLString: String {
        return ""
    }

    // Add Rout method here
    var method: RequestMethod? {
        return .none
    }

    // Set APIs'Rout for each case
    var path: String {
        return ""
    }

    // Set header here
    var headers: [String: String]? {
        return nil
    }

    // Return each case parameters
    var params: [String: Any]? {
        return nil
    }

    var queryParams: [String: Any]? {
        return nil
    }

    // MARK: URLRequestConvertible

    func asURLRequest() throws -> URLRequest {
        let fullPath = baseURLString + path
        guard let url = URL(string: fullPath) else {
            throw NetworkRouterError.invalidURL
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method?.rawValue.uppercased()
        urlRequest.allHTTPHeaderFields = headers

        // Determine the encoding based on the HTTP method and headers
        switch method {
        case .delete,
             .get,
             .head:
            // For GET, DELETE, and HEAD, encode parameters in the query string if any
            let urlEncoding = URLEncoding(destination: .queryString)
            try urlEncoding.encode(&urlRequest, with: queryParams)
        default:
            // For POST, PUT, PATCH, etc., check the content type to decide encoding
            if let contentType = headers?[ContentTypeHeaders.name], contentType == ContentTypeHeaders.formData.rawValue {
                // Use URLEncoding for form-urlencoded content
                let urlEncoding = URLEncoding(destination: .httpBody)
                try urlEncoding.encode(&urlRequest, with: params)
            } else {
                // Default to JSON encoding
                if let queryParams, !queryParams.isEmpty {
                    try URLEncoding(destination: .queryString).encode(&urlRequest, with: queryParams)
                    try JSONEncoding().encode(&urlRequest, with: params)
                } else {
                    try JSONEncoding().encode(&urlRequest, with: params)
                }
            }
        }

        return urlRequest
    }
}
