//
//  EventLocationViewController.h
//  Heyz
//
//  Created by Joshua Jiang on 2015-02-27.
//  Copyright (c) 2015 Teknowledge Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@protocol EventLocationViewControllerDelegate <NSObject>
@required
-(void)locationSeleted:(NSString*)location latitude:(CGFloat)latitude longitude:(CGFloat)longitude;

@end

@interface EventLocationViewController : UIViewController<UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate, UISearchBarDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, weak) id<EventLocationViewControllerDelegate> delegate;
@property (nonatomic, strong) IBOutlet UISearchBar *searchBar;

@end
