//
//  DummyGame.swift
//  YutnoriTests
//
//  Created by Kawoou on 31/05/2019.
//  Copyright © 2019 kawoou. All rights reserved.
//

import Foundation

@testable import Yutnori
class DummyGame {
    static var waiting: Game {
        return Game(
            id: 1,
            status: .waiting,
            turnCount: 0,
            playerCount: 0,
            maxPlayerCount: 2,
            createdAt: Date()
        )
    }
    static var starting: Game {
        return Game(
            id: 1,
            status: .starting,
            turnCount: 0,
            playerCount: 0,
            maxPlayerCount: 2,
            createdAt: Date()
        )
    }
}
