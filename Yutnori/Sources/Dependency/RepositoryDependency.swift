//
//  RepositoryDependency.swift
//  Yutnori
//
//  Created by Kawoou on 29/05/2019.
//  Copyright © 2019 kawoou. All rights reserved.
//

final class RepositoryDependency {

    // MARK: - Dependency

    let checker: CheckerRepository
    let game: GameRepository
    let player: PlayerRepository

    // MARK: - Lifecycle

    init(
        core: CoreDependency,
        scheduler: SchedulerDependency,
        checker: CheckerRepository? = nil,
        game: GameRepository? = nil,
        player: PlayerRepository? = nil
    ) {
        self.checker = checker ?? CheckerRepositoryImpl(
            realm: core.realm,
            scheduler: scheduler.realm
        )
        self.game = game ?? GameRepositoryImpl(
            realm: core.realm,
            scheduler: scheduler.realm
        )
        self.player = player ?? PlayerRepositoryImpl(
            realm: core.realm,
            scheduler: scheduler.realm
        )
    }
}
