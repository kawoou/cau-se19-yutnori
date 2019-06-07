//
//  RepositoryError.swift
//  Yutnori
//
//  Created by Kawoou on 25/05/2019.
//  Copyright © 2019 kawoou. All rights reserved.
//

enum RepositoryError: Int, AbstractError {
    case notFound
    case failedToInsert

    var baseCode: Int {
        return 1000
    }
    var reason: String {
        switch self {
        case .notFound:
            return "데이터를 DB에서 찾을 수 없습니다."
        case .failedToInsert:
            return "데이터를 DB에 등록하는데 실패했습니다."
        }
    }
}
