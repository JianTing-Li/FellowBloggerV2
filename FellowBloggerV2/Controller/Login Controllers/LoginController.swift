//
//  LoginController.swift
//  FellowBloggerV2
//
//  Created by Jian Ting Li on 3/14/19.
//  Copyright © 2019 Jian Ting Li. All rights reserved.
//

import UIKit
import FirebaseAuth

class LoginController: UIViewController {

    @IBOutlet weak var emailTextfield: UITextField!
    @IBOutlet weak var passwordTextfield: UITextField!
    
    private var authservice = AppDelegate.authservice
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: true)
        authservice.authserviceExistingAccountDelegate = self
    }

    @IBAction func loginButtonPressed(_ sender: UIButton) {
        guard let email = emailTextfield.text, !email.isEmpty,
            let password = passwordTextfield.text, !password.isEmpty else {
            return
        }
        authservice.signInExistingAccount(email: email, password: password)
    }
}

extension LoginController: AuthServiceExistingAccountDelegate {
    func didRecieveErrorSigningToExistingAccount(_ authservice: AuthService, error: Error) {
        showAlert(title: "Sign in Error", message: error.localizedDescription)
    }
    
    func didSignInToExistingAccount(_ authservice: AuthService, user: User) {
        print("Sign in Successfully")
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let fellowBloggerTabBarController = storyboard.instantiateViewController(withIdentifier: "FellowBloggerTabBarController") as! UITabBarController
        fellowBloggerTabBarController.modalTransitionStyle = .crossDissolve
        fellowBloggerTabBarController.modalPresentationStyle = .overFullScreen
        present(fellowBloggerTabBarController, animated: true)
        // TODO: remove VC
    }
    
    
}
