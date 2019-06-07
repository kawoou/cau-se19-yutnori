//
//  Checker.swift
//  Yutnori
//
//  Created by Kawoou on 28/05/2019.
//  Copyright © 2019 kawoou. All rights reserved.
//

import Foundation

struct Checker {
    let id: Int
    let playerId: Int
    let gameId: Int
    var dependCheckerId: Int?
    var status: CheckerState
    var area: Int
    var prevArea: [Int]
    let createdAt: Date
}
