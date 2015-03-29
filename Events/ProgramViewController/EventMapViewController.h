//
//  EventMapViewController.h
//  Heyz
//
//  Created by Joshua Jiang on 2015-03-20.
//  Copyright (c) 2015 Teknowledge Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <Parse/Parse.h>

@interface EventMapViewController : UIViewController<MKMapViewDelegate>

@property (nonatomic, strong) MKMapView *mapView;
@property (nonatomic, strong) NSArray *eventList;

@end
