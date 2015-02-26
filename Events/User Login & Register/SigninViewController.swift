//
//  LoginViewController.swift
//  Chat
//
//  Created by My App Templates Team on 24/08/14.
//  Copyright (c) 2014 My App Templates. All rights reserved.
//

import UIKit

class SigninViewController: UIViewController, UITextFieldDelegate{
    
    @IBOutlet var viewForContent : UIScrollView!
    @IBOutlet var viewForUser : UIView!
    @IBOutlet var txtForEmail : UITextField!
    @IBOutlet var txtForPassword : UITextField!
    
    let delegate = UIApplication.sharedApplication().delegate as AppDelegate
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        // Custom initialization
        
    }
    
    required init(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        var size = UIScreen.mainScreen().bounds.size
        viewForContent.contentSize = CGSizeMake(size.width, 568)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var size = UIScreen.mainScreen().bounds.size
        viewForContent.contentSize = CGSizeMake(size.width, 568)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("willShowKeyBoard:"), name:UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("willHideKeyBoard:"), name:UIKeyboardWillHideNotification, object: nil)
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
//        txtForEmail.text = NSUserDefaults.standardUserDefaults().stringForKey(xmppDefaultJID)
//        txtForPassword.text = NSUserDefaults.standardUserDefaults().stringForKey(xmppDefaultPassword)
    }
    
    func willShowKeyBoard(notification : NSNotification){
    
        var userInfo: NSDictionary!
        userInfo = notification.userInfo

        var duration : NSTimeInterval = 0
        var curve = userInfo.objectForKey(UIKeyboardAnimationCurveUserInfoKey) as UInt
        duration = userInfo[UIKeyboardAnimationDurationUserInfoKey] as NSTimeInterval
        var keyboardF:NSValue = userInfo.objectForKey(UIKeyboardFrameEndUserInfoKey) as NSValue
        var keyboardFrame = keyboardF.CGRectValue()
        
        UIView.animateWithDuration(duration, delay: 0, options:nil, animations: {
            self.viewForContent.contentOffset = CGPointMake(0, keyboardFrame.size.height)
            
            }, completion: nil)
       
    }
    
    func willHideKeyBoard(notification : NSNotification){
        
        var userInfo: NSDictionary!
        userInfo = notification.userInfo
        
        var duration : NSTimeInterval = 0
        var curve = userInfo.objectForKey(UIKeyboardAnimationCurveUserInfoKey) as UInt
        duration = userInfo[UIKeyboardAnimationDurationUserInfoKey] as NSTimeInterval
        var keyboardF:NSValue = userInfo.objectForKey(UIKeyboardFrameEndUserInfoKey) as NSValue
        var keyboardFrame = keyboardF.CGRectValue()
        
        UIView.animateWithDuration(duration, delay: 0, options:nil, animations: {
            self.viewForContent.contentOffset = CGPointMake(0, 0)
            
            }, completion: nil)
        
    }
    
    func textFieldShouldReturn (textField: UITextField!) -> Bool{
        if ((textField == txtForEmail)){
            txtForPassword.becomeFirstResponder();
        } else if (textField == txtForPassword){
            textField.resignFirstResponder()
        }
        return true
    }
    
    func setField(field: UITextField, forKey key: String){
        if field.text != nil {
            NSUserDefaults.standardUserDefaults().setObject(field.text, forKey: key)
        } else {
            NSUserDefaults.standardUserDefaults().removeObjectForKey(key)
        }
    }
    
    @IBAction func registerBtnTapped() {
        self.performSegueWithIdentifier("registerSegue", sender: self)
    }
    
    @IBAction func loginBtnTapped() {
//        self.dismissViewControllerAnimated(true, completion: nil);
        
        let user: NSString = txtForEmail.text
        let password: NSString = txtForPassword.text
        
        if user.isEqualToString("") || password.isEqualToString(""){
            var alertView: UIAlertView = UIAlertView()
            alertView.title = "Log in failed"
            alertView.message = "Please enter your username and password"
            alertView.delegate = self
            alertView.addButtonWithTitle("OK")
            alertView.show()
        } else {
            
            setField(txtForEmail, forKey: xmppDefaultIdKey)
            setField(txtForPassword, forKey: xmppDefaultPwdKey)
            
            if delegate.connect() {
                self.dismissViewControllerAnimated(true, completion: nil)
            }
        }
        
    }

    @IBAction func facebookBtnTapped() {
//        self.dismissViewControllerAnimated(true, completion: nil);
    }
    
    @IBAction func twitterBtnTapped() {
//        self.dismissViewControllerAnimated(true, completion: nil);
    }
    
    @IBAction func forgotPasswordBtnTapped() {
//        self.dismissViewControllerAnimated(true, completion: nil);  
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    

    /*
    // #pragma mark - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue?, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

}
