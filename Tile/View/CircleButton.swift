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
    
    override func prepareForInterfaceBuilder() {
        setupView()
    }
    
    func setupView () {
        layer.cornerRadius = cornerRadius
    }
}
