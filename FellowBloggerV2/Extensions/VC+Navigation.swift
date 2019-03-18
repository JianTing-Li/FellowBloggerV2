//
//  VC+Navigation.swift
//  FellowBloggerV2
//
//  Created by Jian Ting Li on 3/18/19.
//  Copyright © 2019 Jian Ting Li. All rights reserved.
//

import UIKit

extension UIViewController {
    public func showLoginView() {
        if let _ = storyboard?.instantiateViewController(withIdentifier: "FellowBloggerTabBarController") as? FellowBloggerTabBarController {
            let loginViewStoryboard = UIStoryboard(name: "LoginView", bundle: nil)
            if let loginController = loginViewStoryboard.instantiateViewController(withIdentifier: "LoginController") as? LoginController {
                (UIApplication.shared.delegate as? AppDelegate)?.window?.rootViewController = loginController
            } else {
                dismiss(animated: true, completion: nil)
            }
        }
    }
}
