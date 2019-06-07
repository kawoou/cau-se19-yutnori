//
//  MainViewController.swift
//  Yutnori
//
//  Created by Kawoou on 30/05/2019.
//  Copyright © 2019 kawoou. All rights reserved.
//

import UIKit
import RxSwift

final class MainViewController: UIViewController {

    // MARK: - Property

    var viewModel: MainViewModel?

    // MARK: - Interface

    @IBOutlet weak var numberOfPlayerSlider: UISlider!
    @IBOutlet weak var numberOfPlayerLabel: UILabel!
    @IBOutlet weak var numberOfCheckerSlider: UISlider!
    @IBOutlet weak var numberOfCheckerLabel: UILabel!
    @IBOutlet weak var startButton: UIButton!

    // MARK: - Private

    private var disposeBag = DisposeBag()

    private func bindEvents(viewModel: MainViewModel) {
        disposeBag = DisposeBag()

        /// State
        viewModel.output.playerCount
            .map { "\($0)" }
            .bind(to: numberOfPlayerLabel.rx.text)
            .disposed(by: disposeBag)

        viewModel.output.checkerCount
            .map { "\($0)" }
            .bind(to: numberOfCheckerLabel.rx.text)
            .disposed(by: disposeBag)

        viewModel.output.game
            .subscribe(onNext: { [weak self] game in
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let viewController = storyboard.instantiateViewController(withIdentifier: "BoardViewController") as! BoardViewController
                viewController.viewModel = BoardViewModel(service: viewModel.service, gameId: game.id)
                self?.present(viewController, animated: true)
            })
            .disposed(by: disposeBag)

        /// Action
        numberOfPlayerSlider.rx.value
            .map { Int($0) }
            .distinctUntilChanged()
            .bind(to: viewModel.input.setPlayerCount)
            .disposed(by: disposeBag)

        numberOfCheckerSlider.rx.value
            .map { Int($0) }
            .distinctUntilChanged()
            .bind(to: viewModel.input.setCheckerCount)
            .disposed(by: disposeBag)

        startButton.rx.tap
            .bind(to: viewModel.input.createGame)
            .disposed(by: disposeBag)
    }

    // MARK: - Public

    override func viewDidLoad() {
        super.viewDidLoad()

        if let viewModel = viewModel {
            bindEvents(viewModel: viewModel)
        }
    }
}
