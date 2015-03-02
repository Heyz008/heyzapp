//
//  NewEventViewController.h
//  Heyz
//
//  Created by Joshua Jiang on 2015-01-29.
//  Copyright (c) 2015 Teknowledge Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface NewEventViewController : UIViewController<UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UIBarButtonItem *cancelButton;
@property (strong, nonatomic) IBOutlet UIScrollView *eventScrollView;

@property (strong, nonatomic) IBOutlet UITextField *eventName;
@property (strong, nonatomic) IBOutlet UIButton *eventLocationButton;

@property (strong, nonatomic) IBOutlet UIButton *uploadButton;
@property (strong, nonatomic) IBOutlet UITextField *eventDescription;


@property (nonatomic, copy) NSString *selectedOurImage;
@property (strong, nonatomic) UIButton *startDate;
@property (strong, nonatomic) UIButton *endDate;

- (IBAction)cancleButtonTapped:(id)sender;

@end
