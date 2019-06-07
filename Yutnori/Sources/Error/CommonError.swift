//
//  CommonError.swift
//  Yutnori
//
//  Created by Kawoou on 25/05/2019.
//  Copyright © 2019 kawoou. All rights reserved.
//

enum CommonError: Int, AbstractError {
    case nilSelf

    var baseCode: Int {
        return 100
    }
    var reason: String {
        switch self {
        case .nilSelf:
            return "원인을 알 수 없는 에러가 발생했습니다."
        }
    }
}
