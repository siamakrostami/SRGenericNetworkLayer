
import Foundation
import UIKit

enum ConnectionHeaders: String{
    case
    keepAlive = "keep-alive",
    close = "close"
    static var name: String{
        return "connection"
    }
}

enum AcceptHeaders: String{
    case
    all = "*/*",
    applicationJson = "application/json",
    applicationJsonUTF8 = "application/json; charset=utf-8",
    text = "text/plain",
    combinedAll = "application/json, text/plain, */*"
    static var name: String {
        return "accept"
    }
}

enum ContentTypeHeaders: String{
    case
    applicationJson = "application/json",
    applicationJsonUTF8 = "application/json; charset=utf-8",
    urlEncoded = "application/x-www-form-urlencoded",
    formData = "multipart/form-data"
    static var name: String {
        return "content-type"
    }
}

enum AcceptEncodingHeaders: String{
    case
    gzip = "gzip",
    compress = "compress",
    deflate = "deflate",
    br = "br",
    identity = "identity",
    all = "*"
    static var name: String {
        return "accept-encoding"
    }
}

enum AcceptlanguageHeaders: String{
    case
    en = "en",
    fa = "fa",
    all = "*"
    static var name: String {
        return "accept-language"
    }
}

// MARK: - HeaderHandler

class HeaderHandler {
    // MARK: Lifecycle

    private init() {}

    // MARK: Internal

    static let shared = HeaderHandler()

    @discardableResult
    func addContentTypeHeader(type: ContentTypeHeaders) -> HeaderHandler {
        self.headers.updateValue(type.rawValue, forKey: ContentTypeHeaders.name)
        return self
    }

    @discardableResult
    func addConnectionHeader(type: ConnectionHeaders) -> HeaderHandler {
        self.headers.updateValue(type.rawValue, forKey: ConnectionHeaders.name)
        return self
    }

    @discardableResult
    func addAcceptHeaders(type: AcceptHeaders) -> HeaderHandler {
        self.headers.updateValue(type.rawValue, forKey: AcceptHeaders.name)
        return self
    }

    @discardableResult
    func addAcceptLanguageHeaders(type: AcceptlanguageHeaders) -> HeaderHandler {
        self.headers.updateValue(type.rawValue, forKey: AcceptlanguageHeaders.name)
        return self
    }

    @discardableResult
    func addAcceptEncodingHeaders(type: AcceptEncodingHeaders) -> HeaderHandler {
        self.headers.updateValue(type.rawValue, forKey: AcceptEncodingHeaders.name)
        return self
    }

    @discardableResult
    func addAuthorizationHeader() -> HeaderHandler {
        self.headers.updateValue("Bearer \("YOUR_ACCESS_TOKEN")", forKey: "authorization")
        return self
    }

    @discardableResult
    func addCustomHeader(name: String, value: String) -> HeaderHandler {
        self.headers.updateValue(value, forKey: name)
        return self
    }

    func build() -> [String: String] {
        return self.headers
    }

    // MARK: Private

    private var headers = [String: String]()
}
