//
//  JSOperation.swift
//  UIKit.js
//
//  Created by Hank Brekke on 1/21/19.
//  Copyright © 2019 Hank Brekke. All rights reserved.
//

import Foundation

public struct JSOperation {
    let moduleName: String
    let functionName: String

    public init(module: String, function: String) {
        self.moduleName = module
        self.functionName = function
    }

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
