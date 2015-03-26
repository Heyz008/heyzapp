//
//  NewEventSecondViewController.h
//  Heyz
//
//  Created by Joshua Jiang on 2015-03-04.
//  Copyright (c) 2015 Teknowledge Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SelectTableViewController.h"

@interface NewEventSecondViewController : UIViewController<SelectTableViewControllerDelegate>

@property (strong, nonatomic) IBOutlet UIButton *privacy;
@property (strong, nonatomic) IBOutlet UIButton *category;
@property (strong, nonatomic) IBOutlet UIButton *maximum;
@property (strong, nonatomic) IBOutlet UIButton *payment;

@property (strong, nonatomic) NSString *eName;
@property CGFloat eLatitude;
@property CGFloat eLongitude;
@property (strong, nonatomic) NSString *eStart;
@property (strong, nonatomic) NSString *eEnd;
@property (strong, nonatomic) UIImage *eImage;
@property (strong, nonatomic) NSString *eDescription;
@property (strong, nonatomic) NSString *eAddress;

-(IBAction)createNewEvent:(id)sender;

@end
