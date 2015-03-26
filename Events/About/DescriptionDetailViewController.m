//
//  DescriptionDetailViewController.m
//  Heyz
//
//  Created by Joshua Jiang on 2015-03-15.
//  Copyright (c) 2015 Teknowledge Software. All rights reserved.
//

#import "DescriptionDetailViewController.h"

@interface DescriptionDetailViewController ()

@end

@implementation DescriptionDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.textView.text = self.eventDescription;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
