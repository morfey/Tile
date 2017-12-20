//
//  PhotoEditor+FiltersViewController.swift
//  Tile
//
//  Created by  Tim on 28.11.2017.
//  Copyright © 2017 TimHazhyi. All rights reserved.
//

import Foundation
import UIKit

extension PhotoEditorViewController {
    
    func addSFiltersViewController() {
        filtersVCIsVisible = true
        hideToolbar(hide: true)
        self.canvasImageView.isUserInteractionEnabled = false
        filtersViewControler.filtersViewControllerDelegate = self
        filtersViewControler.gpuImagePlusDelegate = gpuImagePlusDelegate
        filtersViewControler.originalImage = imageView.image

        self.addChildViewController(filtersViewControler)
        self.view.addSubview(filtersViewControler.view)
        filtersViewControler.didMove(toParentViewController: self)
        let height = view.frame.height
        let width  = view.frame.width
        filtersViewControler.view.frame = CGRect(x: 0, y: self.view.frame.maxY , width: width, height: height)
    }
    
    func removeFiltersView() {
        stickersVCIsVisible = false
        self.canvasImageView.isUserInteractionEnabled = true
        UIView.animate(withDuration: 0.3,
                       delay: 0,
                       options: UIViewAnimationOptions.curveEaseIn,
                       animations: { () -> Void in
                        var frame = self.filtersViewControler.view.frame
                        frame.origin.y = UIScreen.main.bounds.maxY
                        self.filtersViewControler.view.frame = frame
                        
        }, completion: { (finished) -> Void in
            self.filtersViewControler.view.removeFromSuperview()
            self.filtersViewControler.removeFromParentViewController()
            self.hideToolbar(hide: false)
        })
    }
}

extension PhotoEditorViewController: FiltersViewControllerDelegate {
    
    @objc func didSelectFilter(_ sender: UIButton) {
        self.imageView.image = sender.backgroundImage(for: .normal)
//        self.removeFiltersView()
    }
    
    func filtersViewDidDisappear() {
        stickersVCIsVisible = false
        hideToolbar(hide: false)
    }
}
