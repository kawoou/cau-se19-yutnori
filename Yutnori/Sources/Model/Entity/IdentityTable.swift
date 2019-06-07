//
//  IdentityTable.swift
//  Yutnori
//
//  Created by Kawoou on 28/05/2019.
//  Copyright © 2019 kawoou. All rights reserved.
//

import RealmSwift

final class IdentityTable: Object {

    // MARK: - Property

    @objc dynamic var name: String = ""
    @objc dynamic var identity: Int = 1

    // MARK: - Realm

    override class func primaryKey() -> String? {
        return "name"
    }

    // MARK: - Lifecycle

    convenience init(name: String, identity: Int) {
        self.init()

        self.name = name
        self.identity = identity
    }
}
