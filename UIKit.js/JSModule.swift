//
//  JSModule.swift
//  UIKit.js
//
//  Created by Hank Brekke on 12/9/18.
//  Copyright © 2018 Hank Brekke. All rights reserved.
//

import JavaScriptCore

public protocol JSModule: NSObjectProtocol {
    var name: String { get }
}
