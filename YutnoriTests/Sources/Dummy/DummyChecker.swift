//
//  DummyChecker.swift
//  YutnoriTests
//
//  Created by Kawoou on 31/05/2019.
//  Copyright © 2019 kawoou. All rights reserved.
//

import Foundation

@testable import Yutnori
class DummyChecker {
    static var idle: Checker {
        return Checker(
            id: 0,
            playerId: 1,
            gameId: 1,
            dependCheckerId: nil,
            status: .idle,
            area: 0,
            prevArea: [0],
            createdAt: Date()
        )
    }

    static var alive: Checker {
        return Checker(
            id: 0,
            playerId: 1,
            gameId: 1,
            dependCheckerId: nil,
            status: .alive,
            area: 0,
            prevArea: [0],
            createdAt: Date()
        )
    }

    static var done: Checker {
        return Checker(
            id: 0,
            playerId: 1,
            gameId: 1,
            dependCheckerId: nil,
            status: .done,
            area: 0,
            prevArea: [0],
            createdAt: Date()
        )
    }

    static var depend: Checker {
        return Checker(
            id: 0,
            playerId: 1,
            gameId: 1,
            dependCheckerId: 1,
            status: .depend,
            area: 0,
            prevArea: [0],
            createdAt: Date()
        )
    }

    static var index = 1000
    static func area(_ area: Int, prevArea: [Int]) -> Checker {
        index += 1
        return Checker(
            id: index,
            playerId: 1,
            gameId: 1,
            dependCheckerId: nil,
            status: .alive,
            area: area,
            prevArea: prevArea,
            createdAt: Date()
        )
    }

    private init() {}
}
