//
//  ErrorSpec.swift
//  YutnoriTests
//
//  Created by Kawoou on 31/05/2019.
//  Copyright © 2019 kawoou. All rights reserved.
//

import Quick
import Nimble

@testable import Yutnori
class CommonErrorSpec: QuickSpec {

    override func spec() {
        super.spec()

        describe("Error's") {
            context("CommonError") {
                it("error code") {
                    expect(CommonError.nilSelf.code) == 100
                }
            }
            context("RepositoryError") {
                it("error code") {
                    expect(RepositoryError.notFound.code) == 1000
                    expect(RepositoryError.failedToInsert.code) == 1001
                }
            }
            context("CheckerServiceError") {
                it("error code") {
                    expect(CheckerServiceError.cannotMoveChecker.code) == 2000
                }
            }
            context("GameServiceError") {
                it("error code") {
                    expect(GameServiceError.overflowPlayer.code) == 2100
                    expect(GameServiceError.failedToJoinGame.code) == 2101
                    expect(GameServiceError.alreadyStarted.code) == 2102
                    expect(GameServiceError.notStarted.code) == 2103
                }
            }
        }
    }
}
