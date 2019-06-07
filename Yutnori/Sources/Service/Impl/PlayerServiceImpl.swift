//
//  PlayerServiceImpl.swift
//  Yutnori
//
//  Created by Kawoou on 30/05/2019.
//  Copyright © 2019 kawoou. All rights reserved.
//

import RxSwift

final class PlayerServiceImpl: PlayerService {

    // MARK: - Private

    private let repository: RepositoryDependency

    // MARK: - Public

    func create() -> Single<Player> {
        let player = Player(
            id: 0,
            gameId: nil,
            status: .waiting,
            createdAt: Date()
        )
        return repository.player.save(player)
    }
    func observePlayers(game: Game) -> Observable<[Player]> {
        return repository.player.observes(by: game)
    }
    func done(game: Game, victory: Player) -> Single<[Player]> {
        return repository.player.findAll(by: game)
            .map { list -> [Player] in
                return list.map { player in
                    var player = player
                    if player.id == victory.id {
                        player.status = .victory
                    } else {
                        player.status = .done
                    }
                    return player
                }
            }
            .flatMap { [repository] in repository.player.saveAll($0, update: true) }
    }

    // MARK: - Lifecycle

    init(repository: RepositoryDependency) {
        self.repository = repository
    }
}
