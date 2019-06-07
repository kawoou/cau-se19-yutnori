//
//  PlayerTable.swift
//  Yutnori
//
//  Created by Kawoou on 28/05/2019.
//  Copyright © 2019 kawoou. All rights reserved.
//

import RealmSwift

final class PlayerTable: Object {

    // MARK: - Property
    
    @objc dynamic var id: Int = 0
    @objc dynamic var gameId: Int = 0
    @objc dynamic var status: Int = 0
    @objc dynamic var createdAt = Date()

    // MARK: - Realm

    override class func primaryKey() -> String? {
        return "id"
    }
}

extension PlayerTable: TableSupport {
    convenience init(_ model: Player) {
        self.init()
        
        id = model.id
        gameId = model.gameId ?? 0
        status = model.status.rawValue
        createdAt = model.createdAt
    }
}

extension Player: EntitySupport {
    init(_ table: PlayerTable) {
        id = table.id
        gameId = table.gameId == 0 ? nil : table.gameId
        status = PlayerState(rawValue: table.status) ?? .waiting
        createdAt = table.createdAt
    }
}
