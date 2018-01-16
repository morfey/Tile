//
//  TilesPresenter.swift
//  Tile
//
//  Created by  Tim on 16.10.2017.
//  Copyright (c) 2017 TimHazhyi. All rights reserved.

import UIKit

protocol TilesPresentationLogic
{
    func presentWifiAlert(response: Tiles.ConnectionStatus.Response)
    func presentNewTile(response: Tiles.NewTile.Response)
    func presentUsersTiles(responce: Tiles.GetTiles.Response)
    func present(alert: UIAlertController)
    func presentEditedTile(response: Tiles.EditedImage.Response)
}

class TilesPresenter: TilesPresentationLogic
{
    weak var viewController: TilesDisplayLogic?
    
    func presentUsersTiles(responce: Tiles.GetTiles.Response) {
        let viewModel = Tiles.GetTiles.ViewModel(tiles: responce.tiles)
        viewController?.displayUsersTiles(viewModel: viewModel)
    }
    
    func presentWifiAlert(response: Tiles.ConnectionStatus.Response) {
        let alert = UIAlertController(title: "Error", message: "Check your Wi-Fi connect", preferredStyle: .alert)
        let actionOk = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alert.addAction(actionOk)
        let actionSettings = UIAlertAction(title: "Settings", style: .default) { _ in
            let url = URL(string: "App-Prefs:root=WIFI")
            UIApplication.shared.open(url!, options: [:], completionHandler: nil)
        }
        alert.addAction(actionSettings)
        let viewModel = Tiles.ConnectionStatus.ViewModel(alert: alert)
        viewController?.displayWifiConnectionAlert(viewModel: viewModel)
    }
    
    func presentNewTile(response: Tiles.NewTile.Response) {
        let viewModel = Tiles.NewTile.ViewModel(tile: response.tile)
        viewController?.displayNewTile(viewModel: viewModel)
    }
    
    func present(alert: UIAlertController) {
        viewController?.display(alert: alert)
    }
    
    func presentEditedTile(response: Tiles.EditedImage.Response) {
        let viewModel = Tiles.EditedImage.ViewModel(tile: response.tile, image: response.image)
        viewController?.displayEditedTile(viewModel: viewModel)
    }
}
