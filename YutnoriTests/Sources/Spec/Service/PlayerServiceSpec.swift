//
//  PlayerServiceSpec.swift
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
class PlayerServiceSpec: QuickSpec {
    override func spec() {
        super.spec()

        var sut: PlayerService!
        var mockDependency: MockDependency!
        var mockPlayerRepository: MockPlayerRepository!

        var disposeBag: DisposeBag!

        beforeEach {
            disposeBag = DisposeBag()

            mockDependency = MockDependency()
            mockPlayerRepository = mockDependency.repository.player as? MockPlayerRepository
            sut = PlayerServiceImpl(
                repository: mockDependency.repository
            )
        }
        describe("PlayerService's") {
            context("when create") {
                beforeEach {
                    _ = try? sut.create().toBlocking().single()
                }
                it("PlayerRepository's save method should be called") {
                    expect(mockPlayerRepository.isSaveCalled) == true
                }
            }
            context("when observe players by game") {
                beforeEach {
                    sut.observePlayers(game: DummyGame.waiting)
                        .subscribe()
                        .disposed(by: disposeBag)
                }
                it("PlayerRepository's observes by game method should be called") {
                    expect(mockPlayerRepository.isObservesByGameCalled) == true
                }
            }
            context("when done by game with victory player") {
                var players: [Player] = []

                beforeEach {
                    mockPlayerRepository.expectedFindAllByGame = .just([
                        DummyPlayer.playing,
                        DummyPlayer.done
                    ])

                    players = (try? sut.done(game: DummyGame.starting, victory: DummyPlayer.playing).toBlocking().single()) ?? []
                }
                it("victory of players's id should be 1") {
                    expect(players.first { $0.status == .victory }?.id) == 1
                }
            }
        }
    }
}
