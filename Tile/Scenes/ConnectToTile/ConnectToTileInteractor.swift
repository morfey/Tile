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
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(4), execute: {
            FirebaseService.shared.waiter(id: request.id, userId: request.userId) { [weak self] status, tile in
                switch status {
                case .success, .recconnect:
                    self?.tile = tile
                    let response = ConnectToTile.NewTile.Response(tile: tile!)
                    self?.presenter?.presentNewTile(response: response)
                case .notYourTile:
                    let alert = UIAlertController(title: "Error", message: "Not your tile", preferredStyle: .alert)
                    alert.view.tintColor = #colorLiteral(red: 0.8919044137, green: 0.7269840837, blue: 0.4177360535, alpha: 1)
                    alert.addTextField(configurationHandler: nil)
                    let action = UIAlertAction(title: "OK", style: .default)
                    alert.addAction(action)
                    self?.presenter?.present(alert: alert)
                }
            }
        })
    }
    
    func checkWifiConnection() -> Bool {
        return Reachability.isConnectedToNetwork()
    }
}
