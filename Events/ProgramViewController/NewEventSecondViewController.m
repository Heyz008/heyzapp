//
//  NewEventSecondViewController.m
//  Heyz
//
//  Created by Joshua Jiang on 2015-03-04.
//  Copyright (c) 2015 Teknowledge Software. All rights reserved.
//

#import "NewEventSecondViewController.h"
#import "SelectTableViewController.h"

@interface NewEventSecondViewController ()

@end

@implementation NewEventSecondViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
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
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    SelectTableViewController *stvc = [segue destinationViewController];
    if ([[segue identifier] isEqualToString:@"Privacy"]) {
        stvc.navigationController.title = @"Privacy";
        stvc.selection = @[@"Public", @"Friends Only", @"Strangers Only", @"Invite Only"];
    } else if ([[segue identifier] isEqualToString:@"Category"]) {
        stvc.navigationController.title = @"Category";
        stvc.selection = @[@"Clubbing", @"Chat Time", @"Concert", @"Coffee"];
    } else if ([[segue identifier] isEqualToString:@"Maximum"]) {
        stvc.navigationController.title = @"Maximum";
        stvc.selection = @[@"Unlimited", @"1 - 10", @"11 - 100", @"101 - 1000"];
    } else if ([[segue identifier] isEqualToString:@"Payment"]) {
        stvc.navigationController.title = @"Payment";
        stvc.selection = @[@"Free", @"AA", @"你请客", @"我请客"];
    }
    
}


@end
