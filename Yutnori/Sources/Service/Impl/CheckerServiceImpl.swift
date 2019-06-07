//
//  CheckerServiceImpl.swift
//  Yutnori
//
//  Created by Kawoou on 28/05/2019.
//  Copyright © 2019 kawoou. All rights reserved.
//

import RxCocoa
import RxSwift

/* Area Index
 *
 * 10  9  8  7  6  5
 * 11 25        20 4
 * 12   26    21   3
 *         22
 * 13   23    27   2
 * 14 24        28 1
 * 15 16 17 18 19  0
 */
final class CheckerServiceImpl: CheckerService {

    // MARK: - Enumerable

    private enum Direction {
        case move(Int)
        case choice([Int], skip: Int)
        case special(processor: (_ prev: Int) -> Direction)

        func choiceList(prevArea: Int) -> [Int] {
            switch self {
            case .move(let next):
                return [next]
            case .choice(let choice, skip: _):
                return choice
            case .special(let processor):
                return processor(prevArea).choiceList(prevArea: prevArea)
            }
        }
    }

    // MARK: - Constant

    private struct Constant {
        static let direction: [Direction] = [
            /*00 - 04*/ .move(1), .move(2), .move(3), .move(4), .move(5),
            /*05 - 09*/ .choice([6, 20], skip: 6), .move(7), .move(8), .move(9), .move(10),
            /*10 - 14*/ .choice([11, 25], skip: 11), .move(12), .move(13), .move(14), .move(15),
            /*15 - 19*/ .move(16), .move(17), .move(18), .move(19), .move(0),
            /*20 - 21*/ .move(21), .move(22),
            /*22 - 22*/ .special {
                switch $0 {
                case 21:
                    return .choice([23, 27], skip: 23)
                default:
                    return .move(27)
                }
            },
            /*23 - 24*/ .move(24), .move(15),
            /*25 - 26*/ .move(26), .move(22),
            /*27 - 28*/ .move(28), .move(0)
        ]
    }

    // MARK: - Private

    private let repository: RepositoryDependency

    private func moveArea(checker: Checker, direction: Direction, index: Int, choice: Int?, prev: Int) throws -> Int {
        switch (direction, index) {
        case (.move(let next), _):
            return next
        case (.choice(let list, _), 0):
            if let choice = choice, list.contains(choice) {
                return choice
            }
            throw CheckerServiceError.cannotMoveChecker
        case (.choice(_, let skip), _):
            return skip
        case (.special(let processor), _):
            return try moveArea(
                checker: checker,
                direction: processor(prev),
                index: index,
                choice: choice,
                prev: prev
            )
        }
    }

    private func moveArea(checker: Checker, move: Int, choice: Int? = nil) throws -> (prev: [Int], curr: Int) {
        var prev = [Int]()
        var lastPrev = checker.prevArea.last!
        let curr = try (0..<move).reduce(checker.area) { (newArea, index) in
            if checker.area != 0 && newArea == 0 {
                return newArea
            }

            defer {
                prev.append(newArea)
                lastPrev = newArea
            }
            return try moveArea(
                checker: checker,
                direction: Constant.direction[newArea],
                index: index,
                choice: choice,
                prev: lastPrev
            )
        }
        return (prev: prev, curr: curr)
    }

    // MARK: - Public

    func getNextChoices(checker: Checker) -> [Int] {
        switch checker.status {
        case .idle, .alive:
            return Constant.direction[checker.area].choiceList(prevArea: checker.prevArea.last!)

        case .depend, .done:
            return []
        }
    }

    func create(with player: Player) -> Single<Checker> {
        let checker = Checker(
            id: 0,
            playerId: player.id,
            gameId: player.gameId!,
            dependCheckerId: nil,
            status: .idle,
            area: 0,
            prevArea: [0],
            createdAt: Date()
        )
        return repository.checker.save(checker)
    }
    func observeCheckers(player: Player) -> Observable<[Checker]> {
        return repository.checker.observes(by: player)
    }
    func move(checker: Checker, count: Int) -> Single<Checker> {
        return repository.checker.find(by: checker.id)
            .map { [weak self] checker -> Checker in
                guard let ss = self else { throw CommonError.nilSelf }

                var checker = checker

                if count == -1 {
                    checker.area = checker.prevArea.popLast()!
                    if checker.area == 0 {
                        checker.status = .idle
                        checker.prevArea = [0]
                    }
                } else {
                    let area = try ss.moveArea(checker: checker, move: count)
                    checker.status = .alive
                    checker.prevArea.append(contentsOf: area.prev)
                    checker.area = area.curr
                    
                    if area.curr == 0 {
                        checker.status = .done
                    }
                }
                return checker
            }
            .flatMap { [repository] in repository.checker.save($0) }
    }
    func move(checker: Checker, count: Int, choice: Int) -> Single<Checker> {
        return repository.checker.find(by: checker.id)
            .map { [weak self] checker -> Checker in
                guard let ss = self else { throw CommonError.nilSelf }

                let area = try ss.moveArea(checker: checker, move: count, choice: choice)

                var checker = checker
                checker.status = .alive
                checker.prevArea.append(contentsOf: area.prev)

                checker.area = area.curr
                if area.curr == 0 {
                    checker.status = .done
                }
                return checker
            }
            .flatMap { [repository] in repository.checker.save($0) }
    }
    func depend(by checker: Checker) -> Single<Checker> {
        var byChecker = checker
        return repository.checker.findAll(by: checker.playerId)
            .map { list -> [Checker] in
                list
                    .filter { other in
                        if other.id != checker.id {
                            return true
                        } else {
                            byChecker = other
                            return false
                        }
                    }
                    .filter { other in
                        switch other.status {
                        case .alive:
                            return other.area == byChecker.area
                        case .depend, .idle, .done:
                            return false
                        }
                    }
            }
            .flatMap { [repository] list in
                Observable
                    .combineLatest(
                        list
                            .map { oldChecker in
                                var oldChecker = oldChecker
                                oldChecker.status = .depend
                                oldChecker.dependCheckerId = checker.id
                                return oldChecker
                            }
                            .map { repository.checker.save($0).asObservable() }
                    )
                    .map { _ in }
                    .take(1)
                    .asSingle()
            }
            .map { _ in byChecker }
    }
    func destory(checker: Checker) -> Single<Void> {
        return repository.checker.delete(id: checker.id)
    }

    func killChecker(by checker: Checker, on game: Game) -> Single<Void> {
        var byChecker = checker

        return repository.checker.findAll(by: game)
            .map { list -> [Checker] in
                list
                    .filter { other in
                        if other.id != checker.id {
                            return true
                        } else {
                            byChecker = other
                            return false
                        }
                    }
                    .filter { other in
                        switch other.status {
                        case .alive:
                            return other.area == byChecker.area
                        case .depend:
                            guard other.dependCheckerId != checker.id else { return false }
                            guard let depend = list.first(where: { $0.id == other.dependCheckerId! }) else { return false }
                            return depend.area == byChecker.area
                        case .idle, .done:
                            return false
                        }
                    }
            }
            .flatMap { [repository] in
                Observable
                    .combineLatest(
                        $0.map { checker -> Observable<Checker> in
                            var checker = checker
                            checker.status = .idle
                            checker.area = 0
                            checker.prevArea = [0]
                            return repository.checker.save(checker).asObservable()
                        }
                    )
                    .map { _ in }
                    .take(1)
                    .asSingle()
            }
    }

    // MARK: - Lifecycle

    init(repository: RepositoryDependency) {
        self.repository = repository
    }
}
