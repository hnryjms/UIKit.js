//
//  UIViewController.swift
//  UIKit.js
//
//  Created by Hank Brekke on 1/21/19.
//  Copyright © 2019 Hank Brekke. All rights reserved.
//

import UIKit
import JavaScriptCore
import ObjectiveC

private var UIViewControllerJSPropertyOnViewDidAppear: UInt8 = 0

@objc private protocol UIViewControllerJSExport: JSExport {
    var navigationController: UINavigationController? { get }
    var title: String? { get set }

    var onViewDidAppear: JSValue? { get set }
}

extension UIViewController: UIViewControllerJSExport {
    var onViewDidAppear: JSValue? {
        get {
            let managedValue = objc_getAssociatedObject(self, &UIViewControllerJSPropertyOnViewDidAppear) as? JSManagedValue
            return managedValue?.value
        }
        set {
            if let oldValue = self.onViewDidAppear {
                oldValue.context.virtualMachine.removeManagedReference(oldValue, withOwner: self)
            }

            let managedValue: JSManagedValue?
            if let newValue = newValue {
                managedValue = JSManagedValue(value: newValue, andOwner: self)
                newValue.context.virtualMachine.addManagedReference(newValue, withOwner: self)
            } else {
                managedValue = nil
            }

            objc_setAssociatedObject(self, &UIViewControllerJSPropertyOnViewDidAppear, managedValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    @objc func js_viewDidAppear(_ animated: Bool) {
        self.onViewDidAppear?.call(withArguments: [animated])

        // because methods are swapped, this calls the original implementation
        self.js_viewDidAppear(animated)
    }
}

// MARK: - Constructor method(s)

@objc private protocol JSViewControllerJSExport: JSExport {
    init?(options: [String: Any])
}

@objc final class JSViewController: UIViewController, JSViewControllerJSExport {
    required init?(options: [String : Any]) {
        if let nibName = options["nibName"] as? String {
            let bundleName = options["bundle"] as? String

            let bundleMatches: (Bundle) -> Bool = { $0.bundleURL.lastPathComponent == bundleName }
            let bundle = Bundle.allFrameworks.first(where: bundleMatches) ??
                Bundle.allBundles.first(where: bundleMatches) ??
                Bundle.main

            super.init(nibName: nibName, bundle: bundle)
        } else {
            super.init()
        }
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
