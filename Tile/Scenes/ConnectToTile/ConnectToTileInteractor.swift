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
        FirebaseService.shared.add(tile: tile, userId: request.userId) { [weak self] status, tile in
            if status == "New Tile succesfull added" {
                self?.tile = tile
                FirebaseService.shared.addObserveForTile(tile: tile!) {
                    let response = ConnectToTile.NewTile.Response(status: status, tile: tile!)
                    self?.presenter?.presentNewTile(response: response)
                }
            } else {
                let alert = UIAlertController(title: "", message: "Error", preferredStyle: .alert)
                alert.addTextField(configurationHandler: nil)
                let action = UIAlertAction(title: "OK", style: .default)
                alert.addAction(action)
                self?.presenter?.present(alert: alert)
            }
        }
    }
}
