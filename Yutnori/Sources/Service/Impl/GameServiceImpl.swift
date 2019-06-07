//
//  GameServiceImpl.swift
//  Yutnori
//
//  Created by Kawoou on 30/05/2019.
//  Copyright © 2019 kawoou. All rights reserved.
//

import RxCocoa
import RxSwift

final class GameServiceImpl: GameService {

    // MARK: - Private

    private let repository: RepositoryDependency

    // MARK: - Public

    func find(by id: Int) -> Single<Game> {
        return repository.game.find(by: id)
    }

    func create(maxPlayerCount: Int) -> Single<Game> {
        let game = Game(
            id: 0,
            status: .waiting,
            turnCount: 0,
            playerCount: 0,
            maxPlayerCount: maxPlayerCount,
            createdAt: Date()
        )
        return repository.game.save(game)
    }
    func observe(id: Int) -> Observable<Game?> {
        return repository.game.observe(id: id)
    }
    func join(game: Game, player: Player) -> Single<Player> {
        var oldGame = game
        return repository.game.find(by: game.id)
            .map { game in
                oldGame = game

                var game = game
                game.playerCount += 1

                guard game.playerCount <= game.maxPlayerCount else {
                    throw GameServiceError.overflowPlayer
                }
                return game
            }
            .flatMap { [repository] in repository.game.save($0) }
            .flatMap { [repository] game in
                repository.player.find(by: player.id)
                    .map { (game, $0) }
            }
            .flatMap { [repository] (newGame, player) in
                var player = player
                player.gameId = newGame.id

                return repository.player.save(player)
                    /// 사용자 정보 업데이트에 실패했다면,
                    /// 게임 정보를 처음 상태로 다시 저장하고 에러를 반환한다.
                    .catchError { _ in
                        repository.game.save(oldGame)
                            .flatMap { _ in
                                .error(GameServiceError.failedToJoinGame)
                            }
                    }
            }
    }
    func start(game: Game) -> Single<Game> {
        return repository.game.find(by: game.id)
            .map { game in
                guard game.status == .waiting else {
                    throw GameServiceError.alreadyStarted
                }
                var game = game
                game.status = .starting
                game.turnCount = 0
                return game
            }
            .flatMap { [repository] in repository.game.save($0) }
    }
    func nextTurn(game: Game) -> Single<Game> {
        return Observable
            .combineLatest(
                repository.game.find(by: game.id).asObservable(),
                repository.checker.findAll(by: game).asObservable()
            ) { ($0, $1) }
            .flatMapLatest { [repository] (game, checkers) -> Observable<Game> in
                guard game.status == .starting else {
                    throw GameServiceError.notStarted
                }

                var dict = [Int: Int]()
                let maxCheckerCount = checkers.count / game.maxPlayerCount
                checkers.forEach { checker in
                    switch checker.status {
                    case .done:
                        dict[checker.playerId] = (dict[checker.playerId] ?? 0) + 1
                    case .depend where checkers.first(where: { $0.id == checker.dependCheckerId! })?.status == .done:
                        dict[checker.playerId] = (dict[checker.playerId] ?? 0) + 1
                    default:
                        break
                    }
                }

                var game = game
                if let playerId = dict.first(where: { $0.value == maxCheckerCount })?.key {
                    game.status = .finished
                    return repository.player.findAll(by: game)
                        .asObservable()
                        .map { list -> [Player] in
                            list.map { player in
                                var player = player
                                if player.id == playerId {
                                    player.status = .victory
                                } else {
                                    player.status = .done
                                }
                                return player
                            }
                        }
                        .flatMap { list in
                            Observable
                                .combineLatest(
                                    list.map { player -> Observable<Player> in
                                        return repository.player.save(player).asObservable()
                                    }
                                )
                                .map { _ in }
                        }
                        .asObservable()
                        .map { _ in game }
                } else {
                    game.turnCount += 1
                    return .just(game)
                }
            }
            .take(1)
            .asSingle()
            .flatMap { [repository] in repository.game.save($0) }
    }
    func destory(game: Game) -> Single<Void> {
        return repository.game.delete(id: game.id)
    }

    // MARK: - Lifecycle

    init(repository: RepositoryDependency) {
        self.repository = repository
    }
}
