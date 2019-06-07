//
//  MockDependency.swift
//  YutnoriTests
//
//  Created by Kawoou on 31/05/2019.
//  Copyright © 2019 kawoou. All rights reserved.
//

import RealmSwift
import RxSwift

@testable import Yutnori
class MockDependency {

    // MARK: - Core

    lazy var core = CoreDependency(
        realmConfiguration: Realm.Configuration(
            fileURL: nil,
            inMemoryIdentifier: "test.db",
            schemaVersion: 1
        )
    )

    // MARK: - Scheduler

    lazy var scheduler = SchedulerDependency(
        realm: MainScheduler.instance
    )

    // MARK: - Repository

    lazy var checkerRepository = MockCheckerRepository()
    lazy var gameRepository = MockGameRepository()
    lazy var playerRepository = MockPlayerRepository()

    lazy var repository = RepositoryDependency(
        core: core,
        scheduler: scheduler,
        checker: checkerRepository,
        game: gameRepository,
        player: playerRepository
    )

    // MARK: - Service

    lazy var checkerService = MockCheckerService()
    lazy var gameService = MockGameService()
    lazy var playerService = MockPlayerService()

    lazy var service = ServiceDependency(
        repository: repository,
        checker: checkerService,
        game: gameService,
        player: playerService
    )

    // MARK: - App

    lazy var app = AppDependency(
        core: core,
        scheduler: scheduler,
        repository: repository,
        service: service
    )

    init() {
        core.realm.beginWrite()
        core.realm.deleteAll()
        try! core.realm.commitWrite(withoutNotifying: [])
    }
}
