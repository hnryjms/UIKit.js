//
//  UINavigationController.swift
//  UIKit.js
//
//  Created by Hank Brekke on 12/15/18.
//  Copyright © 2018 Hank Brekke. All rights reserved.
//

import UIKit
import JavaScriptCore

@objc private protocol UINavigationControllerJSExport: JSExport {
    var navigationBar: UINavigationBar { get }

    func push(_ viewController: UIViewController, _ animated: Bool)
}

extension UINavigationController: UINavigationControllerJSExport {
    func push(_ viewController: UIViewController, _ animated: Bool) {
        self.pushViewController(viewController, animated: animated)
    }
}

// MARK: - Constructor method(s)

@objc private protocol JSNavigationControllerJSExport: JSExport {
    init?(options: [String: Any])
}

@objc final class JSNavigationController: UINavigationController, JSNavigationControllerJSExport {
    required init?(options: [String: Any]) {
        guard let rootViewController = options["rootViewController"] as? UIViewController else {
            return nil
        }

        super.init(rootViewController: rootViewController)
    }

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
