//
//  UnboxJSValue.swift
//  UIKit.jsExamples
//
//  Created by Hank Brekke on 1/27/19.
//  Copyright © 2019 Hank Brekke. All rights reserved.
//

import Unbox
import JavaScriptCore

func unbox<T: Unboxable>(values: JSValue) throws -> [T] {
    let json = values.toObject()
    if let jsonItems = json as? [UnboxableDictionary] {
        return try Unbox.unbox(dictionaries: jsonItems)
    } else {
        throw UnboxError.invalidData
    }
}

func unbox<T: Unboxable>(value: JSValue) throws -> T {
    let json = value.toObject()
    if let jsonItem = json as? UnboxableDictionary {
        return try Unbox.unbox(dictionary: jsonItem)
    } else {
        throw UnboxError.invalidData
    }
}
