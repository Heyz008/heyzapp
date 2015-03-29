//
//  WhoIsGoingViewController.h
//  Heyz
//
//  Created by Joshua Jiang on 2015-03-15.
//  Copyright (c) 2015 Teknowledge Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WhoIsGoingView.h"

@interface WhoIsGoingViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) IBOutlet UITableView *userTableView;
@property (nonatomic, strong) IBOutlet UIImageView *userImageView;
@property (nonatomic, strong) IBOutlet WhoIsGoingView *connectionView;

@property (nonatomic, strong) NSArray *usernames;
@property (nonatomic, strong) NSArray *userImages;
@property (nonatomic, strong) UIImage *eventImage;

@end
