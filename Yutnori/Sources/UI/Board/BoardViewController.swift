//
//  BoardViewController.swift
//  Yutnori
//
//  Created by Kawoou on 27/05/2019.
//  Copyright © 2019 kawoou. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import SnapKit

final class BoardViewController: UIViewController {

    // MARK: - Constant

    private struct Constant {
        static let playerColors: [UIColor] = [
            .red,
            .blue,
            .yellow,
            .green,
            .cyan
        ]
    }

    // MARK: - Property

    var viewModel: BoardViewModel?

    // MARK: - Layout

    @IBOutlet weak var turnView: UIView!
    @IBOutlet weak var turnLabel: UILabel!
    @IBOutlet weak var turnNumberLabel: UILabel!
    @IBOutlet weak var choiceLabel: UILabel!
    @IBOutlet weak var choiceStackView: UIStackView!
    @IBOutlet weak var shakeButton: UIButton!
    @IBOutlet weak var customShakeLabel: UILabel!
    @IBOutlet weak var customShakeCount: UIStepper!
    @IBOutlet weak var customShakeButton: UIButton!

    @IBOutlet weak var area0: UIView!
    @IBOutlet weak var area1: UIView!
    @IBOutlet weak var area2: UIView!
    @IBOutlet weak var area3: UIView!
    @IBOutlet weak var area4: UIView!
    @IBOutlet weak var area5: UIView!
    @IBOutlet weak var area6: UIView!
    @IBOutlet weak var area7: UIView!
    @IBOutlet weak var area8: UIView!
    @IBOutlet weak var area9: UIView!
    @IBOutlet weak var area10: UIView!
    @IBOutlet weak var area11: UIView!
    @IBOutlet weak var area12: UIView!
    @IBOutlet weak var area13: UIView!
    @IBOutlet weak var area14: UIView!
    @IBOutlet weak var area15: UIView!
    @IBOutlet weak var area16: UIView!
    @IBOutlet weak var area17: UIView!
    @IBOutlet weak var area18: UIView!
    @IBOutlet weak var area19: UIView!
    @IBOutlet weak var area20: UIView!
    @IBOutlet weak var area21: UIView!
    @IBOutlet weak var area22: UIView!
    @IBOutlet weak var area23: UIView!
    @IBOutlet weak var area24: UIView!
    @IBOutlet weak var area25: UIView!
    @IBOutlet weak var area26: UIView!
    @IBOutlet weak var area27: UIView!
    @IBOutlet weak var area28: UIView!

    // MARK: - Private

    private var area: [UIView] = []

    private var actionButtonDisposeBag = DisposeBag()
    private var disposeBag = DisposeBag()

    private func makeCheckerView(checker: Checker, color: UIColor) -> UIView {
        let view = UIView()
        view.backgroundColor = color
        view.clipsToBounds = true
        view.layer.cornerRadius = 10
        return view
    }

    private func makeCheckerButton(_ checker: Checker) -> UIButton {
        let button = UIButton()
        button.backgroundColor = .lightGray
        if checker.status == .idle {
            button.setTitle("New Checker", for: .normal)
        } else {
            button.setTitle("Checker: \(checker.area)", for: .normal)
        }

        button.rx.tap
            .subscribe(onNext: { [weak self] _ in
                self?.viewModel?.input.choiceChecker.accept(checker)
            })
            .disposed(by: actionButtonDisposeBag)

        return button
    }
    private func makeAreaButton(_ area: Int) -> UIButton {
        let button = UIButton()
        button.backgroundColor = .yellow
        button.setTitleColor(UIColor.black, for: .normal)
        button.setTitle("Area: \(area)", for: .normal)

        button.rx.tap
            .subscribe(onNext: { [weak self] _ in
                self?.viewModel?.input.choiceArea.accept(area)
            })
            .disposed(by: actionButtonDisposeBag)

        return button
    }

    private func bindEvents(viewModel: BoardViewModel) {
        disposeBag = DisposeBag()

        _ = viewModel.output.game.filter { $0.status == .finished }
            .take(1)
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] game in
                guard let ss = self else { return }
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let viewController = storyboard.instantiateViewController(withIdentifier: "ResultViewController") as! ResultViewController
                viewController.viewModel = ResultViewModel(service: viewModel.service, game: game)
                ss.present(viewController, animated: true)
            })

        viewModel.output.turnState
            .map { $0.description == nil }
            .bind(to: choiceLabel.rx.isHidden)
            .disposed(by: disposeBag)

        viewModel.output.turnState
            .map { $0.isShake }
            .bind(to: shakeButton.rx.isEnabled)
            .disposed(by: disposeBag)

        viewModel.output.turnState
            .compactMap { $0.description }
            .bind(to: choiceLabel.rx.text)
            .disposed(by: disposeBag)

        let stackViewStream = viewModel.output.turnState
            .distinctUntilChanged()
            .observeOn(MainScheduler.instance)
            .do(onNext: { [weak self] _ in
                self?.actionButtonDisposeBag = DisposeBag()
                self?.choiceStackView.subviews
                    .forEach { $0.removeFromSuperview() }
            })
            .share()

        Observable
            .combineLatest(
                stackViewStream,
                viewModel.output.checkers,
                viewModel.output.currentPlayer
            ) { (state, checkers, currentPlayer) in
                (state, checkers.filter { $0.playerId == currentPlayer.id })
            }
            .compactMap { [weak self] args -> [UIButton]? in
                let (state, checkers) = args
                guard let ss = self else { throw CommonError.nilSelf }
                guard case .choiceChecker = state else { return nil }
                return checkers.map { ss.makeCheckerButton($0) }
            }
            .asDriver(onErrorJustReturn: [])
            .drive(onNext: { [weak self] list in
                list.forEach { self?.choiceStackView.addArrangedSubview($0) }
            })
            .disposed(by: disposeBag)

        stackViewStream
            .compactMap { [weak self] state -> [UIButton]? in
                guard let ss = self else { throw CommonError.nilSelf }
                guard case .choiceArea(_, _, let nextArea) = state else { return nil }
                return nextArea.map { ss.makeAreaButton($0) }
            }
            .asDriver(onErrorJustReturn: [])
            .drive(onNext: { [weak self] list in
                list.forEach { self?.choiceStackView.addArrangedSubview($0) }
            })
            .disposed(by: disposeBag)

        viewModel.output.currentPlayer
            .map { "Player: \($0.id)" }
            .bind(to: turnLabel.rx.text)
            .disposed(by: disposeBag)

        Observable
            .combineLatest(
                viewModel.output.players,
                viewModel.output.currentPlayer
            ) { ($0, $1) }
            .map { args -> Int in
                let (players, currentPlayer) = args
                return players.firstIndex { $0.id == currentPlayer.id } ?? 0
            }
            .map { Constant.playerColors[$0] }
            .bind(to: turnView.rx.backgroundColor)
            .disposed(by: disposeBag)

        viewModel.output.game.map { $0.turnCount }
            .map { "\($0)" }
            .bind(to: turnNumberLabel.rx.text)
            .disposed(by: disposeBag)

        Observable
            .combineLatest(
                viewModel.output.checkers,
                viewModel.output.players
            ) { ($0, $1) }
            .map { [weak self] args -> [(Checker, UIView)] in
                let (checkers, players) = args
                guard let ss = self else { throw CommonError.nilSelf }
                return checkers.map { checker in
                    let view = ss.makeCheckerView(
                        checker: checker,
                        color: Constant.playerColors[players.firstIndex { $0.id == checker.playerId } ?? 0]
                    )
                    return (checker, view)
                }
            }
            .observeOn(MainScheduler.instance)
            .scan([]) { [weak self] old, new -> [UIView] in
                guard let ss = self else { return [] }
                old.forEach { $0.removeFromSuperview() }
                new.forEach {
                    let area = ss.area[$0.0.area]
                    ss.view.addSubview($0.1)
                    $0.1.snp.makeConstraints { maker in
                        maker.size.equalTo(20)
                        maker.center.equalTo(area)
                    }
                }
                return new.map { $0.1 }
            }
            .subscribe()
            .disposed(by: disposeBag)

        shakeButton.rx.tap
            .bind(to: viewModel.input.shake)
            .disposed(by: disposeBag)

        customShakeCount.rx.value
            .map { "\(Int($0))" }
            .bind(to: customShakeLabel.rx.text)
            .disposed(by: disposeBag)

        customShakeButton.rx.tap
            .map { [weak self] in
                guard let ss = self else { throw CommonError.nilSelf }
                return BoardViewModel.TurnState.choiceChecker(move: Int(ss.customShakeLabel.text ?? "") ?? 1)
            }
            .bind(to: viewModel.output.turnState)
            .disposed(by: disposeBag)
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        area = [
            area0, area1, area2, area3, area4,
            area5, area6, area7, area8, area9,
            area10, area11, area12, area13, area14,
            area15, area16, area17, area18, area19,
            area20, area21, area22, area23, area24,
            area25, area26, area27, area28
        ]

        if let viewModel = viewModel {
            bindEvents(viewModel: viewModel)
        }
    }
}

private extension BoardViewModel.TurnState {
    var isShake: Bool {
        switch self {
        case .begin:
            return true
        default:
            return false
        }
    }

    var description: String? {
        switch self {
        case .choiceArea:
            return "Choice the next area"
        case .choiceChecker(let move):
            return "Choice the checker (Move \(move) step)"
        case .begin, .done:
            return nil
        }
    }
}
