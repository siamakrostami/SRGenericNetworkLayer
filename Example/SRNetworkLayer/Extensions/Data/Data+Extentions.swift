//
//  Data+Extentions.swift
//  SRNetworkLayer
//
//  Created by Siamak Rostami on 7/15/24.
//

import Foundation

extension Data {
    mutating func appendString(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
}
