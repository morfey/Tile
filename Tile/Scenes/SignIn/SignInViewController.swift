//
//  SignInViewController.swift
//  Tile
//
//  Created by  Tim on 24.12.2017.
//  Copyright (c) 2017 TimHazhyi. All rights reserved.


import UIKit
import GoogleSignIn

protocol SignInDisplayLogic: class
{
}

class SignInViewController: UIViewController, SignInDisplayLogic, GIDSignInUIDelegate, GoogleManagerDelegate
{
    
    // MARK: Object lifecycle
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?)
    {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }
    
    // MARK: View lifecycle
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().delegate = SignIn.shared
        SignIn.shared.delegate = self
    }
    
    // MARK: Do something
    @IBOutlet weak var emailTextField: DesignableUITextField!
    @IBOutlet weak var passTextField: DesignableUITextField!
    
    @IBAction func loginBtnTapped(_ sender: UIButton) {
        guard let email = emailTextField.text, let pass = passTextField.text else { return }
        SignIn.shared.emailSignIn(email: email, pass: pass) { [weak self] error in
            if let error = error {
                self?.presentError(error)
            } else {
                self?.routeToTiles(segue: nil)
            }
        }
    }
    
    @IBAction func facebookBtnTapped(_ sender: UIButton) {
        SignIn.shared.facebookSignIn { [weak self] _ in
            self?.routeToTiles(segue: nil)
        }
    }
    @IBAction func googleBtnTapped(_ sender: UIButton) {
        SignIn.shared.googleSignIn()
    }
    
    func handleError(_ error: Error) {
        presentError(error)
    }
    
    func handleSuccess() {
        routeToTiles(segue: nil)
    }
    
    func presentError(_ error: Error) {
        let alert = UIAlertController(title: "Error in login", message: error.localizedDescription, preferredStyle: .alert)
        alert.view.tintColor = #colorLiteral(red: 0.8919044137, green: 0.7269840837, blue: 0.4177360535, alpha: 1)
        let action = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    func routeToTiles(segue: UIStoryboardSegue?)
    {
        if let segue = segue {
            let _ = segue.destination as! TilesViewController
        } else {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let destinationVC = storyboard.instantiateViewController(withIdentifier: "mainNavigation") as! UINavigationController
            showDetailViewController(destinationVC, sender: nil)
        }
    }
}
