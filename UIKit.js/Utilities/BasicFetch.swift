//
//  BasicFetch.swift
//  UIKit.js
//
//  Created by Hank Brekke on 1/27/19.
//  Copyright © 2019 Hank Brekke. All rights reserved.
//

import JavaScriptCore
import Foundation

typealias Promise = @convention(block) (JSValue, JSValue) -> (Void)

@objc protocol HeadersExports: JSExport {
    func entries() -> [String: Any]
    func get(_ key: String) -> Any
    func has(_ key: String) -> Bool
    func keys() -> [String]
    func values() -> [Any]
}

class Headers: NSObject, JSModule, HeadersExports {
    let name = "Headers"

    let headers: [AnyHashable: Any]

    init(headers: [AnyHashable: Any]) {
        self.headers = headers
    }

    func entries() -> [String : Any] { return self.headers as! [String: Any] }
    func get(_ key: String) -> Any { return self.headers[key]! }
    func has(_ key: String) -> Bool { return self.headers[key] != nil }
    func keys() -> [String] { return Array(self.headers.keys) as! [String] }
    func values() -> [Any] { return Array(self.headers.values) }
}

@objc protocol ResponseExports: JSExport {
    var headers: Headers { get }
    var ok: Bool { get }
    var redirected: Bool { get }
    var status: Int { get }
    var statusText: String { get }
    var type: String { get }
    var url: String { get }

    func json() -> JSValue
    func text() -> JSValue
}

class Response: NSObject, JSModule, ResponseExports {
    let name = "Response"
    let context: JSContext
    let data: Data?
    let error: Error?

    let headers: Headers
    let redirected: Bool
    let status: Int
    let url: String

    var ok: Bool { get { return 200 ... 299 ~= self.status } }
    var statusText: String { get { return "UNKNOWN" } }
    var type: String { get { return "basic" } }

    init(data: Data?, response: HTTPURLResponse, error: Error?, context: JSContext) {
        self.context = context
        self.data = data
        self.error = error

        self.status = response.statusCode
        self.redirected = false // TODO: discover this value
        self.url = response.url!.absoluteString
        self.headers = Headers(headers: response.allHeaderFields)
    }

    func json() -> JSValue {
        let jsonPromise: Promise = { resole, reject in
            if let data = self.data {
                do {
                    let response = try JSONSerialization.jsonObject(with: data, options: [])
                    resole.call(withArguments: [ response ])
                } catch {
                    reject.call(withArguments: [ error ])
                }
            } else {
                reject.call(withArguments: [])
            }
        }
        let promise = self.context.evaluateScript("Promise")!
        return promise.construct(withArguments: [unsafeBitCast(jsonPromise, to: AnyObject.self)])
    }

    func text() -> JSValue {
        let textPromise: Promise = { resole, reject in
            if let data = self.data {
                let response = String(data: data, encoding: .utf8)!
                resole.call(withArguments: [ response ])
            } else {
                reject.call(withArguments: [])
            }
        }
        let promise = self.context.evaluateScript("Promise")!
        return promise.construct(withArguments: [unsafeBitCast(textPromise, to: AnyObject.self)])
    }
}

func buildFetch(_ context: JSContext) -> @convention(block) (JSValue, JSValue) -> (JSValue) {
    return { destination, options in
        let request = destination.toObject() as! String
        let requestURL = URL(string: request)!

        let buildPromise: Promise = { resolve, reject in
            let session = URLSession(configuration: URLSessionConfiguration.default)

            var request = URLRequest(url: requestURL)

            if options.isObject {
                if options.hasProperty("method") {
                    request.httpMethod = options.forProperty("method").toObject() as? String
                }

                if options.hasProperty("body") {
                    let body = options.forProperty("body").toObject()

                    if let rawBody = body as? String {
                        request.httpBody = rawBody.data(using: .utf8)
                    } else if let jsonBody = body {
                        do {
                            request.httpBody = try JSONSerialization.data(withJSONObject: jsonBody, options: [])
                        } catch {
                            reject.call(withArguments: ["Error with body"])
                            return
                        }
                    } else {
                        reject.call(withArguments: ["Error with body"])
                        return
                    }
                }

                if options.hasProperty("headers") {
                    let headers = options.forProperty("headers").toObject()

                    if let specHeaders = headers as? Headers {
                        specHeaders.entries().forEach({ request.addValue($1 as! String, forHTTPHeaderField: $0) })
                    } else if let rawHeaders = headers as? [String: String] {
                        rawHeaders.forEach({ request.setValue($1, forHTTPHeaderField: $0) })
                    } else {
                        reject.call(withArguments: ["Error with headers"])
                        return
                    }
                }
            }

            let task = session.dataTask(with: request) { data, response, error in
                let response = Response(data: data, response: response as! HTTPURLResponse, error: error, context: context)
                resolve.call(withArguments: [ response ])
            }

            task.resume()
        }

        let promise = context.evaluateScript("Promise")!
        return promise.construct(withArguments: [unsafeBitCast(buildPromise, to: AnyObject.self)])
    }
}
