//
//  EditTilePresenter.swift
//  Tile
//
//  Created by  Tim on 16.10.2017.
//  Copyright (c) 2017 TimHazhyi. All rights reserved.

import UIKit

protocol EditTilePresentationLogic
{
    func presentTileWithImage(responce: EditTile.ImageForTile.Response)
    func setImage(image: UIImage)
}

class EditTilePresenter: EditTilePresentationLogic
{
    weak var viewController: EditTileDisplayLogic?
    
    // MARK: Do something
    
    func presentTileWithImage(responce: EditTile.ImageForTile.Response) {
        let viewModel = EditTile.ImageForTile.ViewModel()
        viewController?.displayTileWithImage(viewModel: viewModel)
    }
    
    func save (image: UIImage, i: Int) {
        let date :NSDate = NSDate()
        let imageName = "/\(i).jpg"
        print(imageName)

        var documentsDirectoryPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        documentsDirectoryPath += imageName
        print(documentsDirectoryPath)
        
        let settingsData: NSData = UIImageJPEGRepresentation(image, 1.0) as! NSData
        settingsData.write(toFile: documentsDirectoryPath, atomically: true)
    }
    
    func setImage(image: UIImage) {
        viewController?.setImage(image: image)
    }
}
