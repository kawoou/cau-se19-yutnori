//
//  MainViewModel.swift
//  Yutnori
//
//  Created by Kawoou on 30/05/2019.
//  Copyright © 2019 kawoou. All rights reserved.
//

import RxCocoa
import RxSwift

final class MainViewModel: ViewModel {
    struct Input {
        let createGame = PublishRelay<Void>()

        let setPlayerCount = PublishRelay<Int>()
        let setCheckerCount = PublishRelay<Int>()
    }
    struct Output {
        let game: Observable<Game>
        let playerCount: Observable<Int>
        let checkerCount: Observable<Int>

        init(input: Input, service: ServiceDependency) {
            playerCount = input.setPlayerCount
                .observeOn(MainScheduler.instance)
                .share(replay: 1, scope: .forever)

            checkerCount = input.setCheckerCount
                .observeOn(MainScheduler.instance)
                .share(replay: 1, scope: .forever)
            
            game = input.createGame
                .withLatestFrom(playerCount) { ($0, $1) }
                .flatMapLatest { service.game.create(maxPlayerCount: $1) }
                .withLatestFrom(checkerCount) { ($0, $1) }
                .flatMapLatest { (game, checkerCount) -> Observable<Game> in
                    return Observable
                        .combineLatest(
                            (0..<game.maxPlayerCount).map { _ in
                                service.player.create()
                                    .flatMap { service.game.join(game: game, player: $0) }
                                    .asObservable()
                                    .flatMapLatest { player in
                                        Observable.combineLatest(
                                            (0..<checkerCount).map { _ in
                                                service.checker.create(with: player).asObservable()
                                            }
                                        ) { _ in player }
                                    }
                            }
                        ) { _ in game }
                }
                .flatMapLatest { service.game.find(by: $0.id).asObservable() }
                .flatMapLatest { service.game.start(game: $0).asObservable() }
                .observeOn(MainScheduler.instance)
        }
    }

    // MARK: - Property

    let service: ServiceDependency

    let input: Input
    let output: Output

    // MARK: - Lifecycle

    init(service: ServiceDependency) {
        self.service = service
        
        input = Input()
        output = Output(input: input, service: service)
    }
}
