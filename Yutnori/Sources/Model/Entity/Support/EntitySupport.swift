//
//  EntitySupport.swift
//  Yutnori
//
//  Created by Kawoou on 28/05/2019.
//  Copyright © 2019 kawoou. All rights reserved.
//

import RealmSwift

protocol EntitySupport {
    associatedtype Table: Object & TableSupport

    var id: Int { get }

    init(_ table: Table)
}
