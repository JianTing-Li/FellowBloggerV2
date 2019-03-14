//
//  RegisterController.swift
//  FellowBloggerV2
//
//  Created by Jian Ting Li on 3/14/19.
//  Copyright © 2019 Jian Ting Li. All rights reserved.
//

import UIKit

class RegisterController: UIViewController {

    @IBOutlet weak var usernameTextfield: UITextField!
    @IBOutlet weak var emailTextfield: UITextField!
    @IBOutlet weak var passwordTextfield: UITextField!
    
    private var authservice = AppDelegate.authservice
    
    override func viewDidLoad() {
        super.viewDidLoad()
        authservice.authserviceCreateNewAccountDelegate = self
    }
    
    @IBAction func registerButtonPressed(_ sender: UIButton) {
        guard let username = usernameTextfield.text, !username.isEmpty,
            let email = emailTextfield.text, !email.isEmpty,
            let password = passwordTextfield.text, !password.isEmpty else {
                return
        }
        authservice.createNewAccount(username: username, email: email, password: password)
    }
    
    @IBAction func alreadyHaveAccountButtonPressed(_ sender: UIButton) {
         navigationController?.popViewController(animated: true)
    }
}

extension RegisterController: AuthServiceCreateNewAccountDelegate {
    func didRecieveErrorCreatingAccount(_ authservice: AuthService, error: Error) {
        showAlert(title: "Account Creation Error", message: error.localizedDescription)
    }
    
    func didCreateNewAccount(_ authservice: AuthService, blogger: Blogger) {
        print("Account Created")
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let fellowBloggerTabBarController = storyboard.instantiateViewController(withIdentifier: "FellowBloggerTabBarController") as! UITabBarController
        fellowBloggerTabBarController.modalTransitionStyle = .crossDissolve
        fellowBloggerTabBarController.modalPresentationStyle = .overFullScreen
        present(fellowBloggerTabBarController, animated: true)
    }
}
