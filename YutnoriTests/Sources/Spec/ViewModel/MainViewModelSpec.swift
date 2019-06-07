//
//  MainViewModelSpec.swift
//  YutnoriTests
//
//  Created by Kawoou on 04/06/2019.
//  Copyright © 2019 kawoou. All rights reserved.
//

import Quick
import Nimble
import RxBlocking
import RxSwift

@testable import Yutnori
class MainViewModelSpec: QuickSpec {
    override func spec() {
        super.spec()

        var sut: MainViewModel!
        var mockDependency: MockDependency!
        var mockGameService: MockGameService!
        var mockPlayerService: MockPlayerService!
        var mockCheckerService: MockCheckerService!

        var disposeBag: DisposeBag!

        beforeEach {
            disposeBag = DisposeBag()

            mockDependency = MockDependency()
            mockCheckerService = mockDependency.service.checker as? MockCheckerService
            mockGameService = mockDependency.service.game as? MockGameService
            mockPlayerService = mockDependency.service.player as? MockPlayerService

            sut = MainViewModel(
                service: mockDependency.service
            )
        }
        describe("MockViewModel's") {
            var game: [Game] = []
            var playerCount: [Int] = []
            var checkerCount: [Int] = []

            beforeEach {
                game = []
                playerCount = []
                checkerCount = []

                sut.output.game
                    .subscribe(onNext: { game.append($0) })
                    .disposed(by: disposeBag)
                sut.output.playerCount
                    .subscribe(onNext: { playerCount.append($0) })
                    .disposed(by: disposeBag)
                sut.output.checkerCount
                    .subscribe(onNext: { checkerCount.append($0) })
                    .disposed(by: disposeBag)
            }

            context("when set player count") {
                beforeEach {
                    sut.input.setPlayerCount.accept(10)
                }
                it("sut's playerCount should equal to 10") {
                    expect(playerCount).toEventually(equal([10]))
                }
            }
            context("when set checker count") {
                beforeEach {
                    sut.input.setCheckerCount.accept(20)
                }
                it("sut's checkerCount should equal to 10") {
                    expect(checkerCount).toEventually(equal([20]))
                }
            }
            context("when received create game") {
                beforeEach {
                    mockGameService.expectedCreate = .just(DummyGame.waiting)
                    mockGameService.expectedFindById = .just(DummyGame.waiting)
                    mockPlayerService.expectedCreate = .just(DummyPlayer.waiting)
                    mockCheckerService.expectedCreate = .just(DummyChecker.idle)

                    sut.input.setCheckerCount.accept(5)
                    sut.input.setPlayerCount.accept(2)
                    sut.input.createGame.accept(Void())
                }
                it("gameService's create method should be called") {
                    expect(mockGameService.isCreateCalled).toEventually(beTrue())
                }
                it("playerService's create method should be called") {
                    expect(mockPlayerService.numberOfCreateCalled).toEventually(equal(2))
                }
                it("gameService's join method should be called") {
                    expect(mockGameService.numberOfJoinCalled).toEventually(equal(2))
                }
                it("checkerService's create method should be called") {
                    expect(mockCheckerService.numberOfCreateCalled).toEventually(equal(10))
                }
                it("gameService's find method should be called") {
                    expect(mockGameService.isFindByIdCalled).toEventually(beTrue())
                }
                it("gameService's start method should be called") {
                    expect(mockGameService.isStartCalled).toEventually(beTrue())
                }
            }
        }
    }
}
