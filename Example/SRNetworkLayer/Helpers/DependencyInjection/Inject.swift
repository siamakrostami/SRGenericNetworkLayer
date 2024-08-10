//
//  Inject.swift
//  SRNetworkLayer
//
//  Created by Siamak on 8/26/23.
//

import Foundation

@propertyWrapper
struct Inject<T> {
    // MARK: Lifecycle

    init() {
        self.wrappedValue = Dependency.resolve()
    }

    // MARK: Internal

    var wrappedValue: T
}
