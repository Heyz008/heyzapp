//
//  EventMapViewController.m
//  Heyz
//
//  Created by Joshua Jiang on 2015-03-20.
//  Copyright (c) 2015 Teknowledge Software. All rights reserved.
//

#import "EventMapViewController.h"
#import "LocationManager.h"
#import "MyAnnotation.h"

@interface EventMapViewController ()

@end

@implementation EventMapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.mapView = [[MKMapView alloc] initWithFrame:self.view.frame];
    self.mapView.delegate = self;
    [self.view addSubview:self.mapView];
    
    [self addLocationsOnMap];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    [LocationManager sharedInstance];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)addLocationsOnMap
{
    
    MKCoordinateRegion region;
    MKCoordinateSpan span;
    span.latitudeDelta=0.2;
    span.longitudeDelta=0.2;
    
    for (PFObject *event in self.eventList) {
        CLLocationCoordinate2D location =   CLLocationCoordinate2DMake([event[@"latitude"] doubleValue], [event[@"longitude"] doubleValue]);
        region.center = location;
        region.center.latitude  =   location.latitude;
        region.center.longitude =   location.longitude;
        region.span.longitudeDelta=0.04f;
        region.span.latitudeDelta=0.04f;
        
        [self.mapView setRegion:region animated:YES];
        MyAnnotation *ann=[[MyAnnotation alloc]init];
        ann.title   =   event[@"title"];
        ann.subtitle = event[@"description"];
        ann.coordinate=region.center;
        [self.mapView addAnnotation:ann];
        [self.mapView setRegion:region animated:YES];
    }
}

-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    if( annotation == mapView.userLocation )
    {
        return nil;
    }
    MyAnnotation *delegate = annotation;  //THIS CAST WAS WHAT WAS MISSING!
    MKPinAnnotationView *annView = nil;
    annView = (MKPinAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:@"eventloc"];
    if( annView == nil ){
        annView = [[MKPinAnnotationView alloc] initWithAnnotation:delegate reuseIdentifier:@"eventloc"];
    }
    
    annView.pinColor = MKPinAnnotationColorRed;
    annView.image = [UIImage imageNamed:@"1.jpg"];
    annView.animatesDrop=TRUE;
    annView.canShowCallout = YES;
    
    return annView;
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
