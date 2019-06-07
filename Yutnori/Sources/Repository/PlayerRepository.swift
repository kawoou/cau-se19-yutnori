//
//  PlayerRepository.swift
//  Yutnori
//
//  Created by Kawoou on 28/05/2019.
//  Copyright © 2019 kawoou. All rights reserved.
//

import RxSwift

protocol PlayerRepository {
    func find(by id: Int) -> Single<Player>
    func findAll(by game: Game) -> Single<[Player]>
    func findAll() -> Single<[Player]>

    func observe(id: Int) -> Observable<Player?>
    func observes() -> Observable<[Player]>
    func observes(by game: Game) -> Observable<[Player]>

    func save(_ object: Player) -> Single<Player>
    func saveAll(_ objects: [Player], update: Bool) -> Single<[Player]>

    func delete(id: Int) -> Single<Void>
    func clear() -> Single<Void>
}
