//
//  JSNavigationBar.swift
//  UIKit.js
//
//  Created by Hank Brekke on 12/15/18.
//  Copyright © 2018 Hank Brekke. All rights reserved.
//

import UIKit
import JavaScriptCore

@objc private protocol UINavigationBarJSExport: JSExport {
    var prefersLargeTitles: Bool { get set }
}

extension UINavigationBar: JSModule, UINavigationBarJSExport {
    public var name: String {
        get { return "UINavigationBar" }
    }
}
