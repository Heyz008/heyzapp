//
//  SignupViewController.swift
//  Heyz
//
//  Created by Jay Yu on 2015-01-28.
//  Copyright (c) 2015 Teknowledge Software. All rights reserved.
//

import UIKit

class SignupViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    
    let userManager = UserManager.singleton
    
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
    
    func setField(field: UITextField, forKey key: String){
        if field.text != nil {
            NSUserDefaults.standardUserDefaults().setObject(field.text, forKey: key)
        } else {
            NSUserDefaults.standardUserDefaults().removeObjectForKey(key)
        }
    }

    @IBAction func onRegisterBtnTapped(sender: UIButton) {
        
        let email: NSString = emailTextField.text
        let password: NSString = passwordTextField.text
        let confirmPassword: NSString = confirmPasswordTextField.text
        
        if(email.isEqualToString("") || password.isEqualToString("") || confirmPassword.isEqualToString("") || email.isEqualToString("")){
            
            let alertController = UIAlertController(title: "Registration failed", message: "All fields are required.", preferredStyle: .Alert)
            let defaultAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
            
            alertController.addAction(defaultAction)
            
            presentViewController(alertController, animated: true, completion: nil)
            
        } else if (!password.isEqualToString(confirmPassword)) {
            
            let alertController = UIAlertController(title: "Registration failed", message: "Passwords do not match.", preferredStyle: .Alert)
            let defaultAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
            
            alertController.addAction(defaultAction)
            
            presentViewController(alertController, animated: true, completion: nil)
            
        } else {
            
            setField(emailTextField, forKey: appDefaultIdKey)
            setField(passwordTextField, forKey: appDefaultPwdKey)
            
            userManager.signupInBackground(email, password: password, email: email, sender: self)
            
        }

    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        if ((textField == emailTextField)){
            passwordTextField.becomeFirstResponder();
        } else if (textField == passwordTextField){
            confirmPasswordTextField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        return true
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
