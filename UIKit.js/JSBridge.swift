//
//  Bridge.swift
//  UIKit.js
//
//  Created by Hank Brekke on 12/9/18.
//  Copyright © 2018 Hank Brekke. All rights reserved.
//

import UIKit
import JavaScriptCore

private var isHooksEnabled = false
public class JSBridge {
    let context: JSContext
    var virtualMachine: JSVirtualMachine {
        get { return self.context.virtualMachine }
    }

    public static func enableHooks() throws {
        if isHooksEnabled {
            throw JSError.duplicateCall
        }

        isHooksEnabled = true

        let originalSelector = class_getInstanceMethod(UIViewController.self, #selector(UIViewController.viewDidAppear(_:)))!
        let modifiedSelector = class_getInstanceMethod(UIViewController.self, #selector(UIViewController.js_viewDidAppear(_:)))!

        method_exchangeImplementations(modifiedSelector, originalSelector)
    }

    public init(
        _ bundleURL: URL?,
        modules: [JSModule]? = nil,
        virtualMachine: JSVirtualMachine = JSVirtualMachine()
    ) throws {
        self.context = JSContext(virtualMachine: virtualMachine)

        self.context.setObject(JSNavigationController.self, forKeyedSubscript: "UINavigationController" as NSString)
        self.context.setObject(JSViewController.self, forKeyedSubscript: "UIViewController" as NSString)
        self.context.setObject(UINavigationBar.self, forKeyedSubscript: "UINavigationBar" as NSString)

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

    public func invoke(
        _ operation: JSOperation,
        withArguments arguments: [Any] = [],
        callback: ((JSValue?, JSValue?) -> ())? = nil
    ) {
        let moduleValue: JSValue = self.context.objectForKeyedSubscript(operation.moduleName)
        let result = moduleValue.invokeMethod(operation.functionName, withArguments: arguments)

        if let callbackBlock = callback {
            let promise = self.context.evaluateScript("Promise")

            if result?.isInstance(of: promise) == true {
                let resolver: @convention(block) (JSValue?) -> () = { promiseResult in
                    callbackBlock(promiseResult, nil)
                }
                let rejecter: @convention(block) (JSValue?) -> () = { promiseReject in
                    callbackBlock(nil, promiseReject)
                }

                result!.invokeMethod("then", withArguments: [
                    unsafeBitCast(resolver, to: AnyObject.self),
                    unsafeBitCast(rejecter, to: AnyObject.self)
                    ])
            } else {
                callbackBlock(result, nil)
            }
        }
    }
}
