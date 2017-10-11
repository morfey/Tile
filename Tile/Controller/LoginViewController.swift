//
//  LoginViewController.swift
//  Tile
//
//  Created by  Tim on 11.10.2017.
//  Copyright © 2017 TimHazhyi. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    // MARK: - SingInButtonActions
    
    @IBAction func facebookSignInTaped(_ sender: Any) {
        SignIn.shared.facebookSignIn()
    }
    @IBAction func googleSignInTapped(_ sender: Any) {
    }
}

