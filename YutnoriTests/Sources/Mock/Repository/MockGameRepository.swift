//
//  MockGameRepository.swift
//  YutnoriTests
//
//  Created by Kawoou on 04/06/2019.
//  Copyright © 2019 kawoou. All rights reserved.
//

import RxSwift

@testable import Yutnori
class MockGameRepository: GameRepository {

    // MARK: - Expect

    var expectedFindById: Single<Game> = .error(MockError.notImplemented)
    var expectedFindAll: Single<[Game]> = .error(MockError.notImplemented)
    var expectedObserveById: Observable<Game?> = .error(MockError.notImplemented)
    var expectedObserves: Observable<[Game]> = .error(MockError.notImplemented)
    var expectedSave: Single<Game>?
    var expectedDelete: Single<Void> = .error(MockError.notImplemented)
    var expectedClear: Single<Void> = .error(MockError.notImplemented)

    var isFindByIdCalled: Bool = false
    var isFindAllCalled: Bool = false
    var isObserveByIdCalled: Bool = false
    var isObservesCalled: Bool = false
    var isSaveCalled: Bool = false
    var isDeleteCalled: Bool = false
    var isClearCalled: Bool = false

    var numberOfFindByIdCalled: Int = 0
    var numberOfFindAllCalled: Int = 0
    var numberOfObserveByIdCalled: Int = 0
    var numberOfObservesCalled: Int = 0
    var numberOfSaveCalled: Int = 0
    var numberOfDeleteCalled: Int = 0
    var numberOfClearCalled: Int = 0

    // MARK: - Protocol

    func find(by id: Int) -> Single<Game> {
        isFindByIdCalled = true
        numberOfFindByIdCalled += 1
        return expectedFindById
    }
    func findAll() -> Single<[Game]> {
        isFindAllCalled = true
        numberOfFindAllCalled += 1
        return expectedFindAll
    }
    func observe(id: Int) -> Observable<Game?> {
        isObserveByIdCalled = true
        numberOfObserveByIdCalled += 1
        return expectedObserveById
    }
    func observes() -> Observable<[Game]> {
        isObservesCalled = true
        numberOfObservesCalled += 1
        return expectedObserves
    }
    func save(_ object: Game) -> Single<Game> {
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
