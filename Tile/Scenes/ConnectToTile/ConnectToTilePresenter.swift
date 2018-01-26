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
    func presentWifiAlert(response: ConnectToTile.ConnectionStatus.Response)
    func present(alert: UIAlertController)
    func timeOutError()
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
    
    func presentWifiAlert(response: ConnectToTile.ConnectionStatus.Response) {
        let alert = UIAlertController(title: "Error", message: "Check your Wi-Fi connect", preferredStyle: .alert)
        alert.view.tintColor = #colorLiteral(red: 0.8919044137, green: 0.7269840837, blue: 0.4177360535, alpha: 1)
        let actionOk = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alert.addAction(actionOk)
        let actionSettings = UIAlertAction(title: "Settings", style: .default) { _ in
            let url = URL(string: "App-Prefs:root=WIFI")
            UIApplication.shared.open(url!, options: [:], completionHandler: nil)
        }
        alert.addAction(actionSettings)
        let viewModel = ConnectToTile.ConnectionStatus.ViewModel(alert: alert)
        viewController?.displayWifiConnectionAlert(viewModel: viewModel)
    }
    
    func timeOutError() {
        viewController?.timeOutError()
    }
}
