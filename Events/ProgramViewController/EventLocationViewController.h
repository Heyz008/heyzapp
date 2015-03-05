//
//  EventLocationViewController.h
//  Heyz
//
//  Created by Joshua Jiang on 2015-02-27.
//  Copyright (c) 2015 Teknowledge Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@protocol EventLocationDelegate <NSObject>
@required
-(void)locationSeleted:(NSString*)location;

@end

@interface EventLocationViewController : UIViewController<UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, CLLocationManagerDelegate>{
    id <EventLocationDelegate> locationDelegate;
}

@property (strong, nonatomic) IBOutlet UITextField *userInput;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, assign) id<EventLocationDelegate> locationDelegate;

@end
