//
//  NetworkParameterEncoding.swift
//  SRNetworkLayer
//
//  Created by Siamak Rostami on 7/15/24.
//

import Foundation

// MARK: - Definitions

public typealias Parameters = [String: Any]

// MARK: - EncodingError

// Error Handling
enum EncodingError: Error {
    case missingURL
    case jsonEncodingFailed(error: Error)
}

// MARK: - NetworkParameterEncoding

protocol NetworkParameterEncoding {
    func encode(_ urlRequest: inout URLRequest, with parameters: Parameters?) throws
}

// MARK: - URLEncoding

struct URLEncoding: NetworkParameterEncoding {
    // MARK: Internal

    enum Destination {
        case methodDependent
        case queryString
        case httpBody
    }

    var destination: Destination
    var arrayEncoding: ArrayEncoding = .noBrackets
    var boolEncoding: BoolEncoding = .numeric

    func encode(_ urlRequest: inout URLRequest, with parameters: Parameters?) throws {
        guard let parameters = parameters else {
            return
        }

        switch destination {
        case .methodDependent:
            if let method = RequestMethod(rawValue: urlRequest.httpMethod?.lowercased() ?? "get"), [.get, .delete, .head].contains(method) {
                try encodeQueryString(&urlRequest, with: parameters)
            } else {
                try encodeHttpBody(&urlRequest, with: parameters)
            }
        case .queryString:
            try encodeQueryString(&urlRequest, with: parameters)
        case .httpBody:
            try encodeHttpBody(&urlRequest, with: parameters)
        }
    }

    func queryComponents(fromKey key: String, value: Any) -> [(String, String)] {
        var components: [(String, String)] = []

        switch value {
        case let dictionary as [String: Any]:
            for (nestedKey, value) in dictionary {
                components += queryComponents(fromKey: "\(key)[\(nestedKey)]", value: value)
            }
        case let array as [Any]:
            for (index, value) in array.enumerated() {
                let encodedKey = arrayEncoding.encode(key: key, atIndex: index)
                components += queryComponents(fromKey: encodedKey, value: value)
            }
        case let bool as Bool:
            let encodedValue = boolEncoding.encode(value: bool)
            components.append((escape(key), escape(encodedValue)))
        case let value:
            components.append((escape(key), escape("\(value)")))
        }
        return components
    }

    func escape(_ string: String) -> String {
        string.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? string
    }

    // MARK: Private

    private func encodeQueryString(_ urlRequest: inout URLRequest, with parameters: Parameters) throws {
        guard let url = urlRequest.url else {
            throw EncodingError.missingURL
        }
        if var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false), !parameters.isEmpty {
            let percentEncodedQuery = (urlComponents.percentEncodedQuery.map { $0 + "&" } ?? "") + query(parameters)
            urlComponents.percentEncodedQuery = percentEncodedQuery
            urlRequest.url = urlComponents.url
        }
    }

    private func encodeHttpBody(_ urlRequest: inout URLRequest, with parameters: Parameters) throws {
        urlRequest.httpBody = Data(query(parameters).utf8)
        urlRequest.setValue("application/x-www-form-urlencoded; charset=utf-8", forHTTPHeaderField: "Content-Type")
    }

    private func query(_ parameters: Parameters) -> String {
        var components: [(String, String)] = []

        for key in parameters.keys.sorted(by: <) {
            let value = parameters[key]!
            components += queryComponents(fromKey: key, value: value)
        }
        return components.map { "\($0.0)=\($0.1)" }.joined(separator: "&")
    }
}

// MARK: - JSONEncoding

struct JSONEncoding: NetworkParameterEncoding {
    func encode(_ urlRequest: inout URLRequest, with parameters: Parameters?) throws {
        guard let parameters = parameters else {
            return
        }

        do {
            let data = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
            urlRequest.httpBody = data
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        } catch {
            throw EncodingError.jsonEncodingFailed(error: error)
        }
    }
}

// MARK: - ArrayEncoding

enum ArrayEncoding {
    case brackets
    case noBrackets
    case indexInBrackets

    // MARK: Internal

    func encode(key: String, atIndex index: Int) -> String {
        switch self {
        case .brackets: return "\(key)[]"
        case .noBrackets: return key
        case .indexInBrackets: return "\(key)[\(index)]"
        }
    }
}

// MARK: - BoolEncoding

enum BoolEncoding {
    case numeric
    case literal

    // MARK: Internal

    func encode(value: Bool) -> String {
        switch self {
        case .numeric: return value ? "1" : "0"
        case .literal: return value ? "true" : "false"
        }
    }
}
