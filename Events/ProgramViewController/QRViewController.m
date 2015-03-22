//
//  QRViewController.m
//  Heyz
//
//  Created by Joshua Jiang on 2015-03-22.
//  Copyright (c) 2015 Teknowledge Software. All rights reserved.
//

#import "QRViewController.h"
#import "UIImage+MDQRCode.h"

@interface QRViewController ()

@end

@implementation QRViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.qrLabel.text = self.eventName;
    self.qrImageView.image = [UIImage mdQRCodeForString:self.eventName size:self.qrImageView.bounds.size.width fillColor:[UIColor darkGrayColor]];
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
