//
//  MockPlayerRepository.swift
//  YutnoriTests
//
//  Created by Kawoou on 04/06/2019.
//  Copyright © 2019 kawoou. All rights reserved.
//

import RxSwift

@testable import Yutnori
class MockPlayerRepository: PlayerRepository {

    // MARK: - Expect

    var expectedFindById: Single<Player> = .error(MockError.notImplemented)
    var expectedFindAllByGame: Single<[Player]> = .error(MockError.notImplemented)
    var expectedFindAll: Single<[Player]> = .error(MockError.notImplemented)
    var expectedObserveById: Observable<Player?> = .error(MockError.notImplemented)
    var expectedObserves: Observable<[Player]> = .error(MockError.notImplemented)
    var expectedObservesByGame: Observable<[Player]> = .error(MockError.notImplemented)
    var expectedSave: Single<Player>?
    var expectedSaveAll: Single<[Player]>?
    var expectedDelete: Single<Void> = .error(MockError.notImplemented)
    var expectedClear: Single<Void> = .error(MockError.notImplemented)

    var isFindByIdCalled: Bool = false
    var isFindAllByGameCalled: Bool = false
    var isFindAllCalled: Bool = false
    var isObserveByIdCalled: Bool = false
    var isObservesCalled: Bool = false
    var isObservesByGameCalled: Bool = false
    var isSaveCalled: Bool = false
    var isSaveAllCalled: Bool = false
    var isDeleteCalled: Bool = false
    var isClearCalled: Bool = false

    var numberOfFindByIdCalled: Int = 0
    var numberOfFindAllByGameCalled: Int = 0
    var numberOfFindAllCalled: Int = 0
    var numberOfObserveByIdCalled: Int = 0
    var numberOfObservesCalled: Int = 0
    var numberOfObservesByGameCalled: Int = 0
    var numberOfSaveCalled: Int = 0
    var numberOfSaveAllCalled: Int = 0
    var numberOfDeleteCalled: Int = 0
    var numberOfClearCalled: Int = 0

    // MARK: - Protocol

    func find(by id: Int) -> Single<Player> {
        isFindByIdCalled = true
        numberOfFindByIdCalled += 1
        return expectedFindById
    }
    func findAll(by game: Game) -> Single<[Player]> {
        isFindAllByGameCalled = true
        numberOfFindAllByGameCalled += 1
        return expectedFindAllByGame
    }
    func findAll() -> Single<[Player]> {
        isFindAllCalled = true
        numberOfFindAllCalled += 1
        return expectedFindAll
    }
    func observe(id: Int) -> Observable<Player?> {
        isObserveByIdCalled = true
        numberOfObserveByIdCalled += 1
        return expectedObserveById
    }
    func observes() -> Observable<[Player]> {
        isObservesCalled = true
        numberOfObservesCalled += 1
        return expectedObserves
    }
    func observes(by game: Game) -> Observable<[Player]> {
        isObservesByGameCalled = true
        numberOfObservesByGameCalled += 1
        return expectedObservesByGame
    }
    func save(_ object: Player) -> Single<Player> {
        isSaveCalled = true
        numberOfSaveCalled += 1
        return expectedSave ?? .just(object)
    }
    func saveAll(_ objects: [Player], update: Bool) -> Single<[Player]> {
        isSaveAllCalled = true
        numberOfSaveAllCalled += 1
        return expectedSaveAll ?? .just(objects)
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
