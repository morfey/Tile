//
//  CircleButton.swift
//  Scribe
//
//  Created by  Tim on 31.01.17.
//  Copyright © 2017  Tim. All rights reserved.
//

import UIKit

@IBDesignable

class CircleButton: UIButton {

    @IBInspectable var cornerRadius: CGFloat = 30.0 {
        didSet {
            layer.cornerRadius = cornerRadius
        }
    }
    
    @IBInspectable var shadowRadius: CGFloat = 0.0 {
        didSet {
            layer.cornerRadius = cornerRadius
            layer.shadowColor = UIColor.black.cgColor
            layer.shadowOffset = CGSize(width: 1.0, height: 2.0)
            layer.masksToBounds = false
            layer.shadowRadius = shadowRadius
            layer.shadowOpacity = 0.2
        }
    }
    
    override func prepareForInterfaceBuilder() {
        setupView()
    }
    
    func setupView () {
        layer.cornerRadius = cornerRadius
        layer.shadowRadius = shadowRadius
    }
}
