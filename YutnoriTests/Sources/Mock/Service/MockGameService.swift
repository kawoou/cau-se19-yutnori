//
//  MockGameService.swift
//  YutnoriTests
//
//  Created by Kawoou on 04/06/2019.
//  Copyright © 2019 kawoou. All rights reserved.
//

import RxSwift

@testable import Yutnori
class MockGameService: GameService {

    // MARK: - Expect

    var expectedFindById: Single<Game> = .error(MockError.notImplemented)
    var expectedCreate: Single<Game> = .error(MockError.notImplemented)
    var expectedObserveById: Observable<Game?> = .error(MockError.notImplemented)
    var expectedJoin: Single<Player>?
    var expectedStart: Single<Game>?
    var expectedNextTurn: Single<Game>?
    var expectedDestory: Single<Void> = .error(MockError.notImplemented)

    var isFindByIdCalled: Bool = false
    var isCreateCalled: Bool = false
    var isObserveByIdCalled: Bool = false
    var isJoinCalled: Bool = false
    var isStartCalled: Bool = false
    var isNextTurnCalled: Bool = false
    var isDestoryCalled: Bool = false

    var numberOfFindByIdCalled: Int = 0
    var numberOfCreateCalled: Int = 0
    var numberOfObserveByIdCalled: Int = 0
    var numberOfJoinCalled: Int = 0
    var numberOfStartCalled: Int = 0
    var numberOfNextTurnCalled: Int = 0
    var numberOfDestoryCalled: Int = 0

    // MARK: - Protocol

    func find(by id: Int) -> Single<Game> {
        isFindByIdCalled = true
        numberOfFindByIdCalled += 1
        return expectedFindById
    }
    func create(maxPlayerCount: Int) -> Single<Game> {
        isCreateCalled = true
        numberOfCreateCalled += 1
        return expectedCreate
    }
    func observe(id: Int) -> Observable<Game?> {
        isObserveByIdCalled = true
        numberOfObserveByIdCalled += 1
        return expectedObserveById
    }
    func join(game: Game, player: Player) -> Single<Player> {
        isJoinCalled = true
        numberOfJoinCalled += 1
        return expectedJoin ?? .just(player)
    }
    func start(game: Game) -> Single<Game> {
        isStartCalled = true
        numberOfStartCalled += 1
        return expectedStart ?? .just(game)
    }
    func nextTurn(game: Game) -> Single<Game> {
        isNextTurnCalled = true
        numberOfNextTurnCalled += 1
        return expectedNextTurn ?? .just(game)
    }
    func destory(game: Game) -> Single<Void> {
        isDestoryCalled = true
        numberOfDestoryCalled += 1
        return expectedDestory
    }
}
