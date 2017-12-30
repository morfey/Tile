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
//    let fullView: CGFloat = 130 // remainder of screen height
    var partialView: CGFloat {
        return UIScreen.main.bounds.height - 130
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        holdView.layer.cornerRadius = 3
        let gesture = UIPanGestureRecognizer.init(target: self, action: #selector(BrightnessViewController.panGesture))
        gesture.delegate = self
        headerView.addGestureRecognizer(gesture)
        setSelected(brightnessButton)
        slider.value =  0.0
        slider.maximumValue = 1.00
        slider.minimumValue = -1.00
        view.tag = 1
        headerView.tag = 1
    }
    
    override func viewDidAppear(_ animated: Bool) {
        UIView.animate(withDuration: 0.3) { [weak self] in
            guard let `self` = self else { return }
            let frame = self.view.frame
            let yComponent = self.partialView
            self.view.frame = CGRect(x: 0,
                                     y: yComponent,
                                     width: frame.width,
                                     height: UIScreen.main.bounds.height - self.partialView)
        }
        slider.value = (delegate?.colorControlsSliders.value(forKey: self.currentKey) as? Float) ?? 0.0
    }
    
    override func viewWillAppear(_ animated: Bool) {
        prepareBackgroundView()
    }
    
    @IBAction func brightnessButtonTapped(_ sender: UIButton) {
        setSelected(sender)
        setSelected(saturationButton, false)
        setSelected(constrastButton, false)
        let brightnessValue = delegate?.colorControlsSliders.value(forKey: kCIInputBrightnessKey) as? Float
        slider.value = brightnessValue ?? 0.0
        slider.maximumValue = 1.00
        slider.minimumValue = -1.00
        currentKey = kCIInputBrightnessKey
    }
    @IBAction func contrastButtonTapped(_ sender: UIButton) {
        setSelected(sender)
        setSelected(saturationButton, false)
        setSelected(brightnessButton, false)
        let contrastValue = delegate?.colorControlsSliders.value(forKey: kCIInputContrastKey) as? Float
        slider.value = contrastValue ?? 1.00
        slider.maximumValue = 2.00
        slider.minimumValue = 0.00
        currentKey = kCIInputContrastKey
    }
    
    @IBAction func saturationButtonTapped(_ sender: UIButton) {
        setSelected(sender)
        setSelected(brightnessButton, false)
        setSelected(constrastButton, false)
        let saturationValue = delegate?.colorControlsSliders.value(forKey: kCIInputSaturationKey) as? Float
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
        if recognizer.state == .ended {
            UIView.animate(withDuration: 0.3, delay: 0.0, options: [.allowUserInteraction], animations: {
                if velocity.y >= 0 {
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
    
    func setSelected(_ button: UIButton, _ force: Bool = true) {
//        button.isHighlighted = force
        if force {
            let view = UIView(frame: CGRect(x: 10, y: button.frame.height, width: button.frame.width - 20, height: 1))
            view.backgroundColor = #colorLiteral(red: 0.8919044137, green: 0.7269840837, blue: 0.4177360535, alpha: 1)
            view.tag = 997
            button.addSubview(view)
        } else {
            button.layer.shadowColor = UIColor.clear.cgColor
            button.subviews.forEach {
                if $0.tag == 997 {
                    $0.removeFromSuperview()
                }
            }
        }
    }
}
