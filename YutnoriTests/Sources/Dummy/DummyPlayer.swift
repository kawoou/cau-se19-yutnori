//
//  DummyPlayer.swift
//  YutnoriTests
//
//  Created by Kawoou on 03/06/2019.
//  Copyright © 2019 kawoou. All rights reserved.
//

import Foundation

@testable import Yutnori
class DummyPlayer {
    static var noGame: Player {
        return Player(
            id: 1,
            gameId: nil,
            status: .waiting,
            createdAt: Date()
        )
    }
    static var waiting: Player {
        return Player(
            id: 0,
            gameId: 1,
            status: .waiting,
            createdAt: Date()
        )
    }
    static var playing: Player {
        return Player(
            id: 1,
            gameId: 1,
            status: .playing,
            createdAt: Date()
        )
    }
    static var done: Player {
        return Player(
            id: 2,
            gameId: 1,
            status: .done,
            createdAt: Date()
        )
    }
    static var victory: Player {
        return Player(
            id: 1,
            gameId: 1,
            status: .victory,
            createdAt: Date()
        )
    }
}
