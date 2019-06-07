//
//  CheckRepositorySpec.swift
//  YutnoriTests
//
//  Created by Kawoou on 31/05/2019.
//  Copyright © 2019 kawoou. All rights reserved.
//

import Quick
import Nimble
import RxBlocking
import RxSwift

@testable import Yutnori
class CheckRepositorySpec: QuickSpec {

    override func spec() {
        super.spec()

        var sut: CheckerRepository!
        var mockDependency: MockDependency!

        var disposeBag: DisposeBag!

        beforeEach {
            disposeBag = DisposeBag()

            mockDependency = MockDependency()
            sut = CheckerRepositoryImpl(
                realm: mockDependency.core.realm,
                scheduler: mockDependency.scheduler.realm
            )
        }
        describe("CheckerRepository's") {
            context("when save the not exist object") {
                beforeEach {
                    _ = try? sut.save(DummyChecker.idle).toBlocking().single()
                }
                context("after find all by game") {
                    var results: [Checker] = []

                    beforeEach {
                        results = (try? sut.findAll(by: DummyGame.waiting).toBlocking().first()) ?? []
                    }
                    it("number of results should be 1") {
                        expect(results.count) == 1
                    }
                }
                context("after find all by player id") {
                    var results: [Checker] = []

                    beforeEach {
                        results = (try? sut.findAll(by: 1).toBlocking().first()) ?? []
                    }
                    it("number of results should be 1") {
                        expect(results.count) == 1
                    }
                }
                context("after observes all by player") {
                    var results = [[Checker]]()

                    beforeEach {
                        results = []

                        sut.observes(by: DummyPlayer.playing)
                            .distinctUntilChanged()
                            .subscribe(onNext: {
                                results.append($0)
                            })
                            .disposed(by: disposeBag)
                    }
                    context("and create checker") {
                        beforeEach {
                            _ = try? sut.save(DummyChecker.alive).toBlocking().single()
                        }
                        it("number of results should be [1, 2]") {
                            expect(results.map { $0.count })
                                .toEventually(equal([1, 2]))
                        }
                    }
                    context("and delete checker") {
                        beforeEach {
                            try? sut.delete(id: 1).toBlocking().single()
                        }
                        it("number of results should be [1, 0]") {
                            expect(results.map { $0.count })
                                .toEventually(equal([1, 0]))
                        }
                    }
                }
            }
        }
    }
}

extension Checker: Equatable {
    public static func == (lhs: Checker, rhs: Checker) -> Bool {
        guard lhs.id == rhs.id else { return false }
        guard lhs.area == rhs.area else { return false }
        guard lhs.createdAt == rhs.createdAt else { return false }
        guard lhs.dependCheckerId == rhs.dependCheckerId else { return false }
        guard lhs.gameId == rhs.gameId else { return false }
        guard lhs.playerId == rhs.playerId else { return false }
        guard lhs.prevArea == rhs.prevArea else { return false }
        guard lhs.status == rhs.status else { return false }
        return true
    }
}
