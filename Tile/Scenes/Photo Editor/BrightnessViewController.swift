//
//  BrightnessViewController.swift
//  Tile
//
//  Created by  Tim on 21.12.2017.
//  Copyright © 2017 TimHazhyi. All rights reserved.
//

import UIKit

class BrightnessViewController: UIViewController, UIGestureRecognizerDelegate {
    @IBOutlet weak var holdView: UIView!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var brightnessButton: UIButton!
    @IBOutlet weak var constrastButton: UIButton!
    @IBOutlet weak var saturationButton: UIButton!
    private var currentKey: String = kCIInputBrightnessKey
    
    let screenSize = UIScreen.main.bounds.size
    var delegate: BrightnessViewControllerDelegate?
    let fullView: CGFloat = 150 // remainder of screen height
    var partialView: CGFloat {
        return UIScreen.main.bounds.height - 130
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        holdView.layer.cornerRadius = 3
        let gesture = UIPanGestureRecognizer.init(target: self, action: #selector(BrightnessViewController.panGesture))
        gesture.delegate = self
        view.addGestureRecognizer(gesture)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        UIView.animate(withDuration: 0.6) { [weak self] in
            guard let `self` = self else { return }
            let frame = self.view.frame
            let yComponent = self.partialView
            self.view.frame = CGRect(x: 0,
                                     y: yComponent,
                                     width: frame.width,
                                     height: UIScreen.main.bounds.height - self.partialView)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        prepareBackgroundView()
    }
    
    @IBAction func brightnessButtonTapped(_ sender: UIButton) {
        setSelected(sender)
        saturationButton.isHighlighted = false
        constrastButton.isHighlighted = false
        let brightnessValue = delegate?.colorControlsFilter.value(forKey: kCIInputBrightnessKey) as? Float
        slider.value = brightnessValue ?? 0.0
        slider.maximumValue = 1.00
        slider.minimumValue = -1.00
        currentKey = kCIInputBrightnessKey
    }
    @IBAction func contrastButtonTapped(_ sender: UIButton) {
        setSelected(sender)
        saturationButton.isHighlighted = false
        brightnessButton.isHighlighted = false
        let contrastValue = delegate?.colorControlsFilter.value(forKey: kCIInputContrastKey) as? Float
        slider.value = contrastValue ?? 1.00
        slider.maximumValue = 2.00
        slider.minimumValue = 0.00
        currentKey = kCIInputContrastKey
    }
    
    @IBAction func saturationButtonTapped(_ sender: UIButton) {
        setSelected(sender)
        brightnessButton.isHighlighted = false
        constrastButton.isHighlighted = false
        let saturationValue = delegate?.colorControlsFilter.value(forKey: kCIInputSaturationKey) as? Float
        slider.value = saturationValue ?? 1.00
        slider.maximumValue = 2.00
        slider.minimumValue = 0.00
        currentKey = kCIInputSaturationKey
    }
    
    @IBAction func didChangeValue(_ sender: UISlider) {
        delegate?.didChangeFilter(value: sender.value, forKey: currentKey)
    }
    
    @objc func panGesture(_ recognizer: UIPanGestureRecognizer) {
        
        let translation = recognizer.translation(in: self.view)
        let velocity = recognizer.velocity(in: self.view)
        
        let y = self.view.frame.minY
        if y + translation.y >= fullView {
            let newMinY = y + translation.y
            self.view.frame = CGRect(x: 0, y: newMinY, width: view.frame.width, height: UIScreen.main.bounds.height - newMinY )
            self.view.layoutIfNeeded()
            recognizer.setTranslation(CGPoint.zero, in: self.view)
        }
        
        if recognizer.state == .ended {
            var duration =  velocity.y < 0 ? Double((y - fullView) / -velocity.y) : Double((partialView - y) / velocity.y )
            duration = duration > 1.3 ? 1 : duration
            //velocity is direction of gesture
            UIView.animate(withDuration: duration, delay: 0.0, options: [.allowUserInteraction], animations: {
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
                    } else {
                        self.view.frame = CGRect(x: 0, y: self.fullView, width: self.view.frame.width, height: UIScreen.main.bounds.height - self.fullView)
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
            self.delegate?.brightnessViewDidDisappear()
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
    
    func setSelected(_ button: UIButton) {
        button.isSelected = !button.isSelected
        if button.isSelected {
            button.layer.shadowColor = UIColor.red.cgColor
            button.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
            button.layer.masksToBounds = false
            button.layer.shadowRadius = 2
            button.layer.shadowOpacity = 0.2
        } else {
            button.layer.shadowColor = UIColor.clear.cgColor
        }
    }
}
