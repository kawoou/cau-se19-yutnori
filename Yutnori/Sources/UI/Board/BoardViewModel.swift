//
//  BoardViewModel.swift
//  Yutnori
//
//  Created by Kawoou on 27/05/2019.
//  Copyright © 2019 kawoou. All rights reserved.
//

import RxCocoa
import RxSwift

final class BoardViewModel: ViewModel {
    enum TurnState: Equatable {
        case begin
        case choiceChecker(move: Int)
        case choiceArea(checker: Checker, move: Int, nextArea: [Int])
        case done(checker: Checker)

        static func ==(lhs: TurnState, rhs: TurnState) -> Bool {
            switch (lhs, rhs) {
            case (.begin, .begin):
                return true
            case (.choiceChecker(let lhsMove), .choiceChecker(let rhsMove))
                where lhsMove == rhsMove:
                return true
            case (.choiceArea(let lhsChecker, let lhsMove, let lhsArea), .choiceArea(let rhsChecker, let rhsMove, let rhsArea))
                where lhsChecker.id == rhsChecker.id && lhsMove == rhsMove && lhsArea == rhsArea:
                return true
            case (.done, .done):
                return true
            default:
                return false
            }
        }
    }

    struct Input {
        let gameId: Int

        let shake = PublishRelay<Void>()
        let choiceChecker = PublishRelay<Checker>()
        let choiceArea = PublishRelay<Int>()

        init(gameId: Int) {
            self.gameId = gameId
        }
    }
    struct Output {
        private let disposeBag = DisposeBag()

        let turnState = BehaviorRelay<TurnState>(value: .begin)

        let game: Observable<Game>
        let players: Observable<[Player]>
        let currentPlayer: Observable<Player>
        let checkers: Observable<[Checker]>

        init(input: Input, service: ServiceDependency) {
            game = service.game
                .observe(id: input.gameId)
                .compactMap { $0 }
                .observeOn(MainScheduler.instance)
                .share(replay: 1, scope: .forever)

            input.shake
                .withLatestFrom(turnState)
                .filter { $0 == .begin }
                .map { _ in Int.random(in: 0...5) }
                .map {
                    if $0 == 0 {
                        return -1
                    } else {
                        return $0
                    }
                }
                .map { TurnState.choiceChecker(move: $0) }
                .bind(to: turnState)
                .disposed(by: disposeBag)

            input.choiceChecker
                .withLatestFrom(turnState) { ($0, $1) }
                .compactMap { args -> (Checker, Int)? in
                    guard case .choiceChecker(let move) = args.1 else { return nil }
                    return (args.0, move)
                }
                .flatMapLatest { args -> Observable<TurnState> in
                    let (checker, move) = args
                    let nextAreas = service.checker.getNextChoices(checker: checker)
                    if move > 0, nextAreas.count > 1 {
                        return .just(.choiceArea(checker: checker, move: move, nextArea: nextAreas))
                    } else {
                        return service.checker.move(checker: checker, count: move)
                            .asObservable()
                            .map { TurnState.done(checker: $0) }
                    }
                }
                .bind(to: turnState)
                .disposed(by: disposeBag)

            input.choiceArea
                .withLatestFrom(turnState) { ($0, $1) }
                .compactMap { args -> (Checker, Int, Int)? in
                    guard case .choiceArea(let checker, let move, _) = args.1 else { return nil }
                    return (checker, move, args.0)
                }
                .flatMapLatest { args -> Observable<TurnState> in
                    let (checker, move, choice) = args
                    return service.checker.move(checker: checker, count: move, choice: choice)
                        .asObservable()
                        .map { TurnState.done(checker: $0) }
                }
                .bind(to: turnState)
                .disposed(by: disposeBag)

            turnState
                .compactMap { state -> Checker? in
                    guard case .done(let checker) = state else { return nil }
                    return checker
                }
                .flatMapLatest { service.checker.depend(by: $0).asObservable() }
                .withLatestFrom(game) { ($0, $1) }
                .flatMapLatest { args -> Observable<Game> in
                    let (checker, game) = args
                    return service.checker.killChecker(by: checker, on: game)
                        .asObservable()
                        .map { game }
                }
                .flatMap { service.game.nextTurn(game: $0).asObservable() }
                .map { _ in TurnState.begin }
                .bind(to: turnState)
                .disposed(by: disposeBag)

            players = game
                .flatMapLatest { service.player.observePlayers(game: $0) }
                .observeOn(MainScheduler.instance)
                .share(replay: 1, scope: .forever)

            currentPlayer = players
                .withLatestFrom(game) { $0[$1.turnCount % $0.count] }
                .share(replay: 1, scope: .forever)

            checkers = players
                .flatMapLatest { list in
                    Observable.combineLatest(
                        list.map { service.checker.observeCheckers(player: $0) }
                    ) { list in
                        list.flatMap { $0 }
                            .filter { $0.status == .alive || $0.status == .idle }
                    }
                }
                .observeOn(MainScheduler.instance)
                .share(replay: 1, scope: .forever)

            game.subscribe().disposed(by: disposeBag)
            players.subscribe().disposed(by: disposeBag)
            currentPlayer.subscribe().disposed(by: disposeBag)
            checkers.subscribe().disposed(by: disposeBag)
        }
    }

    // MARK: - Property

    let service: ServiceDependency

    let input: Input
    let output: Output

    // MARK: - Lifecycle

    init(service: ServiceDependency, gameId: Int) {
        self.service = service
        
        input = Input(gameId: gameId)
        output = Output(input: input, service: service)
    }
}
