//
//  EventCell.h
//  Heyz
//
//  Created by Joshua Jiang on 2015-03-21.
//  Copyright (c) 2015 Teknowledge Software. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EventCell : UITableViewCell

@property (nonatomic,strong) IBOutlet UILabel *start;
@property (nonatomic,strong) IBOutlet UILabel *end;
@property (nonatomic,strong) IBOutlet UILabel *eventName;
@property (nonatomic,strong) IBOutlet UIView *seperator;

@end
