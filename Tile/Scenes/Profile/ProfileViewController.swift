//
//  ProfileViewController.swift
//  Tile
//
//  Created by  Tim on 07.11.2017.
//  Copyright (c) 2017 TimHazhyi. All rights reserved.


import UIKit
import SwiftKeychainWrapper
import Photos

protocol ProfileDisplayLogic: class
{
    func displayUserData(viewModel: Profile.User.ViewModel)
}

class ProfileViewController: UIViewController, ProfileDisplayLogic
{
    var interactor: ProfileBusinessLogic?
    var router: (NSObjectProtocol & ProfileRoutingLogic & ProfileDataPassing)?
    
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
        let interactor = ProfileInteractor()
        let presenter = ProfilePresenter()
        let router = ProfileRouter()
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
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        getUserData()
        avatarImage.layer.borderWidth = 1
        avatarImage.layer.borderColor = UIColor.white.cgColor
        avatarImage.layer.cornerRadius = avatarImage.frame.size.width / 2
        avatarImage.clipsToBounds = true
        let gesture = UITapGestureRecognizer(target: self, action: #selector(selectAvatar))
        avatarImage.isUserInteractionEnabled = true
        avatarImage.addGestureRecognizer(gesture)
        imagePicker = UIImagePickerController()
        imagePicker.view.tintColor = #colorLiteral(red: 0.8919044137, green: 0.7269840837, blue: 0.4177360535, alpha: 1)
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
    }
    
    @objc func selectAvatar() {
        let photos = PHPhotoLibrary.authorizationStatus()
        if photos == .notDetermined {
            PHPhotoLibrary.requestAuthorization({status in
                if status == .authorized{
                    self.presentAlert()
                } else {
                    // TODO: - open instapicks gallery
                }
            })
        } else {
            presentAlert()
        }
    }
    
    // MARK: Do something
    
    @IBOutlet weak var avatarImage: UIImageView!
    @IBOutlet weak var fullNameLbl: UILabel!
    @IBOutlet weak var emailLbl: UILabel!
    private var imagePicker: UIImagePickerController!
    
    
    @IBAction func logoutBtnPressed(_ sender: Any) {
        let _ = KeychainWrapper.standard.removeAllKeys()
        SignIn.shared.signOut()
        performSegue(withIdentifier: "Login", sender: nil)
    }
    
    func getUserData() {
        interactor?.getUserData()
    }
    
    func presentAlert() {
        let alert = UIAlertController(title: "Select", message: "New userpick", preferredStyle: .actionSheet)
        let cameraAction = UIAlertAction(title: "Use camera", style: .default, handler: { _ in
            self.cameraPicker()
        })
        let libraryAction = UIAlertAction(title: "Open gallery", style: .default, handler: { _ in
            self.libraryPicker()
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cameraAction)
        alert.addAction(libraryAction)
        alert.addAction(cancelAction)
        alert.view.tintColor = #colorLiteral(red: 0.8930782676, green: 0.7270605564, blue: 0.417747438, alpha: 1)
        self.present(alert, animated: true, completion: nil)
    }
    
    func cameraPicker() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            imagePicker.sourceType = UIImagePickerControllerSourceType.camera
            imagePicker.allowsEditing = false
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    func libraryPicker() {
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    
    func displayUserData(viewModel: Profile.User.ViewModel) {
        avatarImage.kf.setImage(with: URL(string: viewModel.profileImgUrl), placeholder: #imageLiteral(resourceName: "user"), options: nil, progressBlock: nil, completionHandler: nil)
        fullNameLbl.text = viewModel.fullName
        emailLbl.text = viewModel.email
    }
}
// MARK: UIImagePicker
extension ProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        guard let userKey = KeychainWrapper.standard.string(forKey: UID_KEY) else {return}
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
            FirebaseService.shared.upload(image: image, forUser: userKey) { [weak self] in
                self?.getUserData()
            }
        } else if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            FirebaseService.shared.upload(image: image, forUser: userKey) { [weak self] in
                self?.getUserData()
            }
        }
        imagePicker.dismiss(animated: true, completion: nil)
    }
}
