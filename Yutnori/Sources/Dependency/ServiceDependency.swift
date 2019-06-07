//
//  ServiceDependency.swift
//  Yutnori
//
//  Created by Kawoou on 29/05/2019.
//  Copyright © 2019 kawoou. All rights reserved.
//

final class ServiceDependency {

    // MARK: - Dependency

    let checker: CheckerService
    let game: GameService
    let player: PlayerService

    // MARK: - Lifecycle

    init(
        repository: RepositoryDependency,
        checker: CheckerService? = nil,
        game: GameService? = nil,
        player: PlayerService? = nil
    ) {
        self.checker = checker ?? CheckerServiceImpl(repository: repository)
        self.game = game ?? GameServiceImpl(repository: repository)
        self.player = player ?? PlayerServiceImpl(repository: repository)
    }
}
