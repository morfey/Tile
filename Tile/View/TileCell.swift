//
//  TileCell.swift
//  Tile
//
//  Created by  Tim on 24.10.2017.
//  Copyright © 2017 TimHazhyi. All rights reserved.
//

import UIKit
import Kingfisher

class TileCell: UICollectionViewCell {
    @IBOutlet weak var tileNameLbl: UILabel!
    @IBOutlet weak var tileImageView: UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.borderWidth = 1
        layer.borderColor = UIColor.black.cgColor
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        layer.borderWidth = 1
        layer.borderColor = UIColor.black.cgColor
    }
    
    func configureCell(name: String, image: URL?) {
        tileNameLbl.text = name
        if image != nil {
            tileImageView.kf.setImage(with: image!)
            tileImageView.contentMode = .scaleAspectFit
        } else {
            tileImageView.image = #imageLiteral(resourceName: "plus")
            tileImageView.contentMode = .center
        }
        
    }
}
