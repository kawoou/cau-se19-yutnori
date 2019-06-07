//
//  GameService.swift
//  Yutnori
//
//  Created by Kawoou on 25/05/2019.
//  Copyright © 2019 kawoou. All rights reserved.
//

import RxSwift

protocol GameService {
    func find(by id: Int) -> Single<Game>
    func create(maxPlayerCount: Int) -> Single<Game>
    func observe(id: Int) -> Observable<Game?>
    func join(game: Game, player: Player) -> Single<Player>
    func start(game: Game) -> Single<Game>
    func nextTurn(game: Game) -> Single<Game>
    func destory(game: Game) -> Single<Void>
}
