
import Foundation
import UIKit

public enum ConnectionHeaders: String{
    case
    keepAlive = "keep-alive",
    close = "close"
    public static var name: String{
        return "connection"
    }
}

public enum AcceptHeaders: String{
    case
    all = "*/*",
    applicationJson = "application/json",
    applicationJsonUTF8 = "application/json; charset=utf-8",
    text = "text/plain",
    combinedAll = "application/json, text/plain, */*"
    public static var name: String {
        return "accept"
    }
}

public enum ContentTypeHeaders: String{
    case
    applicationJson = "application/json",
    applicationJsonUTF8 = "application/json; charset=utf-8",
    urlEncoded = "application/x-www-form-urlencoded",
    formData = "multipart/form-data"
    public static var name: String {
        return "content-type"
    }
}

public enum AcceptEncodingHeaders: String{
    case
    gzip = "gzip",
    compress = "compress",
    deflate = "deflate",
    br = "br",
    identity = "identity",
    all = "*"
    public static var name: String {
        return "accept-encoding"
    }
}

public enum AcceptlanguageHeaders: String{
    case
    en = "en",
    fa = "fa",
    all = "*"
    public static var name: String {
        return "accept-language"
    }
}

// MARK: - HeaderHandler

public class HeaderHandler {
    // MARK: Lifecycle

    private init() {}

    // MARK: Internal

    public static let shared = HeaderHandler()

    @discardableResult
    public func addContentTypeHeader(type: ContentTypeHeaders) -> HeaderHandler {
        self.headers.updateValue(type.rawValue, forKey: ContentTypeHeaders.name)
        return self
    }

    @discardableResult
    public func addConnectionHeader(type: ConnectionHeaders) -> HeaderHandler {
        self.headers.updateValue(type.rawValue, forKey: ConnectionHeaders.name)
        return self
    }

    @discardableResult
    public func addAcceptHeaders(type: AcceptHeaders) -> HeaderHandler {
        self.headers.updateValue(type.rawValue, forKey: AcceptHeaders.name)
        return self
    }

    @discardableResult
    public func addAcceptLanguageHeaders(type: AcceptlanguageHeaders) -> HeaderHandler {
        self.headers.updateValue(type.rawValue, forKey: AcceptlanguageHeaders.name)
        return self
    }

    @discardableResult
    public func addAcceptEncodingHeaders(type: AcceptEncodingHeaders) -> HeaderHandler {
        self.headers.updateValue(type.rawValue, forKey: AcceptEncodingHeaders.name)
        return self
    }

    @discardableResult
    public func addAuthorizationHeader(token: String) -> HeaderHandler {
        self.headers.updateValue("Bearer \(token)", forKey: "authorization")
        return self
    }

    @discardableResult
    public func addCustomHeader(name: String, value: String) -> HeaderHandler {
        self.headers.updateValue(value, forKey: name)
        return self
    }

    public func build() -> [String: String] {
        return self.headers
    }

    // MARK: Private

    private var headers = [String: String]()
}
