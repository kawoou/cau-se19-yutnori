//
//  CheckerTable.swift
//  Yutnori
//
//  Created by Kawoou on 28/05/2019.
//  Copyright © 2019 kawoou. All rights reserved.
//

import RealmSwift

final class CheckerTable: Object {

    // MARK: - Property

    @objc dynamic var id: Int = 0
    @objc dynamic var playerId: Int = 0
    @objc dynamic var gameId: Int = 0
    @objc dynamic var dependCheckerId: Int = -1
    @objc dynamic var status: Int = 0
    @objc dynamic var area: Int = 0
    @objc dynamic var prevArea: String = ""
    @objc dynamic var createdAt = Date()

    // MARK: - Realm

    override class func primaryKey() -> String? {
        return "id"
    }
}

extension CheckerTable: TableSupport {
    convenience init(_ model: Checker) {
        self.init()

        id = model.id
        playerId = model.playerId
        gameId = model.gameId
        dependCheckerId = model.dependCheckerId ?? -1
        status = model.status.rawValue
        area = model.area
        prevArea = model.prevArea.map { "\($0)" }
            .joined(separator: "/")
        createdAt = model.createdAt
    }
}

extension Checker: EntitySupport {
    init(_ table: CheckerTable) {
        id = table.id
        playerId = table.playerId
        gameId = table.gameId
        if table.dependCheckerId == -1 {
            dependCheckerId = nil
        } else {
            dependCheckerId = table.dependCheckerId
        }
        status = CheckerState(rawValue: table.status) ?? .idle
        area = table.area
        prevArea = table.prevArea.split(separator: "/")
            .map { Int($0)! }
        createdAt = table.createdAt
    }
}

