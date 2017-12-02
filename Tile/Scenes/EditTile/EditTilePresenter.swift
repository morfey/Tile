//
//  EditTilePresenter.swift
//  Tile
//
//  Created by  Tim on 16.10.2017.
//  Copyright (c) 2017 TimHazhyi. All rights reserved.

import UIKit

protocol EditTilePresentationLogic
{
    func presentFiltersScrollView(response: EditTile.Filters.Response)
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
    
    func presentFiltersScrollView(response: EditTile.Filters.Response) {
        let scrollView = UIScrollView()
        var xCoord: CGFloat = 5
        let yCoord: CGFloat = 5
        let buttonWidth:CGFloat = 70
        let buttonHeight: CGFloat = 70
        let gapBetweenButtons: CGFloat = 5
        var itemCount = 0
        
        for (index, i) in response.images.enumerated() {
            //save(image: UIImage(cgImage: i), i: index)
            itemCount = index
            let filterButton = UIButton(type: .custom)
            filterButton.frame = CGRect(x: xCoord, y: yCoord, width: buttonWidth, height: buttonHeight)
            filterButton.tag = itemCount
            filterButton.addTarget(self, action: #selector(filterButtonTapped(sender:)), for: .touchUpInside)
            filterButton.layer.cornerRadius = 6
            filterButton.clipsToBounds = true
            filterButton.imageView?.contentMode = .center
            let imageForButton = UIImage(cgImage: i)
            filterButton.setBackgroundImage(imageForButton, for: .normal)
            filterButton.contentMode = .scaleAspectFit
            xCoord +=  buttonWidth + gapBetweenButtons
            scrollView.addSubview(filterButton)
        }
        
        scrollView.contentSize = CGSize(width: buttonWidth * CGFloat(itemCount + 2), height: yCoord)
        
        let viewModel = scrollView
        viewController?.displayFiltersScrollView(viewModel: viewModel)
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
    
    @objc func filterButtonTapped(sender: UIButton) {
        viewController?.filterButtonTapped(sender: sender)
    }
    
    func setImage(image: UIImage) {
        viewController?.setImage(image: image)
    }
}
