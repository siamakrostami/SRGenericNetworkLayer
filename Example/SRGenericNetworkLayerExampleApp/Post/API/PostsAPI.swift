//
//  PostsAPI.swift
//  SRGenericNetworkLayerSampleApp
//
//  Created by Siamak Rostami on 9/20/24.
//


// MARK: - PostsAPI.swift

import Foundation
import SRGenericNetworkLayer

struct PostsAPI: NetworkRouter {
    var baseURLString: String { return "https://jsonplaceholder.typicode.com" }
    var method: RequestMethod? { return .get }
    var path: String { return "/posts" }
    var headers: [String: String]? { return nil }
    var params: Parameters? { return nil }
    var queryParams: QueryParameters? { return nil }
}
