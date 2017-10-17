//
//  EditImagePresenter.swift
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

protocol EditImagePresentationLogic
{
    func presentFiltersScrollView(response: EditImage.Filters.Response)
    func setImage(image: UIImage)
}

class EditImagePresenter: EditImagePresentationLogic
{
    weak var viewController: EditImageDisplayLogic?
    
    // MARK: Do something
    
    func presentFiltersScrollView(response: EditImage.Filters.Response) {
        let viewModel = EditImage.Filters.ViewModel(images: response.images)
        viewController?.displayFiltersScrollView(viewModel: viewModel)
    }
    
    func setImage(image: UIImage) {
        viewController?.setImage(image: image)
    }
}