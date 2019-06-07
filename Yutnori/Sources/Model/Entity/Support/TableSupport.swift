//
//  TableSupport.swift
//  Yutnori
//
//  Created by Kawoou on 28/05/2019.
//  Copyright © 2019 kawoou. All rights reserved.
//

import Foundation

protocol TableSupport {
    associatedtype Model: EntitySupport

    var id: Int { get set }

    init(_ model: Model)
}
