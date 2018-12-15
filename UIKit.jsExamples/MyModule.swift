//
//  MyModule.swift
//  UIKit.jsExamples
//
//  Created by Hank Brekke on 12/9/18.
//  Copyright © 2018 Hank Brekke. All rights reserved.
//

import UIKit
import UIKitJS
import JavaScriptCore

@objc protocol MyModuleExports: JSExport {
    func alert(message: String)
}

class MyModule: NSObject, JSModule, MyModuleExports {
    let name = "MyModule"
    
    func alert(message: String) {
        print("hello \(message)")
    }
}
