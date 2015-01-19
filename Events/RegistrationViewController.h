//
//  RegistrationViewController.h
//  Events
//
//  Copyright (c) 2014 Teknowledge Software. All rights reserved.
//


#import <UIKit/UIKit.h>

@protocol registrationViewDelegate <NSObject>

-(void)dismissRegistrationView;

@end
@interface RegistrationViewController : UIViewController<UITextFieldDelegate,UIAlertViewDelegate>{
    id<registrationViewDelegate> __unsafe_unretained delegate;
    
}

@property (assign, nonatomic) id<registrationViewDelegate> __unsafe_unretained delegate;
@property (strong, nonatomic) IBOutlet UIScrollView *scrlView;

@property (strong, nonatomic) IBOutlet UITextField *txtName;
@property (strong, nonatomic) IBOutlet UITextField *txtEmail;
@property (strong, nonatomic) IBOutlet UITextField *txtPassword;

@property (strong, nonatomic) NSArray *countryArray;
@property (strong, nonatomic) NSString *countryName, *countryCode;

-(IBAction)btnRegisterPressed:(id)sender;

@end