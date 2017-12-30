//
//  FiltersViewController.swift
//  Tile
//
//  Created by  Tim on 28.11.2017.
//  Copyright © 2017 TimHazhyi. All rights reserved.
//

import UIKit

class FiltersViewController: UIViewController, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var holdView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var filtersViewControllerDelegate: FiltersViewControllerDelegate?
    var gpuImagePlusDelegate: GPUimagePlusDelegate?
    var originalImage: UIImage!
    
    let screenSize = UIScreen.main.bounds.size
    var images: [CGImage]!
    
    var partialView: CGFloat {
        return UIScreen.main.bounds.height - 130
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        holdView.layer.cornerRadius = 3

        let gesture = UIPanGestureRecognizer.init(target: self, action: #selector(FiltersViewController.panGesture))
        gesture.delegate = self
        view.addGestureRecognizer(gesture)
        
        DispatchQueue.global().async {
            self.images = self.gpuImagePlusDelegate?.proccessFilters(image: self.originalImage)
            DispatchQueue.main.async {
                self.configurateScrollView()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        prepareBackgroundView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        UIView.animate(withDuration: 0.3) { [weak self] in
            guard let `self` = self else { return }
            let frame = self.view.frame
            let yComponent = self.partialView
            self.view.frame = CGRect(x: 0,
                                     y: yComponent,
                                     width: frame.width,
                                     height: UIScreen.main.bounds.height - self.partialView)
        }
    }
    
    @objc func didSelectFilter(_ sender: UIButton) {
        filtersViewControllerDelegate?.didSelectFilter(sender)
    }
    
    func configurateScrollView() {
        var xCoord: CGFloat = 5
        let yCoord: CGFloat = 5
        let buttonWidth:CGFloat = 70
        let buttonHeight: CGFloat = 70
        let gapBetweenButtons: CGFloat = 5
        var itemCount = 0
        
        for (index, i) in images.enumerated() {
            //save(image: UIImage(cgImage: i), i: index)
            itemCount = index
            let filterButton = UIButton(type: .custom)
            filterButton.frame = CGRect(x: xCoord, y: yCoord, width: buttonWidth, height: buttonHeight)
            filterButton.tag = itemCount
            filterButton.addTarget(self, action: #selector(didSelectFilter(_:)), for: .touchUpInside)
            filterButton.layer.cornerRadius = 6
            filterButton.clipsToBounds = true
            filterButton.imageView?.contentMode = .center
            let imageForButton = UIImage(cgImage: i)
            filterButton.setBackgroundImage(imageForButton, for: .normal)
            filterButton.contentMode = .scaleAspectFit
            xCoord +=  buttonWidth + gapBetweenButtons
            scrollView.addSubview(filterButton)
            activityIndicator.stopAnimating()
        }
        
        scrollView.contentSize = CGSize(width: buttonWidth * CGFloat(itemCount + 2), height: yCoord)
    }
    
    //MARK: Pan Gesture
    
    @objc func panGesture(_ recognizer: UIPanGestureRecognizer) {
        
        let translation = recognizer.translation(in: self.view)
        let velocity = recognizer.velocity(in: self.view)
        
        let y = self.view.frame.minY
        if recognizer.state == .ended {
            UIView.animate(withDuration: 0.3, delay: 0.0, options: [.allowUserInteraction], animations: {
                if  velocity.y >= 0 {
                    if y + translation.y >= self.partialView  {
                        self.removeBottomSheetView()
                    } else {
                        self.view.frame = CGRect(x: 0, y: self.partialView, width: self.view.frame.width, height: UIScreen.main.bounds.height - self.partialView)
                        self.view.layoutIfNeeded()
                    }
                } else {
                    if y + translation.y >= self.partialView  {
                        self.view.frame = CGRect(x: 0, y: self.partialView, width: self.view.frame.width, height: UIScreen.main.bounds.height - self.partialView)
                        self.view.layoutIfNeeded()
                    }
                }
                
            }, completion: nil)
        }
    }
    
    func removeBottomSheetView() {
        UIView.animate(withDuration: 0.3,
                       delay: 0,
                       options: UIViewAnimationOptions.curveEaseIn,
                       animations: { () -> Void in
                        var frame = self.view.frame
                        frame.origin.y = UIScreen.main.bounds.maxY
                        self.view.frame = frame
                        
        }, completion: { (finished) -> Void in
            self.view.removeFromSuperview()
            self.removeFromParentViewController()
            self.filtersViewControllerDelegate?.filtersViewDidDisappear()
        })
    }
    
    func prepareBackgroundView(){
        let blurEffect = UIBlurEffect.init(style: .light)
        let visualEffect = UIVisualEffectView.init(effect: blurEffect)
        let bluredView = UIVisualEffectView.init(effect: blurEffect)
        bluredView.contentView.addSubview(visualEffect)
        visualEffect.frame = UIScreen.main.bounds
        bluredView.frame = UIScreen.main.bounds
        view.insertSubview(bluredView, at: 0)
    }
}


