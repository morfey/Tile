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
}
