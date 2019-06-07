//
//  CheckerServiceError.swift
//  Yutnori
//
//  Created by Kawoou on 29/05/2019.
//  Copyright © 2019 kawoou. All rights reserved.
//

enum CheckerServiceError: Int, AbstractError {
    case cannotMoveChecker

    var baseCode: Int {
        return 2000
    }
    var reason: String {
        switch self {
        case .cannotMoveChecker:
            return "말을 이동할 수 없습니다."
        }
    }
}
