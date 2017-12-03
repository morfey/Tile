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
        if tileStatusBtn.isSelected {
            tileImageView.addBlurEffect()
        } else {
            tileImageView.removeBlurEffect()
        }
    }
    
    func configureCell(tile: Tile?) {
        var hideBtns = true
        if let tile = tile {
            self.tile = tile
            tileStatusBtn.isSelected = tile.sleeping
            tileNameLbl.text = tile.name
            batteryLabel.text = "\(tile.batteryLevel)" + "%"
            if tile.sleeping {
                tileImageView.addBlurEffect()
            } else {
                tileImageView.removeBlurEffect()
            }
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
            tileStatusBtn.isSelected = false
            tileImageView.removeBlurEffect()
            hideBtns = true
        }
        tileStatusBtn.isHidden = hideBtns
        batteryView.isHidden = hideBtns
        batteryLabel.isHidden = hideBtns
    }
}

fileprivate extension UIImageView
{
    func addBlurEffect() {
        let effects = self.subviews.map {$0 as? UIVisualEffectView}
        if effects.count == 0 {
            let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.dark)
            let blurEffectView = UIVisualEffectView(effect: blurEffect)
            blurEffectView.frame = self.bounds
            
            blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            blurEffectView.alpha = 0.7
            self.addSubview(blurEffectView)
        }
    }
    
    func removeBlurEffect() {
        self.subviews.forEach {
            if let effect = $0 as? UIVisualEffectView {
                effect.removeFromSuperview()
            }
        }
    }
}
