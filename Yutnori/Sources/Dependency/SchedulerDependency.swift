//
//  SchedulerDependency.swift
//  Yutnori
//
//  Created by Kawoou on 29/05/2019.
//  Copyright © 2019 kawoou. All rights reserved.
//

import RxSwift

final class SchedulerDependency {

    // MARK: - Dependency

    let realm: SchedulerType

    // MARK: - Lifecycle

    init(
        realm: SchedulerType = MainScheduler.instance
    ) {
        self.realm = realm
    }

}
