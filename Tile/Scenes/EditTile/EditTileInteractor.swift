//
//  EditTileInteractor.swift
//  Tile
//
//  Created by  Tim on 16.10.2017.
//  Copyright (c) 2017 TimHazhyi. All rights reserved.

import UIKit

protocol EditTileBusinessLogic
{
    func saveImageForTile(request: EditTile.ImageForTile.Request)
}

protocol EditTileDataStore
{
    var tile: Tile? {get set}
}

class EditTileInteractor: EditTileBusinessLogic, EditTileDataStore
{
    var tile: Tile?
    var presenter: EditTilePresentationLogic?
    var worker: EditTileWorker?
    
    // MARK: Do something
    
    func saveImageForTile(request: EditTile.ImageForTile.Request) {
        if let tile = tile {
            FirebaseService.shared.upload(image: request.image, forTile: tile) { [weak self] url in
                let response = EditTile.ImageForTile.Response(url: url)
                self?.presenter?.presentTileWithImage(responce: response)
            }
        }
    }
}
