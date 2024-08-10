//
//  CustomErrorProtocol.swift
//  SRNetworkLayer
//
//  Created by Siamak Rostami on 8/10/24.
//

import Foundation

// MARK: - CustomErrorProtocol

public protocol CustomErrorProtocol: Codable, Error {
    var errorDescription: String { get }
}
