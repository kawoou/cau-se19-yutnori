//
//  ViewModel.swift
//  Yutnori
//
//  Created by Kawoou on 27/05/2019.
//  Copyright © 2019 kawoou. All rights reserved.
//

protocol ViewModel {
    associatedtype Input
    associatedtype Output

    var input: Input { get }
    var output: Output { get }
}
