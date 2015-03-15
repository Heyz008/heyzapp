//
//  SelectTableViewController.h
//  Heyz
//
//  Created by Joshua Jiang on 2015-03-04.
//  Copyright (c) 2015 Teknowledge Software. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SelectTableViewControllerDelegate <NSObject>
@required
-(void)privacySelected:(NSString*)info withIndex:(int)index;
-(void)categorySelected:(NSString*)info withIndex:(int)index;
-(void)maximumSelected:(NSString*)info withIndex:(int)index;
-(void)paymentSelected:(NSString*)info withIndex:(int)index;

@end

@interface SelectTableViewController : UITableViewController

@property (strong, nonatomic) NSArray *selection;
@property (strong, nonatomic) NSString *type;
@property (nonatomic, weak) id<SelectTableViewControllerDelegate> delegate;

@end
