//
//  ResultViewModel.swift
//  Yutnori
//
//  Created by Kawoou on 31/05/2019.
//  Copyright © 2019 kawoou. All rights reserved.
//

import RxCocoa
import RxSwift

final class ResultViewModel: ViewModel {
    struct Input {
        let game: Game

        let dismiss = PublishRelay<Void>()

        init(game: Game) {
            self.game = game
        }
    }
    struct Output {
        private let disposeBag = DisposeBag()

        let isDone = BehaviorRelay<Bool>(value: false)
        let victory: Observable<Player>

        init(input: Input, service: ServiceDependency) {
            input.dismiss
                .flatMapLatest { service.game.destory(game: input.game) }
                .map { true }
                .bind(to: isDone)
                .disposed(by: disposeBag)

            victory = service.player.observePlayers(game: input.game)
                .compactMap { list in
                    list.first { $0.status == .victory }
                }
                .share(replay: 1, scope: .forever)
        }
    }

    // MARK: - Property

    let service: ServiceDependency

    let input: Input
    let output: Output

    // MARK: - Lifecycle

    init(service: ServiceDependency, game: Game) {
        self.service = service

        input = Input(game: game)
        output = Output(input: input, service: service)
    }
}
