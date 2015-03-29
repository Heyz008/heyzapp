//
//  ActivityRequestCell.h
//  Heyz
//
//  Created by Joshua Jiang on 2015-03-29.
//  Copyright (c) 2015 Teknowledge Software. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ActivityRequestCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UIImageView *photo;
@property (nonatomic, strong) IBOutlet UILabel *activity;
@property (nonatomic, strong) IBOutlet UIButton *acceptButton;
@property (nonatomic, strong) IBOutlet UIButton *rejectButton;
@property (nonatomic, strong) IBOutlet UILabel *status;

@end
