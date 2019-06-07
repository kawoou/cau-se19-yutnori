//
//  CheckerRepositoryImpl.swift
//  Yutnori
//
//  Created by Kawoou on 28/05/2019.
//  Copyright © 2019 kawoou. All rights reserved.
//

import RealmSwift
import RxSwift

final class CheckerRepositoryImpl: CheckerRepository, Repository {

    // MARK: - Typealias

    typealias Entity = Checker

    // MARK: - Property

    let realm: RealmType
    let scheduler: SchedulerType

    // MARK: - Public

    func findAll(by game: Game) -> Single<[Checker]> {
        return Single
            .deferred { [weak self] () -> Single<Results<Table>> in
                guard let ss = self else { throw CommonError.nilSelf }
                return .just(
                    ss.realm.objects(Table.self)
                        .filter("gameId == %@", game.id)
                )
            }
            .map { $0.map(Entity.init) }
            .subscribeOn(scheduler)
    }

    func findAll(by playerId: Int) -> Single<[Checker]> {
        return Single
            .deferred { [weak self] () -> Single<Results<Table>> in
                guard let ss = self else { throw CommonError.nilSelf }
                return .just(
                    ss.realm.objects(Table.self)
                        .filter("playerId == %@", playerId)
                )
            }
            .map { $0.map(Entity.init) }
            .subscribeOn(scheduler)
    }

    func observes(by player: Player) -> Observable<[Checker]> {
        return Observable<[Table]>
            .create { [weak self] observer in
                guard let ss = self else {
                    observer.onError(CommonError.nilSelf)
                    return Disposables.create()
                }

                let objects = ss.realm.objects(Table.self)
                    .filter("playerId == %@", player.id)

                observer.onNext(Array(objects))

                let token = objects
                    .observe { result in
                        switch result {
                        case .initial(let list):
                            observer.onNext(Array(list))

                        case .update(let list, _, _, _):
                            observer.onNext(Array(list))

                        case .error(let error):
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

    // MARK: - Lifecycle

    required init(realm: RealmType, scheduler: SchedulerType) {
        self.realm = realm
        self.scheduler = scheduler
    }
}
