//
//  GameTable.swift
//  Yutnori
//
//  Created by Kawoou on 28/05/2019.
//  Copyright © 2019 kawoou. All rights reserved.
//

import RealmSwift

final class GameTable: Object {

    // MARK: - Property
    
    @objc dynamic var id: Int = 0
    @objc dynamic var status: Int = 0
    @objc dynamic var turnCount: Int = 0
    @objc dynamic var playerCount: Int = 0
    @objc dynamic var maxPlayerCount: Int = 0
    @objc dynamic var createdAt = Date()

    // MARK: - Realm

    override class func primaryKey() -> String? {
        return "id"
    }
}

extension GameTable: TableSupport {
    convenience init(_ model: Game) {
        self.init()

        id = model.id
        status = model.status.rawValue
        turnCount = model.turnCount
        playerCount = model.playerCount
        maxPlayerCount = model.maxPlayerCount
        createdAt = model.createdAt
    }
}

extension Game: EntitySupport {
    init(_ table: GameTable) {
        id = table.id
        status = GameState(rawValue: table.status) ?? .waiting
        turnCount = table.turnCount
        playerCount = table.playerCount
        maxPlayerCount = table.maxPlayerCount
        createdAt = table.createdAt
    }
}
