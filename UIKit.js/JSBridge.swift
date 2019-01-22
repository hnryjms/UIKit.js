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

/**
 The `JSBridge` automatically manages JavaScript module bridging, and
 provides methods to load data from JS from native actions.
 */
public class JSBridge {
    let context: JSContext
    var virtualMachine: JSVirtualMachine {
        get { return self.context.virtualMachine }
    }

    /**
     Enables core features that require Objective-C method swizzling in
     order to function properly.

     - Experiment: This injected behavior likely belongs as an automated
       opt-out action of constructing a `JSBridge()` instance. It is may
       be removed in a future version.
    */
    public static func enableHooks() throws {
        if isHooksEnabled {
            throw JSError.duplicateCall
        }

        isHooksEnabled = true

        let originalSelector = class_getInstanceMethod(UIViewController.self, #selector(UIViewController.viewDidAppear(_:)))!
        let modifiedSelector = class_getInstanceMethod(UIViewController.self, #selector(UIViewController.js_viewDidAppear(_:)))!

        method_exchangeImplementations(modifiedSelector, originalSelector)
    }

    /**
     Create a new `JSBridge` instance for your application.

     Typically an application will contain only one `JSBridge` that is
     shared across the application lifecycle. This bridge can be stored
     on or near the `@UIApplicationMain` delegate file.

     - Parameters:
       - bundleURL: This file URL points to the JavaScript code that should
         be loaded immediately into the new `JSContext` managed by this bridge.
       - modules: These additional modules are entrypoints into native actions,
         that JS code will have global access via the `name` property.
       - virtualMachine: Override the default `JSVirtualMachine` here to allow
         data from `JSValue` to be sharable with other `JSBridge` or `JSContext`
         instances. *(Note: see Discussion; there seldom is a need for multiple
         bridges within a single app).*
    */
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

    /**
     Load data from JavaScript for use by your application in native
     components, or transmit native event data to JavaScript.

     The JS code must expose modules for them to be callable by this
     method. With vanilla JS, that means appending your module to the
     root `this` property, such as:

     ```
     class MyModule {
         static async MyAction() { }
     }
     this.MyModule = MyModule;
     ```

     Using the `webpack` bundler means using the `global` object instead
     of the root `this` property, such as:

     ```
     export default class MyModule {
         static async MyAction() { }
     }

     global.MyModule = MyModule;
     ```

     - Parameters:
       - operation: The JavaScript `module` and `function` to be invoked.
       - arguments: Optional arguments for the JS function invocation.
       - callback: Optional callback for the completion of this function,
         including the resolve/reject of any async JS promise.
    */
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
