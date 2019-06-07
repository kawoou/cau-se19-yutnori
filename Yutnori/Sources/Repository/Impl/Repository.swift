//
//  Repository.swift
//  Yutnori
//
//  Created by Kawoou on 28/05/2019.
//  Copyright © 2019 kawoou. All rights reserved.
//

import RealmSwift
import RxSwift

protocol Repository: class {
    associatedtype Entity: EntitySupport

    var realm: RealmType { get }
    var scheduler: SchedulerType { get }

    init(realm: RealmType, scheduler: SchedulerType)
}

extension Repository where Entity.Table.Model == Entity {
    typealias Table = Entity.Table

    func find(by id: Int) -> Single<Entity> {
        return Single
            .deferred { [weak self] () -> Single<Table?> in
                guard let ss = self else { throw CommonError.nilSelf }
                return .just(
                    ss.realm.object(ofType: Table.self, forPrimaryKey: id)
                )
            }
            .map { object in
                guard let object = object else { throw RepositoryError.notFound }
                return Entity(object)
            }
            .subscribeOn(scheduler)
    }
    func findAll() -> Single<[Entity]> {
        return Single
            .deferred { [weak self] () -> Single<Results<Table>> in
                guard let ss = self else { throw CommonError.nilSelf }
                return .just(
                    ss.realm.objects(Table.self)
                )
            }
            .map { $0.map(Entity.init) }
            .subscribeOn(scheduler)
    }

    func observe(id: Int) -> Observable<Entity?> {
        return Observable<Table?>
            .create { [weak self] observer in
                guard let ss = self else {
                    observer.onError(CommonError.nilSelf)
                    return Disposables.create()
                }

                let object = ss.realm.object(ofType: Table.self, forPrimaryKey: id)
                observer.onNext(object)

                let token = object?
                    .observe { result in
                        switch result {
                        case .change(_):
                            observer.onNext(ss.realm.object(ofType: Table.self, forPrimaryKey: id))

                        case .deleted:
                            observer.onNext(nil)
                            observer.onCompleted()

                        case .error(let error):
                            observer.onError(error)
                        }
                    }

                return Disposables.create {
                    token?.invalidate()
                }
            }
            .map { object in
                guard let object = object else { return nil }
                return Entity(object)
            }
            .subscribeOn(scheduler)
    }
    func observes() -> Observable<[Entity]> {
        return Observable<[Table]>
            .create { [weak self] observer in
                guard let ss = self else {
                    observer.onError(CommonError.nilSelf)
                    return Disposables.create()
                }

                let token = ss.realm.objects(Table.self)
                    .observe {
                        switch $0 {
                        case let .initial(results):
                            observer.onNext(Array(results))

                        case let .update(results, _, _, _):
                            observer.onNext(Array(results))

                        case let .error(error):
                            observer.onError(error)
                        }
                }

                return Disposables.create {
                    token.invalidate()
                }
            }
            .map { $0.map(Entity.init) }
            .subscribeOn(scheduler)
    }

    func save(_ object: Entity) -> Single<Entity> {
        return find(by: object.id)
            .map { $0 }
            .catchErrorJustReturn(nil)
            .map { $0 != nil }
            .map { [weak self] isExist in
                guard let ss = self else { throw CommonError.nilSelf }

                guard !isExist else {
                    ss.realm.beginWrite()
                    ss.realm.add(Table(object), update: true)
                    try ss.realm.commitWrite(withoutNotifying: [])
                    return object
                }

                ss.realm.beginWrite()

                let identity = ss.realm.object(ofType: IdentityTable.self, forPrimaryKey: Table.className())
                    ?? IdentityTable(name: Table.className(), identity: 0)
                identity.identity += 1

                var table = Table(object)
                table.id = identity.identity

                ss.realm.add(identity, update: false)
                ss.realm.add(table, update: false)
                try ss.realm.commitWrite(withoutNotifying: [])
                return Entity(table)
            }
            .subscribeOn(scheduler)
    }
    func saveAll(_ objects: [Entity], update: Bool) -> Single<[Entity]> {
        return Single
            .deferred { [weak self] in
                guard let ss = self else { throw CommonError.nilSelf }
                ss.realm.beginWrite()
                ss.realm.add(objects.map { Table($0) }, update: update)
                try ss.realm.commitWrite(withoutNotifying: [])
                return .just(objects)
            }
            .subscribeOn(scheduler)
    }

    func delete(id: Int) -> Single<Void> {
        return Single
            .deferred { [weak self] in
                guard let ss = self else { throw CommonError.nilSelf }
                guard let object = ss.realm.object(ofType: Table.self, forPrimaryKey: id) else { throw RepositoryError.notFound }
                ss.realm.beginWrite()
                ss.realm.delete(object)
                try ss.realm.commitWrite(withoutNotifying: [])
                return .just(Void())
            }
            .subscribeOn(scheduler)
    }
    func clear() -> Single<Void> {
        return Single
            .deferred { [weak self] in
                guard let ss = self else { throw CommonError.nilSelf }

                ss.realm.beginWrite()
                ss.realm.deleteAll()
                try ss.realm.commitWrite(withoutNotifying: [])

                return .just(Void())
            }
            .subscribeOn(scheduler)
    }
}
