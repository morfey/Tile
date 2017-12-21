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
//        filtersVCIsVisible = true
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
//        stickersVCIsVisible = false
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
        colorControlsFilter.setValue(value, forKey: key)
        if let outputImage = self.colorControlsFilter.outputImage {
            if let cgImageNew = self.ciImageContext.createCGImage(outputImage, from: outputImage.extent) {
                let newImg = UIImage(cgImage: cgImageNew)
                imageView.image = newImg
            }
        }
    }
    
    func brightnessViewDidDisappear() {
        stickersVCIsVisible = false
        hideToolbar(hide: false)
    }
}
