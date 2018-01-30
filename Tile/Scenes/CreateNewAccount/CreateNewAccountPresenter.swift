//
//  CreateNewAccountPresenter.swift
//  Tile
//
//  Created by  Tim on 16.11.2017.
//  Copyright (c) 2017 TimHazhyi. All rights reserved.


import UIKit

protocol CreateNewAccountPresentationLogic
{
    func presentError(_ error: Error)
}

class CreateNewAccountPresenter: CreateNewAccountPresentationLogic
{
    weak var viewController: CreateNewAccountDisplayLogic?
    
    func presentError(_ error: Error) {
        let alert = UIAlertController(title: "Error in new account", message: error.localizedDescription, preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alert.view.tintColor = #colorLiteral(red: 0.8930782676, green: 0.7270605564, blue: 0.417747438, alpha: 1)
        alert.addAction(action)
        let viewModel = CreateNewAccount.Error.ViewModel(alert: alert)
        viewController?.displayError(viewModel: viewModel)
    }
}
