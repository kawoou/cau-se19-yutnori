//
//  CheckerServiceSpec.swift
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
class CheckerServiceSpec: QuickSpec {
    override func spec() {
        super.spec()

        var sut: CheckerService!
        var mockDependency: MockDependency!
        var mockCheckerRepository: MockCheckerRepository!

        var disposeBag: DisposeBag!

        beforeEach {
            disposeBag = DisposeBag()

            mockDependency = MockDependency()
            mockCheckerRepository = mockDependency.repository.checker as? MockCheckerRepository
            sut = CheckerServiceImpl(
                repository: mockDependency.repository
            )
        }
        describe("CheckerService's") {
            context("when called to get next choices for checker") {
                context("at directly move area") {
                    var results: [[Int]] = []

                    beforeEach {
                        results = [
                            0, 1, 2, 3, 4,
                            6, 7, 8, 9,
                            11, 12, 13, 14,
                            15, 16, 17, 18, 19,
                            20, 21,
                            23, 24,
                            25, 26,
                            27, 28
                        ].map {
                            sut.getNextChoices(checker: DummyChecker.area($0, prevArea: [$0]))
                        }
                    }
                    it("results should be next area") {
                        expect(results) == [
                            1, 2, 3, 4, 5,
                            7, 8, 9, 10,
                            12, 13, 14, 15,
                            16, 17, 18, 19, 0,
                            21, 22,
                            24, 15,
                            26, 22,
                            28, 0
                        ].map { [$0] }
                    }
                }
                context("at choice area") {
                    var results: [[Int]] = []

                    beforeEach {
                        results = [5, 10].map {
                            sut.getNextChoices(checker: DummyChecker.area($0, prevArea: [$0]))
                        }
                    }
                    it("results should be choice areas") {
                        expect(results) == [
                            [6, 20],
                            [11, 25]
                        ]
                    }
                }
                context("at special area") {
                    var results: [Int] = []

                    context("from 21") {
                        beforeEach {
                            results = sut.getNextChoices(checker: DummyChecker.area(22, prevArea: [21]))
                        }
                        it("results should be [23, 27]") {
                            expect(results) == [23, 27]
                        }
                    }
                    context("from 26") {
                        beforeEach {
                            results = sut.getNextChoices(checker: DummyChecker.area(22, prevArea: [26]))
                        }
                        it("results should be [27]") {
                            expect(results) == [27]
                        }
                    }
                }
                context("that state is .done") {
                    var results: [Int] = []

                    beforeEach {
                        results = sut.getNextChoices(checker: DummyChecker.done)
                    }
                    it("results should be empty") {
                        expect(results.isEmpty) == true
                    }
                }
                context("that state is .depend") {
                    var results: [Int] = []

                    beforeEach {
                        results = sut.getNextChoices(checker: DummyChecker.depend)
                    }
                    it("results should be empty") {
                        expect(results.isEmpty) == true
                    }
                }
            }
            context("when create with player") {
                beforeEach {
                    _ = try? sut.create(with: DummyPlayer.waiting).toBlocking().single()
                }
                it("CheckerRepository's save should be called") {
                    expect(mockCheckerRepository.isSaveCalled) == true
                }
            }
            context("when observe checkers by player") {
                beforeEach {
                    sut.observeCheckers(player: DummyPlayer.waiting)
                        .subscribe()
                        .disposed(by: disposeBag)
                }
                it("CheckerRepository's observs by player should be called") {
                    expect(mockCheckerRepository.isObservesByPlayerCalled) == true
                }
            }
            context("when move checker and count") {
                var newChecker: Checker!

                context("move back") {
                    beforeEach {
                        let checker = DummyChecker.area(4, prevArea: [2, 3])
                        mockCheckerRepository.expectedFindById = .just(checker)

                        newChecker = try? sut.move(checker: checker, count: -1).toBlocking().single()
                    }
                    it("newChecker's area should be 3") {
                        expect(newChecker.area) == 3
                        expect(newChecker.status) == .alive
                    }
                    it("CheckerRepository's save method should be called") {
                        expect(mockCheckerRepository.isSaveCalled) == true
                    }

                    context("if already area 0") {
                        beforeEach {
                            let checker = DummyChecker.area(0, prevArea: [0])
                            mockCheckerRepository.expectedFindById = .just(checker)

                            newChecker = try? sut.move(checker: checker, count: -1).toBlocking().single()
                        }
                        it("newChecker's area should be 0") {
                            expect(newChecker.area) == 0
                            expect(newChecker.status) == .idle
                        }
                    }
                }
                context("move forward") {
                    beforeEach {
                        let checker = DummyChecker.area(4, prevArea: [3])
                        mockCheckerRepository.expectedFindById = .just(checker)

                        newChecker = try? sut.move(checker: checker, count: 4).toBlocking().single()
                    }
                    it("newChecker's area should be 8") {
                        expect(newChecker.area) == 8
                        expect(newChecker.status) == .alive
                    }
                    it("CheckerRepository's save method should be called") {
                        expect(mockCheckerRepository.isSaveCalled) == true
                    }

                    context("if last area") {
                        beforeEach {
                            let checker = DummyChecker.area(28, prevArea: [27])
                            mockCheckerRepository.expectedFindById = .just(checker)

                            newChecker = try? sut.move(checker: checker, count: 4).toBlocking().single()
                        }
                        it("newChecker's area should be 0") {
                            expect(newChecker.area) == 0
                            expect(newChecker.status) == .done
                        }
                    }
                }
                context("move to choice") {
                    beforeEach {
                        let checker = DummyChecker.area(5, prevArea: [4])
                        mockCheckerRepository.expectedFindById = .just(checker)

                        newChecker = try? sut.move(checker: checker, count: 4, choice: 20).toBlocking().single()
                    }
                    it("newChecker's area should be 23") {
                        expect(newChecker.area) == 23
                        expect(newChecker.status) == .alive
                    }
                    it("CheckerRepository's save method should be called") {
                        expect(mockCheckerRepository.isSaveCalled) == true
                    }

                    context("if last area") {
                        beforeEach {
                            let checker = DummyChecker.area(22, prevArea: [20, 21])
                            mockCheckerRepository.expectedFindById = .just(checker)

                            newChecker = try? sut.move(checker: checker, count: 5, choice: 27).toBlocking().single()
                        }
                        it("newChecker's area should be 0") {
                            expect(newChecker.area) == 0
                            expect(newChecker.status) == .done
                        }
                    }
                }
            }
            context("when depend by checker") {
                beforeEach {
                    let checker = DummyChecker.area(5, prevArea: [3, 4])
                    mockCheckerRepository.expectedFindAllByPlayerId = .just([
                        checker,
                        DummyChecker.area(5, prevArea: [3, 4]),
                        DummyChecker.area(6, prevArea: [4, 5])
                    ])

                    _ = try? sut.depend(by: checker).toBlocking().first()
                }
                it("CheckerRepository's save method should be called") {
                    expect(mockCheckerRepository.numberOfSaveCalled) == 1
                }
            }
            context("when destory checker") {
                beforeEach {
                    _ = try? sut.destory(checker: DummyChecker.alive).toBlocking().single()
                }
                it("CheckerRepository's delete should be called") {
                    expect(mockCheckerRepository.isDeleteCalled) == true
                }
            }
            context("when kill by checker on game") {
                beforeEach {
                    let checker = DummyChecker.area(5, prevArea: [3, 4])
                    mockCheckerRepository.expectedFindAllByGame = .just([
                        checker,
                        DummyChecker.area(5, prevArea: [3, 4]),
                        DummyChecker.area(6, prevArea: [4, 5])
                    ])

                    _ = try? sut.killChecker(by: checker, on: DummyGame.waiting).toBlocking().first()
                }
                it("CheckerRepository's save method should be called") {
                    expect(mockCheckerRepository.numberOfSaveCalled) == 1
                }
            }
        }
    }
}
