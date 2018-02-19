//
//  UIView+Image.swift
//  Photo Editor
//
//  Created by Mohamed Hamed on 4/23/17.
//  Copyright © 2017 Mohamed Hamed. All rights reserved.
//

import UIKit

extension UIView {
    
    func toImage() -> UIImage {
        var size: CGSize = .zero
        self.subviews.forEach {
            if let imageView = $0 as? UIImageView {
                if imageView.image?.size.width ?? 0 > size.width {
                    size = imageView.image?.size ?? .zero
                }
            }
        }
        UIGraphicsBeginImageContextWithOptions(size, self.isOpaque, 0.0)
        self.drawHierarchy(in: CGRect(origin: self.bounds.origin, size: size), afterScreenUpdates: false)
        let snapshotImageFromMyView = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return snapshotImageFromMyView!
    }
    
    func toImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.image = toImage()
        imageView.frame = frame
        imageView.contentMode = .scaleAspectFit
        return imageView
    }
}


