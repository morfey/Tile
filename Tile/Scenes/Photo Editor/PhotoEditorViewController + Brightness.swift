//
//  PhotoEditorViewController + Brightness.swift
//  Tile
//
//  Created by  Tim on 21.12.2017.
//  Copyright © 2017 TimHazhyi. All rights reserved.
//

import Foundation
import UIKit
import CoreImage

extension PhotoEditorViewController {
    
    func addBrightnessViewController() {
        brigtnessVCIsVisible = true
        hideToolbar(hide: true)
        self.canvasImageView.isUserInteractionEnabled = false
        brightnessViewController.delegate = self
        
        self.addChildViewController(brightnessViewController)
        self.view.addSubview(brightnessViewController.view)
        brightnessViewController.didMove(toParentViewController: self)
        let height = view.frame.height
        let width  = view.frame.width
        brightnessViewController.view.frame = CGRect(x: 0, y: self.view.frame.maxY , width: width, height: height)
    }
    
    func removeBrightnessView() {
        brigtnessVCIsVisible = false
        self.canvasImageView.isUserInteractionEnabled = true
        UIView.animate(withDuration: 0.3,
                       delay: 0,
                       options: UIViewAnimationOptions.curveEaseIn,
                       animations: { () -> Void in
                        var frame = self.brightnessViewController.view.frame
                        frame.origin.y = UIScreen.main.bounds.maxY
                        self.brightnessViewController.view.frame = frame
                        
        }, completion: { (finished) -> Void in
            self.brightnessViewController.view.removeFromSuperview()
            self.brightnessViewController.removeFromParentViewController()
            self.hideToolbar(hide: false)
        })
    }
}

extension PhotoEditorViewController: BrightnessViewControllerDelegate {
    func didChangeFilter(value: Float, forKey key: String) {
        colorControlsSliders.setValue(value, forKey: key)
        showResult()
    }
    
    func brightnessViewDidDisappear() {
        brigtnessVCIsVisible = false
        hideToolbar(hide: false)
    }
}
