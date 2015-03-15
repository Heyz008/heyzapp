//
//  NewEventSecondViewController.m
//  Heyz
//
//  Created by Joshua Jiang on 2015-03-04.
//  Copyright (c) 2015 Teknowledge Software. All rights reserved.
//

#import "NewEventSecondViewController.h"
#import "M13Checkbox.h"
#import <Parse/Parse.h>

@interface NewEventSecondViewController () {
    NSArray *privacys;
    NSArray *categories;
    NSArray *maximums;
    NSArray *payments;
    
    int privacyIndex;
    int categoryIndex;
    int maximumIndex;
    int paymentIndex;
}

@end

@implementation NewEventSecondViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    privacys = @[@"Public", @"Friends Only", @"Strangers Only", @"Invite Only"];
    categories = @[@"Clubbing", @"Chat Time", @"Concert", @"Coffee"];
    maximums = @[@"Unlimited", @"1 - 10", @"11 - 100", @"101 - 1000"];
    payments = @[@"Free", @"AA", @"你请客", @"我请客"];
    
    self.privacy.layer.borderColor = [UIColor blackColor].CGColor;
    self.privacy.layer.borderWidth = 1.0f;
    self.privacy.titleLabel.text = @"Privacy";
    self.privacy.titleLabel.textAlignment = UIControlContentHorizontalAlignmentLeft;
    
    self.category.layer.borderColor = [UIColor blackColor].CGColor;
    self.category.layer.borderWidth = 1.0f;
    self.category.titleLabel.text = @"Category";
    self.category.titleLabel.textAlignment = UIControlContentHorizontalAlignmentLeft;
    
    self.maximum.layer.borderColor = [UIColor blackColor].CGColor;
    self.maximum.layer.borderWidth = 1.0f;
    self.maximum.titleLabel.text = @"Maximum";
    self.maximum.titleLabel.textAlignment = UIControlContentHorizontalAlignmentLeft;
    
    self.payment.layer.borderColor = [UIColor blackColor].CGColor;
    self.payment.layer.borderWidth = 1.0f;
    self.payment.titleLabel.text = @"Payment Type";
    self.payment.titleLabel.textAlignment = UIControlContentHorizontalAlignmentLeft;
    
    M13Checkbox *checkBox = [[M13Checkbox alloc] initWithTitle:@"加入event时需要二次确认"];
    checkBox.titleLabel.font = [UIFont systemFontOfSize:12];
    checkBox.strokeColor = [UIColor blackColor];
    checkBox.checkColor = [UIColor blackColor];
    [checkBox setCheckAlignment:M13CheckboxAlignmentLeft];
    checkBox.frame = CGRectMake(self.privacy.frame.origin.x, self.privacy.frame.origin.y + self.privacy.frame.size.height + 6, self.privacy.frame.size.width, 16);
    [self.view addSubview:checkBox];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)privacySelected:(NSString*)info withIndex:(int)index {
    privacyIndex = index;
    [self.privacy setTitle:[NSString stringWithFormat:@"Privacy                          %@", info] forState:UIControlStateNormal];
}

-(void)categorySelected:(NSString*)info withIndex:(int)index {
    categoryIndex = index;
    [self.category setTitle:[NSString stringWithFormat:@"Category                       %@", info] forState:UIControlStateNormal];
}

-(void)maximumSelected:(NSString*)info withIndex:(int)index {
    maximumIndex = index;
    [self.maximum setTitle:[NSString stringWithFormat:@"Maximum                      %@", info] forState:UIControlStateNormal];
}

-(void)paymentSelected:(NSString*)info withIndex:(int)index {
    paymentIndex = index;
    [self.payment setTitle:[NSString stringWithFormat:@"Payment Type                %@", info] forState:UIControlStateNormal];
}

-(IBAction)createNewEvent:(id)sender {
    PFObject *event = [PFObject objectWithClassName:@"Event"];
    event[@"title"] = self.eName;
    event[@"description"] = self.eDescription;
    event[@"latitude"] = [NSString stringWithFormat:@"%f", self.eLatitude];
    event[@"longitude"] = [NSString stringWithFormat:@"%f", self.eLongitude];
    event[@"from"] = self.eStart;
    event[@"to"] = self.eEnd;
    event[@"category"] = categories[categoryIndex];
    event[@"privacy"] = privacys[privacyIndex];
    event[@"maximum"] = maximums[maximumIndex];
    event[@"payment"] = payments[paymentIndex];
    NSData *imageData = UIImagePNGRepresentation(self.eImage);
    PFFile *imageFile = [PFFile fileWithName:@"eventImage.png" data:imageData];
    event[@"image"] = imageFile;
    
    [event saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        [self.navigationController popToRootViewControllerAnimated:YES];
        
    }];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    SelectTableViewController *stvc = [segue destinationViewController];
    stvc.delegate = self;
    if ([[segue identifier] isEqualToString:@"Privacy"]) {
        stvc.navigationController.title = @"Privacy";
        stvc.selection = privacys;
        stvc.type = @"privacy";
    } else if ([[segue identifier] isEqualToString:@"Category"]) {
        stvc.navigationController.title = @"Category";
        stvc.selection = categories;
        stvc.type = @"category";
    } else if ([[segue identifier] isEqualToString:@"Maximum"]) {
        stvc.navigationController.title = @"Maximum";
        stvc.selection = maximums;
        stvc.type = @"maximum";
    } else if ([[segue identifier] isEqualToString:@"Payment"]) {
        stvc.navigationController.title = @"Payment";
        stvc.selection = payments;
        stvc.type = @"payment";
    }
    
}


@end
