//
//  ConnectToTilePresenter.swift
//  Tile
//
//  Created by  Tim on 29.11.2017.
//  Copyright (c) 2017 TimHazhyi. All rights reserved.

import UIKit

protocol ConnectToTilePresentationLogic
{
    func presentNewTile(response: ConnectToTile.NewTile.Response)
    func present(alert: UIAlertController)
}

class ConnectToTilePresenter: ConnectToTilePresentationLogic
{
    weak var viewController: ConnectToTileDisplayLogic?
    
    func presentNewTile(response: ConnectToTile.NewTile.Response) {
        let viewModel = ConnectToTile.NewTile.ViewModel(tile: response.tile)
        viewController?.displayNewTile(viewModel: viewModel)
    }
    
    func present(alert: UIAlertController) {
        viewController?.display(alert: alert)
    }
}
