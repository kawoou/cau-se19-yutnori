//
//  ResultViewModelSpec.swift
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
class ResultViewModelSpec: QuickSpec {
    override func spec() {
        super.spec()

        var sut: ResultViewModel!
        var mockDependency: MockDependency!
        var mockGameService: MockGameService!
        var mockPlayerService: MockPlayerService!

        var disposeBag: DisposeBag!

        beforeEach {
            disposeBag = DisposeBag()

            mockDependency = MockDependency()
            mockGameService = mockDependency.service.game as? MockGameService
            mockPlayerService = mockDependency.service.player as? MockPlayerService

            mockPlayerService.expectedObservePlayers = .just(
                [DummyPlayer.done, DummyPlayer.victory]
            )

            sut = ResultViewModel(
                service: mockDependency.service,
                game: DummyGame.waiting
            )
        }
        describe("ResultViewModel's") {
            var isDone: [Bool] = []
            var victory: [Player] = []

            beforeEach {
                victory = []

                sut.output.isDone
                    .subscribe(onNext: { isDone.append($0) })
                    .disposed(by: disposeBag)
                sut.output.victory
                    .subscribe(onNext: { victory.append($0) })
                    .disposed(by: disposeBag)
            }
            it("initial state") {
                expect(isDone.first).toEventually(beFalse())
                expect(victory.first).toNotEventually(beNil())
                expect(victory.first?.status).toEventually(equal(.victory))
            }
            context("when receive dismiss") {
                beforeEach {
                    mockGameService.expectedDestory = .just(Void())

                    sut.input.dismiss.accept(Void())
                }
                it("gameService's destory method should be called") {
                    expect(mockGameService.isDestoryCalled) == true
                }
                it("sut's isDone should be true") {
                    expect(isDone.last).toEventually(beTrue())
                }
            }
        }
    }
}
