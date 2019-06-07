//
//  RealmType.swift
//  Yutnori
//
//  Created by Kawoou on 28/05/2019.
//  Copyright © 2019 kawoou. All rights reserved.
//

import RealmSwift
import RxSwift

protocol RealmType {
    func beginWrite()
    func commitWrite(withoutNotifying tokens: [NotificationToken]) throws

    func add(_ object: Object, update: Bool)
    func add<S: Sequence>(_ objects: S, update: Bool) where S.Iterator.Element: Object

    func delete(_ object: Object)
    func deleteAll()

    func object<Element: Object, KeyType>(ofType type: Element.Type, forPrimaryKey key: KeyType) -> Element?
    func objects<Element: Object>(_ type: Element.Type) -> Results<Element>
}

extension Realm: RealmType {}
