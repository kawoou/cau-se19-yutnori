//
//  MockCheckerRepository.swift
//  YutnoriTests
//
//  Created by Kawoou on 03/06/2019.
//  Copyright © 2019 kawoou. All rights reserved.
//

import RxSwift

@testable import Yutnori
class MockCheckerRepository: CheckerRepository {

    // MARK: - Expect

    var expectedFindById: Single<Checker> = .error(MockError.notImplemented)
    var expectedFindAll: Single<[Checker]> = .error(MockError.notImplemented)
    var expectedFindAllByGame: Single<[Checker]> = .error(MockError.notImplemented)
    var expectedFindAllByPlayerId: Single<[Checker]> = .error(MockError.notImplemented)
    var expectedObserveById: Observable<Checker?> = .error(MockError.notImplemented)
    var expectedObserves: Observable<[Checker]> = .error(MockError.notImplemented)
    var expectedObservesByPlayer: Observable<[Checker]> = .error(MockError.notImplemented)
    var expectedSave: Single<Checker>?
    var expectedDelete: Single<Void> = .error(MockError.notImplemented)
    var expectedClear: Single<Void> = .error(MockError.notImplemented)

    var isFindByIdCalled: Bool = false
    var isFindAllCalled: Bool = false
    var isFindAllByGameCalled: Bool = false
    var isFindAllByPlayerIdCalled: Bool = false
    var isObserveByIdCalled: Bool = false
    var isObservesCalled: Bool = false
    var isObservesByPlayerCalled: Bool = false
    var isSaveCalled: Bool = false
    var isDeleteCalled: Bool = false
    var isClearCalled: Bool = false

    var numberOfFindByIdCalled: Int = 0
    var numberOfFindAllCalled: Int = 0
    var numberOfFindAllByGameCalled: Int = 0
    var numberOfFindAllByPlayerIdCalled: Int = 0
    var numberOfObserveByIdCalled: Int = 0
    var numberOfObservesCalled: Int = 0
    var numberOfObservesByPlayerCalled: Int = 0
    var numberOfSaveCalled: Int = 0
    var numberOfDeleteCalled: Int = 0
    var numberOfClearCalled: Int = 0

    // MARK: - Protocol

    func find(by id: Int) -> Single<Checker> {
        isFindByIdCalled = true
        numberOfFindByIdCalled += 1
        return expectedFindById
    }
    func findAll() -> Single<[Checker]> {
        isFindAllCalled = true
        numberOfFindAllCalled += 1
        return expectedFindAll
    }
    func findAll(by game: Game) -> Single<[Checker]> {
        isFindAllByGameCalled = true
        numberOfFindAllByGameCalled += 1
        return expectedFindAllByGame
    }
    func findAll(by playerId: Int) -> Single<[Checker]> {
        isFindAllByPlayerIdCalled = true
        numberOfFindAllByPlayerIdCalled += 1
        return expectedFindAllByPlayerId
    }

    func observe(id: Int) -> Observable<Checker?> {
        isObserveByIdCalled = true
        numberOfObserveByIdCalled += 1
        return expectedObserveById
    }
    func observes() -> Observable<[Checker]> {
        isObservesCalled = true
        numberOfObservesCalled += 1
        return expectedObserves
    }
    func observes(by player: Player) -> Observable<[Checker]> {
        isObservesByPlayerCalled = true
        numberOfObservesByPlayerCalled += 1
        return expectedObservesByPlayer
    }

    func save(_ object: Checker) -> Single<Checker> {
        isSaveCalled = true
        numberOfSaveCalled += 1
        return expectedSave ?? .just(object)
    }
    func delete(id: Int) -> Single<Void> {
        isDeleteCalled = true
        numberOfDeleteCalled += 1
        return expectedDelete
    }
    func clear() -> Single<Void> {
        isClearCalled = true
        numberOfClearCalled += 1
        return expectedClear
    }
}
