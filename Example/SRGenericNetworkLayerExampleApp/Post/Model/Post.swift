//
//  Post.swift
//  SRGenericNetworkLayerSampleApp
//
//  Created by Siamak Rostami on 9/20/24.
//


// MARK: - Post.swift

import Foundation

struct Post: Codable, Identifiable {
    let id: Int
    let title: String
    let body: String
}