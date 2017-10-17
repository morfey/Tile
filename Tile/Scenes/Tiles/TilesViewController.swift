//
//  TilesViewController.swift
//  Tile
//
//  Created by  Tim on 16.10.2017.
//  Copyright (c) 2017 TimHazhyi. All rights reserved.
//
//  This file was generated by the Clean Swift Xcode Templates so
//  you can apply clean architecture to your iOS and Mac projects,
//  see http://clean-swift.com
//

import UIKit
import SwiftKeychainWrapper

protocol TilesDisplayLogic: class
{
    func displaySelectedImage(viewModel: Tiles.SelectedImage.ViewModel)
}

class TilesViewController: UIViewController, TilesDisplayLogic, UIImagePickerControllerDelegate, UINavigationControllerDelegate
{
    var interactor: TilesBusinessLogic?
    var router: (NSObjectProtocol & TilesRoutingLogic & TilesDataPassing)?
    
    // MARK: Object lifecycle
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?)
    {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        setup()
    }
    
    // MARK: Setup
    
    private func setup()
    {
        let viewController = self
        let interactor = TilesInteractor()
        let presenter = TilesPresenter()
        let router = TilesRouter()
        viewController.interactor = interactor
        viewController.router = router
        interactor.presenter = presenter
        presenter.viewController = viewController
        router.viewController = viewController
        router.dataStore = interactor
    }
    
    // MARK: Routing
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if let scene = segue.identifier {
            let selector = NSSelectorFromString("routeTo\(scene)WithSegue:")
            if let router = router, router.responds(to: selector) {
                router.perform(selector, with: segue)
            }
        }
    }
    
    // MARK: View lifecycle
    var imagePicker: UIImagePickerController!
    var imgSelected = false
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if KeychainWrapper.standard.string(forKey: "uid") == nil {
            performSegue(withIdentifier: "Login", sender: nil)
        }
        interactor?.setImage(image: nil)
    }
    
    // MARK: Do something
    
    @IBOutlet weak var imageAdd: UIImageView!
    //@IBOutlet weak var nameTextField: UITextField!
    
    @IBAction func eidtImageTapped(_ sender: Any) {
        performSegue(withIdentifier: "EditImage", sender: nil)
    }
    
    @IBAction func selectImage(_ sender: Any) {
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func signOut(_ sender: Any) {
        KeychainWrapper.standard.removeAllKeys()
    }
    
    @IBAction func cameraTapped(_ sender: Any) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
            imagePicker.sourceType = UIImagePickerControllerSourceType.camera
            imagePicker.allowsEditing = false
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
            imgSelected = true
            interactor?.setImage(image: image)
        } else if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imgSelected = true
            interactor?.setImage(image: image)
        }
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    func displaySelectedImage(viewModel: Tiles.SelectedImage.ViewModel) {
        imageAdd.image = viewModel.image
    }
}
