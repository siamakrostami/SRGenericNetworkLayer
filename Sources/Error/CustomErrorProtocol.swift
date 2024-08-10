//
//  CustomErrorProtocol.swift
//  SRNetworkLayer
//
//  Created by Siamak Rostami on 8/10/24.
//

import Foundation

// MARK: - CustomErrorProtocol

open protocol CustomErrorProtocol: Codable, Error {
    open var errorDescription: String { get }
}
