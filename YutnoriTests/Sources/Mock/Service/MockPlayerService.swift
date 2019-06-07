//
//  MockPlayerService.swift
//  YutnoriTests
//
//  Created by Kawoou on 04/06/2019.
//  Copyright © 2019 kawoou. All rights reserved.
//

import RxSwift

@testable import Yutnori
class MockPlayerService: PlayerService {

    // MARK: - Expect

    var expectedCreate: Single<Player> = .error(MockError.notImplemented)
    var expectedObservePlayers: Observable<[Player]> = .error(MockError.notImplemented)
    var expectedDone: Single<[Player]> = .error(MockError.notImplemented)

    var isCreateCalled: Bool = false
    var isObservePlayersCalled: Bool = false
    var isDoneCalled: Bool = false

    var numberOfCreateCalled: Int = 0
    var numberOfObservePlayersCalled: Int = 0
    var numberOfDoneCalled: Int = 0

    // MARK: - Protocol

    func create() -> Single<Player> {
        isCreateCalled = true
        numberOfCreateCalled += 1
        return expectedCreate
    }
    func observePlayers(game: Game) -> Observable<[Player]> {
        isObservePlayersCalled = true
        numberOfObservePlayersCalled += 1
        return expectedObservePlayers
    }
    func done(game: Game, victory: Player) -> Single<[Player]> {
        isDoneCalled = true
        numberOfDoneCalled += 1
        return expectedDone
    }

}
