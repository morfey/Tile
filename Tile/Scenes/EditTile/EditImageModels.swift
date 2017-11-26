//
//  EditTileModels.swift
//  Tile
//
//  Created by  Tim on 16.10.2017.
//  Copyright (c) 2017 TimHazhyi. All rights reserved.

import UIKit

enum EditTile
{
    // MARK: Use cases
    enum Filters {
        struct Request
        {
            var filters: [String]
            var originalImage: UIImage
        }
        struct Response
        {
            var images: [CGImage]
        }
        struct ViewModel
        {
            var filtersScrollView: UIScrollView
        }
    }
    enum ImageForTile {
        struct Request
        {
            var image: UIImage
        }
        struct Response
        {
            var url: String
        }
        struct ViewModel
        {
            
        }
    }
}
