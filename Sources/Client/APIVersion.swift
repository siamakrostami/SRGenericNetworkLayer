//
//  APIVersion.swift
//  SRGenericNetworkLayer
//
//  Created by Siamak on 11/30/24.
//


// MARK: - APIVersion

public enum APIVersion: String, Sendable {
    case v1
    case v2
    case v3
    case v4
    case v5

    // MARK: Internal

    public var path: String {
        "api/\(rawValue)/"
    }
}
