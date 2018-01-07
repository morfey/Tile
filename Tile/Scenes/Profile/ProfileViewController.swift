//
//  ProfileViewController.swift
//  Tile
//
//  Created by  Tim on 07.11.2017.
//  Copyright (c) 2017 TimHazhyi. All rights reserved.


import UIKit
import SwiftKeychainWrapper

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
        avatarImage.layer.masksToBounds = false
        avatarImage.layer.borderColor = UIColor.clear.cgColor
        avatarImage.layer.cornerRadius = avatarImage.frame.height / 2
        avatarImage.clipsToBounds = true
    }
    
    // MARK: Do something
    
    @IBOutlet weak var avatarImage: UIImageView!
    @IBOutlet weak var fullNameLbl: UILabel!
    @IBOutlet weak var emailLbl: UILabel!
    
    
    @IBAction func logoutBtnPressed(_ sender: Any) {
        let _ = KeychainWrapper.standard.removeAllKeys()
        SignIn.shared.signOut()
        performSegue(withIdentifier: "Login", sender: nil)
    }
    
    func getUserData() {
        interactor?.getUserData()
    }
    
    func displayUserData(viewModel: Profile.User.ViewModel) {
        avatarImage.kf.setImage(with: URL(string: viewModel.profileImgUrl), placeholder: #imageLiteral(resourceName: "user"), options: nil, progressBlock: nil, completionHandler: nil)
        fullNameLbl.text = viewModel.fullName
        emailLbl.text = viewModel.email
    }
}
