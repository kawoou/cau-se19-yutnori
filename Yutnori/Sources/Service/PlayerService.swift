//
//  Player.swift
//  Yutnori
//
//  Created by Kawoou on 25/05/2019.
//  Copyright © 2019 kawoou. All rights reserved.
//

import RxSwift

protocol PlayerService {
    func create() -> Single<Player>
    func observePlayers(game: Game) -> Observable<[Player]>
    func done(game: Game, victory: Player) -> Single<[Player]>
}
