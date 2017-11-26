//
//  EditTileInteractor.swift
//  Tile
//
//  Created by  Tim on 16.10.2017.
//  Copyright (c) 2017 TimHazhyi. All rights reserved.

import UIKit

protocol EditTileBusinessLogic
{
    func applyFilters(request: EditTile.Filters.Request)
    func saveImageForTile(request: EditTile.ImageForTile.Request)
    
    func setImage()
    func setImageWithFilter(image: UIImage)
}

protocol EditTileDataStore
{
    var tile: Tile? {get set}
    var imageWithFilter: UIImage? {get set}
}

class EditTileInteractor: EditTileBusinessLogic, EditTileDataStore
{
    var tile: Tile?
    var imageWithFilter: UIImage?
    var presenter: EditTilePresentationLogic?
    var worker: EditTileWorker?
    
    // MARK: Do something
    
    func applyFilters(request: EditTile.Filters.Request) {
        worker = EditTileWorker()
        DispatchQueue.global().async {
            let images = self.worker?.applyGPUImageFilters(originalImage: request.originalImage)
//            let images = self.worker?.applyFilters(originalImage: request.originalImage, filtrerNames: request.filters)
            DispatchQueue.main.async {
                let response = EditTile.Filters.Response(images: images!)
                self.presenter?.presentFiltersScrollView(response: response)
            }
        }
    }
    
    func saveImageForTile(request: EditTile.ImageForTile.Request) {
        if let dbKey = tile?.dbKey {
            FirebaseService.shared.upload(image: request.image, forTile: dbKey) { url in
                let response = EditTile.ImageForTile.Response(url: url)
                self.presenter?.presentTileWithImage(responce: response)
            }
        }
    }
    
    func setImage() {
//        presenter?.setImage(image: originalImage!)
    }
    
    func setImageWithFilter(image: UIImage) {
        self.imageWithFilter = image
    }
}
