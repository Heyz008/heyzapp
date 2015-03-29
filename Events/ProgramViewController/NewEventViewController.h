//
//  NewEventViewController.h
//  Heyz
//
//  Created by Joshua Jiang on 2015-01-29.
//  Copyright (c) 2015 Teknowledge Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "EventLocationViewController.h"

@interface NewEventViewController : UIViewController<UITextFieldDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (strong, nonatomic) IBOutlet UIBarButtonItem *cancelButton;
@property (strong, nonatomic) IBOutlet UIScrollView *eventScrollView;

@property (strong, nonatomic) IBOutlet UITextField *eventName;
@property (strong, nonatomic) IBOutlet UIButton *eventLocationButton;

@property (strong, nonatomic) IBOutlet UITextField *eventFrom;
@property (strong, nonatomic) IBOutlet UITextField *eventTo;

@property (strong, nonatomic) IBOutlet UIButton *uploadButton;
@property (strong, nonatomic) IBOutlet UISwitch *eventSwitch;
@property (strong, nonatomic) IBOutlet UITextField *eventDescription;
@property (strong, nonatomic) IBOutlet UIView *onlineEventView;


@property (nonatomic, copy) NSString *selectedOurImage;
@property (strong, nonatomic) IBOutlet UIButton *startDate;
@property (strong, nonatomic) IBOutlet UIButton *endDate;
@property (strong, nonatomic) EventLocationViewController *el;

- (IBAction)cancleButtonTapped:(id)sender;
- (IBAction)photoButtonTapped:(id)sender;

- (IBAction)fromSelect:(id)sender;
- (IBAction)toSelect:(id)sender;

@end
