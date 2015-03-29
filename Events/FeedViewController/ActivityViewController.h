//
//  ActivityViewController.h
//  Heyz
//
//  Created by Joshua Jiang on 2015-03-29.
//  Copyright (c) 2015 Teknowledge Software. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ActivityViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) IBOutlet UISegmentedControl *segment;

-(IBAction)segmentChanged:(id)sender;

@end
