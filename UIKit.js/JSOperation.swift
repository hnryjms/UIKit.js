//
//  JSOperation.swift
//  UIKit.js
//
//  Created by Hank Brekke on 1/21/19.
//  Copyright © 2019 Hank Brekke. All rights reserved.
//

import Foundation

/// Defines the module and function to be called in an invocation of JavaScript code.
public struct JSOperation {
    let moduleName: String
    let functionName: String

    /**
     Creates the reference to an exposed JavaScript operation to be called on
     any `JSBridge()`

     - Parameter module: The name of the JavaScript module attached at the
       `JSContext` global object.
     - Parameter function: The name of the JavaScript function within this
       module.
    */
    public init(module: String, function: String) {
        self.moduleName = module
        self.functionName = function
    }

    /**
     Shortcut syntax for creating a reference to an exposed JavaScript operation
     to be called on any `JSBridge()`

     The `operation` string must be formatted in a JS-like syntax including empty
     trailing parenthesis and a dot-separator, such as:

     ```
     JSOperation("MyModule.myFunctionName()")!
     ```

     It is generally safe to unwrap this value, since the string passed into
     this function will be staticly defined by your application.

     - Parameter operation: This JavaScript-like string includes the module and
       function names in a format that improves Project-Find searches when
       refactoring JS code.
    */
    public init?(_ operation: String) {
        let regex = try! NSRegularExpression(pattern: "([a-z$_0-9]+)\\.([a-z_0-9]+)\\(\\)", options: [ .caseInsensitive ])
        let operationData = regex.matches(in: operation, options: .anchored, range: NSRange(operation.startIndex..., in: operation)).last
        if operationData?.numberOfRanges != 3 {
            return nil
        }

        self.moduleName = String(operation[Range(operationData!.range(at: 1), in: operation)!])
        self.functionName = String(operation[Range(operationData!.range(at: 2), in: operation)!])
    }
}
