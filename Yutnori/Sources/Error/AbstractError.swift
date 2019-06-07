//
//  AbstractError.swift
//  Yutnori
//
//  Created by Kawoou on 25/05/2019.
//  Copyright © 2019 kawoou. All rights reserved.
//

protocol AbstractError: Error {
    var baseCode: Int { get }
    var reason: String { get }
    var rawValue: Int { get }
}

extension AbstractError {
    var code: Int {
        return baseCode + rawValue
    }
}
