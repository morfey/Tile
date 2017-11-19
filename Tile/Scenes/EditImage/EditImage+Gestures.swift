//
//  EditImage+Gestures.swift
//  Tile
//
//  Created by  Tim on 12.11.2017.
//  Copyright © 2017 TimHazhyi. All rights reserved.
//

import Foundation
import UIKit

extension EditImageViewController : UIGestureRecognizerDelegate  {
    
    func addGestures(view: UIView) {
        //Gestures
        view.isUserInteractionEnabled = true
        
        let panGesture = UIPanGestureRecognizer(target: self,
                                                action: #selector(EditImageViewController.panGesture))
        panGesture.minimumNumberOfTouches = 1
        panGesture.maximumNumberOfTouches = 1
        panGesture.delegate = self
        view.addGestureRecognizer(panGesture)
        
        let pinchGesture = UIPinchGestureRecognizer(target: self,
                                                    action: #selector(EditImageViewController.pinchGesture))
        pinchGesture.delegate = self
        view.addGestureRecognizer(pinchGesture)
        
        let rotationGestureRecognizer = UIRotationGestureRecognizer(target: self,
                                                                    action:#selector(EditImageViewController.rotationGesture) )
        rotationGestureRecognizer.delegate = self
        view.addGestureRecognizer(rotationGestureRecognizer)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(EditImageViewController.tapGesture))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc func panGesture(_ recognizer: UIPanGestureRecognizer) {
        if let view = recognizer.view {
            if view is UIImageView {
                if recognizer.state == .began {
                    for imageView in subImageViews(view: imageCropperView) {
                        let location = recognizer.location(in: imageView)
                        let alpha = imageView.alphaAtPoint(location)
                        if alpha > 0 {
                            imageViewToPan = imageView
                            break
                        }
                    }
                }
                if imageViewToPan != nil {
                    moveView(view: imageViewToPan!, recognizer: recognizer)
                }
            } else {
                moveView(view: view, recognizer: recognizer)
            }
        }
    }
    
    @objc func pinchGesture(_ recognizer: UIPinchGestureRecognizer) {
        if let view = recognizer.view {
            if view is UITextView {
                let textView = view as! UITextView
                
                if textView.font!.pointSize * recognizer.scale < 90 {
                    let font = UIFont(name: textView.font!.fontName, size: textView.font!.pointSize * recognizer.scale)
                    textView.font = font
                    let sizeToFit = textView.sizeThatFits(CGSize(width: UIScreen.main.bounds.size.width,
                                                                 height:CGFloat.greatestFiniteMagnitude))
                    textView.bounds.size = CGSize(width: textView.intrinsicContentSize.width,
                                                  height: sizeToFit.height)
                } else {
                    let sizeToFit = textView.sizeThatFits(CGSize(width: UIScreen.main.bounds.size.width,
                                                                 height:CGFloat.greatestFiniteMagnitude))
                    textView.bounds.size = CGSize(width: textView.intrinsicContentSize.width,
                                                  height: sizeToFit.height)
                }
                
                
                textView.setNeedsDisplay()
            } else {
                view.transform = view.transform.scaledBy(x: recognizer.scale, y: recognizer.scale)
            }
            recognizer.scale = 1
        }
    }

    @objc func rotationGesture(_ recognizer: UIRotationGestureRecognizer) {
        if let view = recognizer.view {
            view.transform = view.transform.rotated(by: recognizer.rotation)
            recognizer.rotation = 0
        }
    }
    
    @objc func tapGesture(_ recognizer: UITapGestureRecognizer) {
        if let view = recognizer.view {
            if view is UIImageView {
                for imageView in subImageViews(view: imageCropperView) {
                    let location = recognizer.location(in: imageView)
                    let alpha = imageView.alphaAtPoint(location)
                    if alpha > 0 {
                        scaleEffect(view: imageView)
                        break
                    }
                }
            } else {
                scaleEffect(view: view)
            }
        }
    }
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
    
//    func screenEdgeSwiped(_ recognizer: UIScreenEdgePanGestureRecognizer) {
//        if recognizer.state == .recognized {
//            if !stickersVCIsVisible {
//                addStickersViewController()
//            }
//        }
//    }
    
//    override public var prefersStatusBarHidden: Bool {
//        return true
//    }
//
    func scaleEffect(view: UIView) {
        view.superview?.bringSubview(toFront: view)

        if #available(iOS 10.0, *) {
            let generator = UIImpactFeedbackGenerator(style: .heavy)
            generator.impactOccurred()
        }
        let previouTransform =  view.transform
        UIView.animate(withDuration: 0.2,
                       animations: {
                        view.transform = view.transform.scaledBy(x: 1.2, y: 1.2)
        },
                       completion: { _ in
                        UIView.animate(withDuration: 0.2) {
                            view.transform  = previouTransform
                        }
        })
    }

    func moveView(view: UIView, recognizer: UIPanGestureRecognizer)  {

//        hideToolbar(hide: true)
//        deleteView.isHidden = false

        view.superview?.bringSubview(toFront: view)
//        let pointToSuperView = recognizer.location(in: self.view)

        view.center = CGPoint(x: view.center.x + recognizer.translation(in: imageCropperView).x,
                              y: view.center.y + recognizer.translation(in: imageCropperView).y)

        recognizer.setTranslation(CGPoint.zero, in: imageCropperView)

//        if let previousPoint = lastPanPoint {
//            if deleteView.frame.contains(pointToSuperView) && !deleteView.frame.contains(previousPoint) {
//                if #available(iOS 10.0, *) {
//                    let generator = UIImpactFeedbackGenerator(style: .heavy)
//                    generator.impactOccurred()
//                }
//                UIView.animate(withDuration: 0.3, animations: {
//                    view.transform = view.transform.scaledBy(x: 0.25, y: 0.25)
//                    view.center = recognizer.location(in: self.imageCropperView)
//                })
//            }
//            else if deleteView.frame.contains(previousPoint) && !deleteView.frame.contains(pointToSuperView) {
//                UIView.animate(withDuration: 0.3, animations: {
//                    view.transform = view.transform.scaledBy(x: 4, y: 4)
//                    view.center = recognizer.location(in: self.imageCropperView)
//                })
//            }
//        }
//        lastPanPoint = pointToSuperView

//        if recognizer.state == .ended {
//            imageViewToPan = nil
//            lastPanPoint = nil
//            hideToolbar(hide: false)
//            deleteView.isHidden = true
//            let point = recognizer.location(in: self.view)
//
//            if deleteView.frame.contains(point) { // Delete the view
//                view.removeFromSuperview()
//                if #available(iOS 10.0, *) {
//                    let generator = UINotificationFeedbackGenerator()
//                    generator.notificationOccurred(.success)
//                }
//            } else if !canvasImageView.bounds.contains(view.center) { //Snap the view back to canvasImageView
//                UIView.animate(withDuration: 0.3, animations: {
//                    view.center = self.canvasImageView.center
//                })
//
//            }
//        }
    }
    
    func subImageViews(view: UIView) -> [UIImageView] {
        var imageviews: [UIImageView] = []
        for imageView in view.subviews {
            if imageView is UIImageView {
                imageviews.append(imageView as! UIImageView)
            }
        }
        return imageviews
    }
}
