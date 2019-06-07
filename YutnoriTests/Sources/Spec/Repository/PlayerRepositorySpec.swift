//
//  PlayerRepositorySpec.swift
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
class PlayerRepositorySpec: QuickSpec {
    override func spec() {
        super.spec()

        var sut: PlayerRepository!
        var mockDependency: MockDependency!

        var disposeBag: DisposeBag!

        beforeEach {
            disposeBag = DisposeBag()

            mockDependency = MockDependency()
            sut = PlayerRepositoryImpl(
                realm: mockDependency.core.realm,
                scheduler: mockDependency.scheduler.realm
            )
        }
        describe("PlayerRepository's") {
            context("when save the not exist object") {
                var result: Player!

                beforeEach {
                    result = try? sut.save(DummyPlayer.waiting).toBlocking().single()
                }
                context("after find all by game") {
                    var results: [Player] = []

                    beforeEach {
                        results = (try? sut.findAll(by: DummyGame.waiting).toBlocking().first()) ?? []
                    }
                    it("number of results should be 1") {
                        expect(results.count) == 1
                    }
                }
                context("after observes by game") {
                    var results = [[Player]]()

                    beforeEach {
                        results = []

                        sut.observes(by: DummyGame.waiting)
                            .subscribe(onNext: {
                                results.append($0)
                            })
                            .disposed(by: disposeBag)
                    }
                    context("and create player") {
                        beforeEach {
                            _ = try? sut.save(DummyPlayer.waiting).toBlocking().single()
                        }
                        it("number of results should be [1, 2]") {
                            expect(results.map { $0.count })
                                .toEventually(equal([1, 1, 2]))
                        }
                    }
                    context("and delete player") {
                        beforeEach {
                            try? sut.delete(id: result.id).toBlocking().single()
                        }
                        it("number of results should be [1, 0]") {
                            expect(results.map { $0.count })
                                .toEventually(equal([1, 1, 0]))
                        }
                    }
                }
            }
        }
    }
}
