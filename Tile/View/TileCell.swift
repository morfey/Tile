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
    @IBOutlet weak var tileStatusBtn: CircleButton!
    @IBOutlet weak var batteryView: UIView!
    @IBOutlet weak var batteryLabel: UILabel!
    var tile: Tile!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    @IBAction func sleepBtnTapped(_ sender: UIButton) {
        guard let tile = tile else { return }
        tileStatusBtn.isSelected = !tileStatusBtn.isSelected
        FirebaseService.shared.update(tile: tile, sleepForceStatus: tileStatusBtn.isSelected)
    }
    
    func configureCell(tile: Tile?) {
//        tileImageView.layer.masksToBounds = false
//        tileImageView.layer.shadowColor = UIColor.lightGray.cgColor
//        tileImageView.layer.shadowOpacity = 0.8
//        tileImageView.layer.shadowOffset = CGSize(width: 0, height: 2.0)
//        tileImageView.layer.shadowRadius = 2
        var hideBtns = true
        if let tile = tile {
            self.tile = tile
            tileStatusBtn.isSelected = tile.sleeping
            tileNameLbl.text = tile.name
            batteryLabel.text = "\(tile.batteryLevel)" + "%"
            if let imgStr = tile.imageUrl, imgStr != "none" {
                tileImageView.kf.setImage(with: URL(string: imgStr))
                tileImageView.contentMode = .scaleAspectFill
                tileImageView.clipsToBounds = true
                hideBtns = false
            } else {
                tileImageView.image = #imageLiteral(resourceName: "empty_image")
                tileImageView.contentMode = .center
                hideBtns = false
            }
        } else {
            tileNameLbl.text = ""
            tileImageView.image = #imageLiteral(resourceName: "add_tile")
            tileImageView.contentMode = .center
            hideBtns = true
        }
        tileStatusBtn.isHidden = hideBtns
        batteryView.isHidden = hideBtns
        batteryLabel.isHidden = hideBtns
    }
}

