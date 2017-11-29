//
//  ConnectToTilePresenter.swift
//  Tile
//
//  Created by  Tim on 29.11.2017.
//  Copyright (c) 2017 TimHazhyi. All rights reserved.

import UIKit

protocol ConnectToTilePresentationLogic
{
    func presentSomething(response: ConnectToTile.Something.Response)
}

class ConnectToTilePresenter: ConnectToTilePresentationLogic
{
    weak var viewController: ConnectToTileDisplayLogic?
    
    // MARK: Do something
    
    func presentSomething(response: ConnectToTile.Something.Response)
    {
        let viewModel = ConnectToTile.Something.ViewModel()
        viewController?.displaySomething(viewModel: viewModel)
    }
}
