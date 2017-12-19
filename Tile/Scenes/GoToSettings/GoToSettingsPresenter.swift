//
//  GoToSettingsPresenter.swift
//  Tile
//
//  Created by  Tim on 19.12.2017.
//  Copyright (c) 2017 TimHazhyi. All rights reserved.


import UIKit

protocol GoToSettingsPresentationLogic
{
    func presentSomething(response: GoToSettings.Something.Response)
}

class GoToSettingsPresenter: GoToSettingsPresentationLogic
{
    weak var viewController: GoToSettingsDisplayLogic?
    
    // MARK: Do something
    
    func presentSomething(response: GoToSettings.Something.Response)
    {
        let viewModel = GoToSettings.Something.ViewModel()
        viewController?.displaySomething(viewModel: viewModel)
    }
}
