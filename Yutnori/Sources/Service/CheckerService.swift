//
//  Checker.swift
//  Yutnori
//
//  Created by Kawoou on 25/05/2019.
//  Copyright © 2019 kawoou. All rights reserved.
//

import RxSwift

protocol CheckerService {
    func getNextChoices(checker: Checker) -> [Int]

    func create(with player: Player) -> Single<Checker>
    func observeCheckers(player: Player) -> Observable<[Checker]>
    func move(checker: Checker, count: Int) -> Single<Checker>
    func move(checker: Checker, count: Int, choice: Int) -> Single<Checker>
    func depend(by checker: Checker) -> Single<Checker>
    func destory(checker: Checker) -> Single<Void>

    func killChecker(by checker: Checker, on game: Game) -> Single<Void>
}
