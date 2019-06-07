//
//  Player.swift
//  Yutnori
//
//  Created by Kawoou on 28/05/2019.
//  Copyright © 2019 kawoou. All rights reserved.
//

import Foundation

struct Player {
    let id: Int
    var gameId: Int?
    var status: PlayerState
    let createdAt: Date
}
