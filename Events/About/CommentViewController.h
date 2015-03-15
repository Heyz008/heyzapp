//
//  CommentViewController.h
//  Heyz
//
//  Created by Joshua Jiang on 2015-03-15.
//  Copyright (c) 2015 Teknowledge Software. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CommentViewController : UITableViewController

@property (nonatomic, strong) NSMutableArray *usernames;
@property (nonatomic, strong) NSMutableArray *comments;
@property (nonatomic, strong) NSMutableArray *times;
@property (nonatomic, strong) NSMutableArray *userPhotos;

@end
