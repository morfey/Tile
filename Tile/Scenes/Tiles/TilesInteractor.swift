//
//  TilesInteractor.swift
//  Tile
//
//  Created by  Tim on 16.10.2017.
//  Copyright (c) 2017 TimHazhyi. All rights reserved.
//
//  This file was generated by the Clean Swift Xcode Templates so
//  you can apply clean architecture to your iOS and Mac projects,
//  see http://clean-swift.com
//

import UIKit

protocol TilesBusinessLogic
{
    func setImage(image: UIImage?)
    var selectedImage: UIImage? {get set}
}

protocol TilesDataStore
{
    var selectedImage: UIImage? {get set}
}

class TilesInteractor: TilesBusinessLogic, TilesDataStore
{
    var selectedImage: UIImage?
    var presenter: TilesPresentationLogic?
    var worker: TilesWorker?
    
    // MARK: Do something
    
    func setImage(image: UIImage? = nil) {
        if image != nil {
            selectedImage = image   
        }
        if selectedImage == nil {return}
        let response = Tiles.SelectedImage.Response(image: selectedImage!)
        presenter?.presentSelectedImage(response: response)
    }
}
