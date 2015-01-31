//
//  SignupViewController.swift
//  Heyz
//
//  Created by Jay Yu on 2015-01-28.
//  Copyright (c) 2015 Teknowledge Software. All rights reserved.
//

import UIKit

class SignupViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func gotoLogin(sender: UIButton) {
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func onRegisterBtnTapped(sender: UIButton) {
        
        let email: NSString = emailTextField.text
        let password: NSString = passwordTextField.text
        let confirmPassword: NSString = confirmPasswordTextField.text
        
        if(email.isEqualToString("") || password.isEqualToString("") || confirmPassword.isEqualToString("")){
            var alertView: UIAlertView = UIAlertView()
            alertView.title = "Sign up failed"
            alertView.message = "All fields are required."
            alertView.delegate = self
            alertView.addButtonWithTitle("OK")
            alertView.show()
        } else if !password.isEqualToString(confirmPassword) {
            var alertView: UIAlertView = UIAlertView()
            alertView.title = "Sign up failed"
            alertView.message = "Passwords do not match."
            alertView.delegate = self
            alertView.addButtonWithTitle("OK")
            alertView.show()
        } else {
            println("REGISTERING USER")
            let userManager: UserManager = UserManager.singleton
            userManager.registerUserInBackground(email, password: password, onComplete: { error in
                if error != nil {
                    self.dismissViewControllerAnimated(true, completion: nil)
                } else {
                    
                }
            })
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
