//
//  LoginViewController.swift
//  Tile
//
//  Created by  Tim on 11.10.2017.
//  Copyright © 2017 TimHazhyi. All rights reserved.
//

import UIKit
import GoogleSignIn

class LoginViewController: UIViewController, GIDSignInUIDelegate {

    
    override func viewDidLoad() {
        super.viewDidLoad()
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().delegate = SignIn.shared
    }
    
    // MARK: - SingInButtonActions
    
    @IBAction func facebookSignInTaped(_ sender: Any) {
        SignIn.shared.facebookSignIn()
    }
    @IBAction func googleSignInTapped(_ sender: Any) {
        SignIn.shared.googleSignIn()
    }
}
