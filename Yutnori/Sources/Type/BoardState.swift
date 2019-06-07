//
//  GameState.swift
//  Yutnori
//
//  Created by Kawoou on 25/05/2019.
//  Copyright © 2019 kawoou. All rights reserved.
//

enum GameState {
    case waiting
    case starting
    case turn(player: Int)
    case doneTurn
    case finished(winer: Int)
}
