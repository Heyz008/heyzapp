//
//  QRViewController.h
//  Heyz
//
//  Created by Joshua Jiang on 2015-03-22.
//  Copyright (c) 2015 Teknowledge Software. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QRViewController : UIViewController

@property (nonatomic, strong) NSString *eventName;

@property (nonatomic, strong) IBOutlet UIImageView *qrImageView;
@property (nonatomic, strong) IBOutlet UILabel *qrLabel;

@end
