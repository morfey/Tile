//
//  ImageCell.swift
//  Tile
//
//  Created by  Tim on 24.10.2017.
//  Copyright © 2017 TimHazhyi. All rights reserved.
//

import UIKit

class ImageCell: UICollectionViewCell {
    @IBOutlet weak var preview: UIView!
    @IBOutlet weak var imageView: UIImageView!
    
    func configureCell(image: UIImage?, first: Bool) {
        if first {
            imageView.image = #imageLiteral(resourceName: "camera")
            imageView.backgroundColor = .groupTableViewBackground
        } else {
            imageView.image = image!
            imageView.contentMode = .scaleAspectFill
            imageView.clipsToBounds = true
        }
    }
}
