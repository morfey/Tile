//
//  TilesInteractor.swift
//  Tile
//
//  Created by  Tim on 16.10.2017.
//  Copyright (c) 2017 TimHazhyi. All rights reserved.

import UIKit
import Unbox

protocol TilesBusinessLogic
{
    func checkWifiConnection()
    func getTiles(request: Tiles.GetTiles.Request)
    func addNewTile(request: Tiles.NewTile.Request)
    
    var selectedImage: UIImage? {get set}
    var selectedTile: Tile? {get set}
}

protocol TilesDataStore
{
    var selectedImage: UIImage? {get set}
    var selectedTile: Tile? {get set}
    var newTile: Tile? {get set}
}

class TilesInteractor: TilesBusinessLogic, TilesDataStore
{
    var selectedImage: UIImage?
    var selectedTile: Tile?
    var newTile: Tile? {
        didSet {
            let response = Tiles.NewTile.Response(tile: newTile!)
            presenter?.presentNewTile(response: response)
        }
    }
    var presenter: TilesPresentationLogic?
    var worker: TilesWorker?
    
    // MARK: Do something
    
    func checkWifiConnection() {
        let connection = Reachability.isConnectedToNetwork()
        if connection {
            return
        } else {
            let response = Tiles.ConnectionStatus.Response(status: connection)
            presenter?.presentWifiAlert(response: response)
        }    
    }
    
    func getTiles(request: Tiles.GetTiles.Request) {
        var tiles: [Tile] = []
        FirebaseService.shared.getUsersTiles(byId: request.userId) { [weak self] tilesData in
            for data in tilesData {
                guard let data = data.value as? Dictionary<String, Any> else {return}
                do {
                    let tile: Tile = try unbox(dictionary: data)
                    tiles.append(tile)
                } catch {
                }
            }
            let responce = Tiles.GetTiles.Response(tiles: tiles)
            self?.presenter?.presentUsersTiles(responce: responce)
        }
    }
    
    func addNewTile(request: Tiles.NewTile.Request) {
        let tile = Tile(id: request.id, userId: request.userId)
        FirebaseService.shared.add(tile: tile, userId: request.userId) { [weak self] status, tile in
            switch status {
            case .success, .recconnect:
                FirebaseService.shared.addObserveForTile(tile: tile!) {
                    let response = Tiles.NewTile.Response(tile: tile!)
                    self?.presenter?.presentNewTile(response: response)
                }
            case .notYourTile:
                let alert = UIAlertController(title: "Error", message: "Not your tile", preferredStyle: .alert)
                alert.addTextField(configurationHandler: nil)
                let action = UIAlertAction(title: "OK", style: .default)
                alert.addAction(action)
                self?.presenter?.present(alert: alert)
            }
        }
    }
}
