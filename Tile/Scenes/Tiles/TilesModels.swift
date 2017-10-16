//
//  TilesModels.swift
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

enum Tiles
{
    // MARK: Use cases
    
    enum Something
    {
        struct Request
        {
        }
        struct Response
        {
        }
        struct ViewModel
        {
        }
    }
    enum SelectedImage
    {
        struct Request
        {
        }
        struct Response
        {
            var image: UIImage
        }
        struct ViewModel
        {
            var image: UIImage
        }
    }
}
