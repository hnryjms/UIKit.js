//
//  Bridge.swift
//  UIKit.js
//
//  Created by Hank Brekke on 12/9/18.
//  Copyright © 2018 Hank Brekke. All rights reserved.
//

import UIKit
import JavaScriptCore

public class Bridge {
    let context: JSContext
    var virtualMachine: JSVirtualMachine {
        get { return self.context.virtualMachine }
    }

    public init(_ bundleURL: URL?,
                virtualMachine: JSVirtualMachine = JSVirtualMachine(),
                modules: [JSModule]? = nil) throws {
        self.context = JSContext(virtualMachine: virtualMachine)

        modules?.forEach({ module in
            self.context.setObject(module, forKeyedSubscript: module.name as NSString)
        })

        self.context.exceptionHandler = { (context, value) in
            fatalError("JS exception in initialization \(value?.toString() ?? "unknown")")
        }

        if let bundleURL = bundleURL {
            let bundleScript = try String(contentsOf: bundleURL)
            self.context.evaluateScript(bundleScript, withSourceURL: bundleURL)
        }
    }
}
