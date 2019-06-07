//
//  MockCheckerService.swift
//  YutnoriTests
//
//  Created by Kawoou on 04/06/2019.
//  Copyright © 2019 kawoou. All rights reserved.
//

import RxSwift

@testable import Yutnori
class MockCheckerService: CheckerService {

    // MARK: - Expect

    var expectedGetNextChoices: [Int] = []
    var expectedCreate: Single<Checker> = .error(MockError.notImplemented)
    var expectedObserveCheckers: Observable<[Checker]> = .error(MockError.notImplemented)
    var expectedMove: Single<Checker> = .error(MockError.notImplemented)
    var expectedMoveWithChoice: Single<Checker> = .error(MockError.notImplemented)
    var expectedDepend: Single<Checker> = .error(MockError.notImplemented)
    var expectedDestory: Single<Void> = .error(MockError.notImplemented)
    var expectedKillChecker: Single<Void> = .error(MockError.notImplemented)

    var isGetNextChoicesCalled: Bool = false
    var isCreateCalled: Bool = false
    var isObserveCheckersCalled: Bool = false
    var isMoveCalled: Bool = false
    var isMoveWithChoiceCalled: Bool = false
    var isDependCalled: Bool = false
    var isDestoryCalled: Bool = false
    var isKillCheckerCalled: Bool = false

    var numberOfGetNextChoicesCalled: Int = 0
    var numberOfCreateCalled: Int = 0
    var numberOfObserveCheckersCalled: Int = 0
    var numberOfMoveCalled: Int = 0
    var numberOfMoveWithChoiceCalled: Int = 0
    var numberOfDependCalled: Int = 0
    var numberOfDestoryCalled: Int = 0
    var numberOfKillCheckerCalled: Int = 0

    // MARK: - Protocol

    func getNextChoices(checker: Checker) -> [Int] {
        isGetNextChoicesCalled = true
        numberOfGetNextChoicesCalled += 1
        return expectedGetNextChoices
    }
    func create(with player: Player) -> Single<Checker> {
        isCreateCalled = true
        numberOfCreateCalled += 1
        return expectedCreate
    }
    func observeCheckers(player: Player) -> Observable<[Checker]> {
        isObserveCheckersCalled = true
        numberOfObserveCheckersCalled += 1
        return expectedObserveCheckers
    }
    func move(checker: Checker, count: Int) -> Single<Checker> {
        isMoveCalled = true
        numberOfMoveCalled += 1
        return expectedMove
    }
    func move(checker: Checker, count: Int, choice: Int) -> Single<Checker> {
        isMoveWithChoiceCalled = true
        numberOfMoveWithChoiceCalled += 1
        return expectedMoveWithChoice
    }
    func depend(by checker: Checker) -> Single<Checker> {
        isDependCalled = true
        numberOfDependCalled += 1
        return expectedDepend
    }
    func destory(checker: Checker) -> Single<Void> {
        isDestoryCalled = true
        numberOfDestoryCalled += 1
        return expectedDestory
    }
    func killChecker(by checker: Checker, on game: Game) -> Single<Void> {
        isKillCheckerCalled = true
        numberOfKillCheckerCalled += 1
        return expectedKillChecker
    }
}
