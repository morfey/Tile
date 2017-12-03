//
//  LoginPresenter.swift
//  Tile
//
//  Created by  Tim on 12.10.2017.
//  Copyright (c) 2017 TimHazhyi. All rights reserved.


import UIKit

protocol LoginPresentationLogic
{
    func presentError(_ error: Error)
}

class LoginPresenter: LoginPresentationLogic
{
    weak var viewController: LoginDisplayLogic?
    
    // MARK: Do something
    
    func presentError(_ error: Error) {
        let alert = UIAlertController(title: "Error in login", message: error.localizedDescription, preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alert.addAction(action)
        let viewModel = Login.Error.ViewModel(alert: alert)
        viewController?.displayError(viewModel: viewModel)
    }
}
