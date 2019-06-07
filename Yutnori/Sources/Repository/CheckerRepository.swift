//
//  CheckerRepository.swift
//  Yutnori
//
//  Created by Kawoou on 28/05/2019.
//  Copyright © 2019 kawoou. All rights reserved.
//

import RxSwift

protocol CheckerRepository {
    func find(by id: Int) -> Single<Checker>
    func findAll() -> Single<[Checker]>
    func findAll(by game: Game) -> Single<[Checker]>
    func findAll(by playerId: Int) -> Single<[Checker]>

    func observe(id: Int) -> Observable<Checker?>
    func observes() -> Observable<[Checker]>
    func observes(by player: Player) -> Observable<[Checker]>

    func save(_ object: Checker) -> Single<Checker>
    func delete(id: Int) -> Single<Void>
    func clear() -> Single<Void>
}
