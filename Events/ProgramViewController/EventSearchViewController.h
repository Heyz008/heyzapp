//
//  EventSearchViewController.h
//  Heyz
//
//  Created by Joshua Jiang on 2015-03-20.
//  Copyright (c) 2015 Teknowledge Software. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EventSearchViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic,strong) IBOutlet UITableView *tableView;
@property (nonatomic,strong) IBOutlet UITableView *userTableView;
@property (nonatomic,strong) NSArray *categories;
@property (nonatomic,strong) NSArray *usernames;
@property (nonatomic,strong) NSArray *photos;
@property (nonatomic,strong) IBOutlet UISegmentedControl *seg;

-(IBAction)changeSeg;

@end
