//
//  GameRepositoryImpl.swift
//  Yutnori
//
//  Created by Kawoou on 28/05/2019.
//  Copyright © 2019 kawoou. All rights reserved.
//

import RxSwift

final class GameRepositoryImpl: GameRepository, Repository {

    // MARK: - Typealias

    typealias Entity = Game

    // MARK: - Property

    let realm: RealmType
    let scheduler: SchedulerType

    // MARK: - Lifecycle

    required init(realm: RealmType, scheduler: SchedulerType) {
        self.realm = realm
        self.scheduler = scheduler
    }
}
