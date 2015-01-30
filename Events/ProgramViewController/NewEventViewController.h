//
//  NewEventViewController.h
//  Heyz
//
//  Created by Joshua Jiang on 2015-01-29.
//  Copyright (c) 2015 Teknowledge Software. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NewEventViewController : UIViewController

@property (strong, nonatomic) IBOutlet UIBarButtonItem *cancelButton;
@property (strong, nonatomic) IBOutlet UIScrollView *eventScrollView;
@property (strong, nonatomic) IBOutlet UITextField *eventTitle;
@property (strong, nonatomic) IBOutlet UITextField *eventLocation;
@property (strong, nonatomic) IBOutlet UIButton *eventCreateButton;

- (IBAction)cancleButtonTapped:(id)sender;
- (IBAction)createEvent:(id)sender;

@end
