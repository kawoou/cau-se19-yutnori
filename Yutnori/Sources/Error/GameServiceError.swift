//
//  GameServiceError.swift
//  Yutnori
//
//  Created by Kawoou on 30/05/2019.
//  Copyright © 2019 kawoou. All rights reserved.
//

enum GameServiceError: Int, AbstractError {
    case overflowPlayer
    case failedToJoinGame
    case alreadyStarted
    case notStarted

    var baseCode: Int {
        return 2100
    }
    var reason: String {
        switch self {
        case .overflowPlayer:
            return "게임에 사용자가 꽉 찼습니다."
        case .failedToJoinGame:
            return "게임에 참가하는데 실패했습니다."
        case .alreadyStarted:
            return "이미 시작된 게임입니다."
        case .notStarted:
            return "게임이 시작되지 않았습니다."
        }
    }
}
