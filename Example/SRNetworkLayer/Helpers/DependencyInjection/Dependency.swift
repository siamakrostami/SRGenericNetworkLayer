//
//  Dependency.swift
//  SRNetworkLayer
//
//  Created by Siamak on 8/26/23.
//

import Foundation

// MARK: - Dependency

final class Dependency {
    // MARK: Lifecycle

    private init() {}
    
    // MARK: Private

    private static let shared = Dependency()

    private var dependencies = [String: AnyObject]()
    private let queue = DispatchQueue(label: "com.dependency.queue")
}

extension Dependency {
    static func register<T>(_ dependency: T) {
        shared.register(dependency)
    }
    
    static func resolve<T>() -> T {
        return shared.resolve()
    }
    
    private func register<T>(_ dependency: T) {
        let key = String(describing: T.self)
        queue.sync {
            dependencies[key] = dependency as AnyObject
        }
    }
    
    private func resolve<T>() -> T {
        let key = String(describing: T.self)
        var dependency: T?
        queue.sync {
            dependency = dependencies[key] as? T
        }
        precondition(dependency != nil, "No dependency found for \(key)! must register a dependency before resolve.")
        
        return dependency!
    }
}
