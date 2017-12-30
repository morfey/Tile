//
//  Protocols.swift
//  Photo Editor
//
//  Created by Mohamed Hamed on 6/15/17.
//
//

import Foundation
import UIKit
/**
 - didSelectView
 - didSelectImage
 - stickersViewDidDisappear
 */

public protocol PhotoEditorDelegate {
    /**
     - Parameter image: edited Image
     */
    func doneEditing(image: UIImage)
    /**
     StickersViewController did Disappear
     */
    func canceledEditing()
}


/**
 - didSelectView
 - didSelectImage
 - stickersViewDidDisappear
 */
protocol StickersViewControllerDelegate {
    /**
     - Parameter view: selected view from StickersViewController
     */
    func didSelectView(view: UIView)
    /**
     - Parameter image: selected Image from StickersViewController
     */
    func didSelectImage(image: UIImage)
    /**
     StickersViewController did Disappear
     */
    func stickersViewDidDisappear()
}

protocol BrightnessViewControllerDelegate {
    var colorControlsSliders : CIFilter!  { get }
    func didChangeFilter(value: Float, forKey: String)
    func brightnessViewDidDisappear()
}

@objc protocol FiltersViewControllerDelegate {
    /**
     - Parameter button: selected view from FiltersViewController
     */
    @objc func didSelectFilter(_ sender: UIButton)
    /**
     FiltersViewController did Disappear
     */
    func filtersViewDidDisappear()
}

/**
 - didSelectColor
 */
protocol ColorDelegate {
    func didSelectColor(color: UIColor)
}

public protocol GPUimagePlusDelegate {
    func proccessFilters(image: UIImage) -> ([CGImage])
    func applyFilter(index: Int, toImage image: UIImage) -> UIImage
}
