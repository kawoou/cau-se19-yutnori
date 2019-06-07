//
//  MockDependency.swift
//  YutnoriTests
//
//  Created by Kawoou on 31/05/2019.
//  Copyright © 2019 kawoou. All rights reserved.
//

@testable import Yutnori
class MockDependency: AppDependency {
    lazy var sashaAPI = MockNetworkSasha()
    lazy var sashaService = MockSashaService()

    lazy var core = CoreDependency(
        sashaAPI: sashaAPI
    )
    lazy var service = ServiceDependency(
        core: core,
        sasha: sashaService
    )

    lazy var app = AppDependency(
        core: core,
        service: service
    )
}
