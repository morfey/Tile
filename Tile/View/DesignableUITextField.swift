//
//  DesignableUITextField.swift
//  Tile
//
//  Created by  Tim on 12.12.2017.
//  Copyright © 2017 TimHazhyi. All rights reserved.
//

import Foundation

import UIKit

@IBDesignable
class DesignableUITextField: UITextField {
    
    // Provides left padding for images
    override func leftViewRect(forBounds bounds: CGRect) -> CGRect {
        var textRect = super.leftViewRect(forBounds: bounds)
        textRect.origin.x += leftPadding
        return textRect
    }
    
    @IBInspectable var leftImage: UIImage? {
        didSet {
            updateView()
            setBottomBorder()
        }
    }
    
    @IBInspectable var leftPadding: CGFloat = 0
    
    @IBInspectable var color: UIColor = UIColor.lightGray {
        didSet {
            updateView()
            setBottomBorder()
        }
    }
    
    func setBottomBorder() {
        borderStyle = .none
        layer.backgroundColor = UIColor.white.cgColor
        
        layer.masksToBounds = false
        layer.shadowColor = UIColor.lightGray.cgColor
        layer.shadowOffset = CGSize(width: 0.0, height: 0.5)
        layer.shadowOpacity = 0.5
        layer.shadowRadius = 0.0
    }
    
    func updateView() {
        if let image = leftImage {
            let view = UIView(frame: CGRect(x: 0, y: 0, width: 50, height: 20))
            leftViewMode = UITextFieldViewMode.always
            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
            imageView.image = image
            imageView.tintColor = color
            view.addSubview(imageView)
            leftView = view
        } else {
            leftViewMode = UITextFieldViewMode.never
            leftView = nil
        }
        
        // Placeholder text color
        attributedPlaceholder = NSAttributedString(string: placeholder != nil ?  placeholder! : "", attributes:[NSAttributedStringKey.foregroundColor: color])
    }
}
