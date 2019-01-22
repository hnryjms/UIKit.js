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
    var navigationController: UINavigationController { get set }
}

class MyModule: NSObject, JSModule, MyModuleExports {
    let name = "MyModule"
    let controller: UIViewController

    init(_ controller: UIViewController) {
        self.controller = controller
    }

    var navigationController: UINavigationController {
        get {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let splitViewController = appDelegate.window!.rootViewController as! UISplitViewController
            let navigationController = splitViewController.viewControllers[0] as! UINavigationController
            return navigationController
        }

        set {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let splitViewController = appDelegate.window!.rootViewController as! UISplitViewController
            splitViewController.showDetailViewController(newValue, sender: self)
        }
    }
}
