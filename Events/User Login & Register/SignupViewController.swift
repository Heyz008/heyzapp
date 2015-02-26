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
    
    let delegate = UIApplication.sharedApplication().delegate as AppDelegate
    
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
            var alertView: UIAlertView = UIAlertView()
            alertView.title = "Log in Failed!"
            alertView.message = "All fields are required."
            alertView.delegate = self
            alertView.addButtonWithTitle("OK")
            alertView.show()
        } else if (!password.isEqualToString(confirmPassword)) {
            var alertView: UIAlertView = UIAlertView()
            alertView.title = "Log in Failed!"
            alertView.message = "Passwords do not match."
            alertView.delegate = self
            alertView.addButtonWithTitle("OK")
            alertView.show()
        } else {
            
            setField(emailTextField, forKey: xmppDefaultIdKey)
            setField(passwordTextField, forKey: xmppDefaultPwdKey)
            
            delegate.disconnect()
            
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
