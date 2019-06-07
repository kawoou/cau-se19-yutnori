//
//  GameRepositorySpec.swift
//  YutnoriTests
//
//  Created by Kawoou on 03/06/2019.
//  Copyright © 2019 kawoou. All rights reserved.
//

import Quick
import Nimble
import RxBlocking
import RxSwift

@testable import Yutnori
class GameRepositorySpec: QuickSpec {
    override func spec() {
        super.spec()

        var sut: GameRepository!
        var mockDependency: MockDependency!

        var disposeBag: DisposeBag!

        beforeEach {
            disposeBag = DisposeBag()

            mockDependency = MockDependency()
            sut = GameRepositoryImpl(
                realm: mockDependency.core.realm,
                scheduler: mockDependency.scheduler.realm
            )
        }
        describe("GameRepository's") {
            // TODO: Write something
        }
    }
}
