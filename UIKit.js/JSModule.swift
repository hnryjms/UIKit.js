//
//  JSModule.swift
//  UIKit.js
//
//  Created by Hank Brekke on 12/9/18.
//  Copyright © 2018 Hank Brekke. All rights reserved.
//

import JavaScriptCore

/**
 This protocol allows your application to define custom modules that
 are accessable to the JavaScript code from a `JSBridge()`.

 When creating modules, you should separate JavaScript-accessable `func`s
 from private actions using a `JSExport` protocol, such as:

 ```
 @objc protocol MyModuleExports: JSExport {
     var coolProperty: String { get set }
     func coolAction(_ message: String, _ options: [String: Any]) -> Bool
 }

 class MyModule: NSObject, JSModule, MyModuleExports {
     let name = "MyModule"

     var coolProperty: String

     func coolAction(_ message: String, _ options: [String: Any]) -> Bool {
         return false
     }
 }
 ```

 At a minimum, functions callable by JavaScript code must be exposed using
 the `@objc` keyword.

 This means arguments will become embedded into the name of the JavaScript function,
 such as `coolActionWithMessageOptions(a, b)`, using camel-case conversions.

 You can avoid arguments by prefixing all Swift `func` arguments with `_` such as the
 example above.
 */
public protocol JSModule: NSObjectProtocol {
    var name: String { get }
}
