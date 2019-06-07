//
//  GameRepository.swift
//  Yutnori
//
//  Created by Kawoou on 28/05/2019.
//  Copyright © 2019 kawoou. All rights reserved.
//

import RxSwift

protocol GameRepository {
    func find(by id: Int) -> Single<Game>
    func findAll() -> Single<[Game]>

    func observe(id: Int) -> Observable<Game?>
    func observes() -> Observable<[Game]>

    func save(_ object: Game) -> Single<Game>
    func delete(id: Int) -> Single<Void>
    func clear() -> Single<Void>
}
