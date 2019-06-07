//
//  RepositorySpec.swift
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
class RepositorySpec: QuickSpec {
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
        describe("Repository's") {
            context("when save the not exist object") {
                var result: Checker!

                beforeEach {
                    result = try? sut.save(DummyChecker.idle).toBlocking().single()
                }
                it("id of result should be issued") {
                    expect(result.id).notTo(equal(0))
                }
                it("entity should be saved in the realm") {
                    expect(
                        mockDependency.core.realm
                            .object(ofType: CheckerTable.self, forPrimaryKey: result.id)
                            .flatMap { Checker($0) }
                        ).to(equal(result))
                }

                context("after save the exist object") {
                    var updateResult: Checker!

                    beforeEach {
                        var updateEntity = result!
                        updateEntity.area = 10
                        updateResult = try? sut.save(updateEntity).toBlocking().single()
                    }
                    it("updateResult's id should equal to result's id") {
                        expect(updateResult.id) == result.id
                    }
                    it("entity should be saved in the realm") {
                        expect(
                            mockDependency.core.realm
                                .object(ofType: CheckerTable.self, forPrimaryKey: result.id)
                                .flatMap { Checker($0) }
                            ).to(equal(updateResult))
                    }
                }
                context("after delete") {
                    context("exist object") {
                        beforeEach {
                            try! sut.delete(id: result.id).toBlocking().single()
                        }
                        it("entity not should be found in the realm") {
                            expect(
                                mockDependency.core.realm
                                    .object(ofType: CheckerTable.self, forPrimaryKey: result.id)
                                ).to(beNil())
                        }
                    }
                    context("not exist object") {
                        var error: Error!

                        beforeEach {
                            do {
                                try sut.delete(id: 0).toBlocking().single()
                            } catch let e {
                                error = e
                            }
                        }
                        it("should be throw exception") {
                            expect(error is AbstractError) == true
                            expect((error as! AbstractError).code) == RepositoryError.notFound.code
                        }
                    }
                }
                context("after clear objects") {
                    beforeEach {
                        try! sut.clear().toBlocking().single()
                    }
                    it("any entity not should be found in the realm") {
                        expect(
                            Array(mockDependency.core.realm.objects(CheckerTable.self))
                            ) == []
                    }
                }

                context("after find by id") {
                    var result: Checker?

                    beforeEach {
                        result = try? sut.find(by: 1).toBlocking().first()
                    }
                    it("result should not be nil") {
                        expect(result).toNot(beNil())
                    }
                }
                context("after find all") {
                    var results: [Checker] = []

                    beforeEach {
                        results = (try? sut.findAll().toBlocking().first()) ?? []
                    }
                    it("number of results should be 1") {
                        expect(results.count) == 1
                    }
                }

                context("after observe by id") {
                    var results = [Checker?]()

                    beforeEach {
                        results = []

                        sut.observe(id: result.id)
                            .subscribe(onNext: {
                                results.append($0)
                            })
                            .disposed(by: disposeBag)
                    }
                    context("and update checker") {
                        beforeEach {
                            var newChecker = result!
                            newChecker.status = .alive
                            _ = try? sut.save(newChecker).toBlocking().single()
                        }
                        it("status of results should be [.idle, .alive]") {
                            expect(results.map { $0?.status })
                                .toEventually(equal([CheckerState.idle, .alive]))
                        }
                    }
                    context("and delete checker") {
                        beforeEach {
                            try? sut.delete(id: result.id).toBlocking().single()
                        }
                        it("status of results should be [.idle, nil]") {
                            expect(results.map { $0?.status })
                                .toEventually(equal([CheckerState.idle, nil]))
                        }
                    }
                }

                context("when observes all") {
                    var results = [[Checker]]()

                    beforeEach {
                        results = []

                        sut.observes()
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
                            try? sut.delete(id: result.id).toBlocking().single()
                        }
                        it("number of results should be [1, 0]") {
                            expect(results.map { $0.count })
                                .toEventually(equal([1, 0]))
                        }
                    }
                }
            }
            context("when find by id") {
                var result: Checker?

                beforeEach {
                    result = try? sut.find(by: 1).toBlocking().first()
                }
                it("result should be nil") {
                    expect(result).to(beNil())
                }
            }
            context("when find all") {
                var results: [Checker] = []

                beforeEach {
                    results = (try? sut.findAll().toBlocking().first()) ?? []
                }
                it("results count should be 0") {
                    expect(results.count) == 0
                }
            }
        }
    }
}
