//
//  Game.swift
//  Yutnori
//
//  Created by Kawoou on 28/05/2019.
//  Copyright © 2019 kawoou. All rights reserved.
//

import Foundation

struct Game {
    let id: Int
    var status: GameState
    var turnCount: Int
    var playerCount: Int
    let maxPlayerCount: Int
    let createdAt: Date
}
