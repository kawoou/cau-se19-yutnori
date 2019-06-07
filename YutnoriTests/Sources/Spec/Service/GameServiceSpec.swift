//
//  GameServiceSpec.swift
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
class GameServiceSpec: QuickSpec {
    override func spec() {
        super.spec()

        var sut: GameService!
        var mockDependency: MockDependency!
        var mockCheckerRepository: MockCheckerRepository!
        var mockGameRepository: MockGameRepository!
        var mockPlayerRepository: MockPlayerRepository!

        var disposeBag: DisposeBag!

        beforeEach {
            disposeBag = DisposeBag()

            mockDependency = MockDependency()
            mockCheckerRepository = mockDependency.repository.checker as? MockCheckerRepository
            mockGameRepository = mockDependency.repository.game as? MockGameRepository
            mockPlayerRepository = mockDependency.repository.player as? MockPlayerRepository
            sut = GameServiceImpl(
                repository: mockDependency.repository
            )
        }
        describe("GameService's") {
            context("when find by game id") {
                beforeEach {
                    _ = try? sut.find(by: 1).toBlocking().single()
                }
                it("GameRepository's find by id method should be called") {
                    expect(mockGameRepository.isFindByIdCalled) == true
                }
            }
            context("when create with max player count") {
                var game: Game!
                beforeEach {
                    game = try? sut.create(maxPlayerCount: 5).toBlocking().single()
                }
                it("game's maxPlayerCount should be 5") {
                    expect(game.maxPlayerCount) == 5
                }
                it("GameRepository's ave method should be called") {
                    expect(mockGameRepository.isSaveCalled) == true
                }
            }
            context("when observe by game id") {
                beforeEach {
                    sut.observe(id: 1)
                        .subscribe()
                        .disposed(by: disposeBag)
                }
                it("gameRepository's find by id method should be called") {
                    expect(mockGameRepository.isObserveByIdCalled) == true
                }
            }
            context("when join player in game") {
                var player: Player?

                context("success") {
                    beforeEach {
                        mockGameRepository.expectedFindById = .just(DummyGame.waiting)
                        mockPlayerRepository.expectedFindById = .just(DummyPlayer.noGame)

                        player = try? sut.join(game: DummyGame.waiting, player: DummyPlayer.noGame).toBlocking().single()
                    }
                    it("GameRepository's save method should be called") {
                        expect(mockGameRepository.isSaveCalled) == true
                    }
                    it("player's game id should be 1") {
                        expect(player?.gameId) == 1
                    }
                }
                context("failed") {
                    beforeEach {
                        mockGameRepository.expectedFindById = .just(DummyGame.waiting)
                        mockPlayerRepository.expectedFindById = .just(DummyPlayer.noGame)
                        mockPlayerRepository.expectedSave = .error(MockError.notImplemented)

                        player = try? sut.join(game: DummyGame.waiting, player: DummyPlayer.noGame).toBlocking().single()
                    }
                    it("GameRepository's save method should be called") {
                        expect(mockGameRepository.isSaveCalled) == true
                    }
                    it("player should be nil") {
                        expect(player).to(beNil())
                    }
                }
            }
            context("when start game") {
                var game: Game!

                beforeEach {
                    mockGameRepository.expectedFindById = .just(DummyGame.waiting)

                    game = try? sut.start(game: DummyGame.waiting).toBlocking().single()
                }
                it("game's status should be .starting") {
                    expect(game.status) == .starting
                }
                it("game's turnCount should be 0") {
                    expect(game.turnCount) == 0
                }
                it("GameRepository's save method should be called") {
                    expect(mockGameRepository.isSaveCalled) == true
                }
            }
            context("when next turn game") {
                var newGame: Game!

                context("game over") {
                    beforeEach {
                        let game = Game(
                            id: 1,
                            status: .starting,
                            turnCount: 2,
                            playerCount: 2,
                            maxPlayerCount: 2,
                            createdAt: Date()
                        )
                        let player1 = Player(
                            id: 1,
                            gameId: 1,
                            status: .playing,
                            createdAt: Date()
                        )
                        let player2 = Player(
                            id: 2,
                            gameId: 1,
                            status: .playing,
                            createdAt: Date()
                        )
                        let checker1 = Checker(
                            id: 1,
                            playerId: 1,
                            gameId: 1,
                            dependCheckerId: nil,
                            status: .done,
                            area: 0,
                            prevArea: [18],
                            createdAt: Date()
                        )
                        let checker2 = Checker(
                            id: 2,
                            playerId: 2,
                            gameId: 1,
                            dependCheckerId: nil,
                            status: .alive,
                            area: 18,
                            prevArea: [17],
                            createdAt: Date()
                        )

                        mockGameRepository.expectedFindById = .just(game)
                        mockCheckerRepository.expectedFindAllByGame = .just([
                            checker1,
                            checker2
                        ])
                        mockPlayerRepository.expectedFindAllByGame = .just([
                            player1,
                            player2
                        ])

                        newGame = try? sut.nextTurn(game: game).toBlocking().single()
                    }
                    it("PlayerRepository's save method should be called") {
                        expect(mockPlayerRepository.numberOfSaveCalled) == 2
                    }
                    it("GameRepository's save method should be called") {
                        expect(mockGameRepository.isSaveCalled) == true
                    }
                    it("newGame's status should be .finished") {
                        expect(newGame.status) == .finished
                    }
                }
                context("game playing") {
                    beforeEach {
                        mockGameRepository.expectedFindById = .just(DummyGame.starting)
                        mockCheckerRepository.expectedFindAllByGame = .just([
                            DummyChecker.area(4, prevArea: [3]),
                            DummyChecker.area(3, prevArea: [2])
                        ])

                        newGame = try? sut.nextTurn(game: DummyGame.starting).toBlocking().single()
                    }
                    it("PlayerRepository's save method should not be called") {
                        expect(mockPlayerRepository.numberOfSaveCalled) == 0
                    }
                    it("GameRepository's save method should be called") {
                        expect(mockGameRepository.isSaveCalled) == true 
                    }
                    it("newGame's turnCount should be 1") {
                        expect(newGame.turnCount) == 1
                        expect(newGame.status) == .starting
                    }
                }
            }
            context("when destory game") {
                beforeEach {
                    _ = try? sut.destory(game: DummyGame.waiting).toBlocking().single()
                }
                it("GameRepository's delete by id method should be called") {
                    expect(mockGameRepository.isDeleteCalled) == true
                }
            }
        }
    }
}
