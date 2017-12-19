//
//  ConnectToTileInteractor.swift
//  Tile
//
//  Created by  Tim on 29.11.2017.
//  Copyright (c) 2017 TimHazhyi. All rights reserved.


import UIKit

protocol ConnectToTileBusinessLogic
{
    func addNewTile(request: ConnectToTile.NewTile.Request)
}

protocol ConnectToTileDataStore
{
    var tile: Tile? { get set }
    //var name: String { get set }
}



class ConnectToTileInteractor: ConnectToTileBusinessLogic, ConnectToTileDataStore
{
    var presenter: ConnectToTilePresentationLogic?
    var worker: ConnectToTileWorker?
    var router: ConnectToTileRoutingLogic?
    var tile: Tile?
    
    // MARK: Do something
    
    func addNewTile(request: ConnectToTile.NewTile.Request) {
        let tile = Tile(id: request.id, userId: request.userId)
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(4), execute: {
//            if self.checkWifiConnection() {
                FirebaseService.shared.add(tile: tile, userId: request.userId) { [weak self] status, tile in
                    switch status {
                    case .success, .recconnect:
                        self?.tile = tile
                        FirebaseService.shared.addObserveForTile(tile: tile!) {
                            let response = ConnectToTile.NewTile.Response(tile: tile!)
                            self?.presenter?.presentNewTile(response: response)
                        }
                    case .notYourTile:
                        let alert = UIAlertController(title: "Error", message: "Not your tile", preferredStyle: .alert)
                        alert.view.tintColor = #colorLiteral(red: 0.8919044137, green: 0.7269840837, blue: 0.4177360535, alpha: 1)
                        alert.addTextField(configurationHandler: nil)
                        let action = UIAlertAction(title: "OK", style: .default)
                        alert.addAction(action)
                        self?.presenter?.present(alert: alert)
                    }
                }
//            } else {
//                let response = ConnectToTile.ConnectionStatus.Response(status: false)
//                self.presenter?.presentWifiAlert(response: response)
//            }
        })
    }
    
    func checkWifiConnection() -> Bool {
        return Reachability.isConnectedToNetwork()
    }
}
