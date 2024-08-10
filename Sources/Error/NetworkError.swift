//
//  NetworkError.swift
//  SRNetworkLayer
//
//  Created by Siamak Rostami on 6/13/24.
//

import Foundation

// MARK: - NetworkError

enum NetworkError<ErrorType: CustomErrorProtocol>: Error {
    case unknown
    case urlError(URLError)
    case decodingError(Error)
    case customError(ErrorType)
    case responseError(Int, Data)
}

// MARK: LocalizedError

extension NetworkError: LocalizedError {
    var localizedErrorDescription: String? {
        switch self {
        case .urlError(let error):
            return error.localizedDescription
        case .decodingError(let error):
            return error.localizedDescription
        case .customError(let error):
            return error.errorDescription
        case .unknown:
            return GeneralErrorResponse.unknown().errorDescription
        default:
            return nil
        }
    }
}
