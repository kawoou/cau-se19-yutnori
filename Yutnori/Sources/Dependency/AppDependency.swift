//
//  AppDependency.swift
//  Yutnori
//
//  Created by Kawoou on 29/05/2019.
//  Copyright © 2019 kawoou. All rights reserved.
//

final class AppDependency {

    // MARK: - Dependency

    let core: CoreDependency
    let scheduler: SchedulerDependency
    let repository: RepositoryDependency
    let service: ServiceDependency

    // MARK: - Lifecycle

    init(
        core: CoreDependency = .init(),
        scheduler: SchedulerDependency = .init(),
        repository: RepositoryDependency? = nil,
        service: ServiceDependency? = nil
    ) {
        let repository = repository ?? .init(core: core, scheduler: scheduler)

        self.core = core
        self.scheduler = scheduler
        self.repository = repository
        self.service = service ?? .init(repository: repository)
    }
}
