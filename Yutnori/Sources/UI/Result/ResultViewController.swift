//
//  ResultViewController.swift
//  Yutnori
//
//  Created by Kawoou on 31/05/2019.
//  Copyright © 2019 kawoou. All rights reserved.
//

import UIKit
import RxSwift

final class ResultViewController: UIViewController {

    // MARK: - Property

    var viewModel: ResultViewModel?

    // MARK: - Interface

    @IBOutlet weak var winnerLabel: UILabel!
    @IBOutlet weak var doneButton: UIButton!

    // MARK: - Private

    private var disposeBag = DisposeBag()

    private func bindEvents(viewModel: ResultViewModel) {
        disposeBag = DisposeBag()

        /// State
        viewModel.output.victory
            .map { "Winner: Player \($0.id)" }
            .bind(to: winnerLabel.rx.text)
            .disposed(by: disposeBag)

        viewModel.output.isDone
            .filter { $0 }
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                self?.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
            })
            .disposed(by: disposeBag)

        /// Action
        doneButton.rx.tap
            .bind(to: viewModel.input.dismiss)
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
