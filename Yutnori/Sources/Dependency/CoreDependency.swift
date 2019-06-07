//
//  CoreDependency.swift
//  Yutnori
//
//  Created by Kawoou on 29/05/2019.
//  Copyright © 2019 kawoou. All rights reserved.
//

import RealmSwift

final class CoreDependency {

    // MARK: - Dependency

    let realm: RealmType

    // MARK: - Lifecycle

    init(
        realmConfiguration: Realm.Configuration? = nil
    ) {
        let realmPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]

        let url = URL(fileURLWithPath: realmPath).appendingPathComponent("yutnori.realm")

        try? FileManager.default.removeItem(at: url)
        
        Realm.Configuration.defaultConfiguration = realmConfiguration ?? Realm.Configuration(
            fileURL: url,
            schemaVersion: 1,
            migrationBlock: { (migration, oldSchemeVersion) in

            }
        )

        self.realm = try! Realm()
    }
}
