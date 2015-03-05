//
//  NewEventViewController.m
//  Heyz
//
//  Created by Joshua Jiang on 2015-01-29.
//  Copyright (c) 2015 Teknowledge Software. All rights reserved.
//

#import "EventLocationViewController.h"
#import "NewEventViewController.h"
#import <Parse/Parse.h>
#import "MyAnnotation.h"
#import "ASIHTTPRequest.h"
#import "SBJSON.h"
#import "M13Checkbox.h"
#import "AccordionView.h"

@interface NewEventViewController ()<EventLocationDelegate> {
    NSArray *categoryData;
    double longitude;
    double latitude;
    NSMutableArray *places;
    NSMutableArray *placeIds;
    double selectedLatitude;
    double selectedLongitude;
}

@end

@implementation NewEventViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    CGFloat fieldOriginX = self.eventName.frame.origin.x;
    CGFloat fieldWidth = self.eventName.frame.size.width;
    CGFloat fieldHeight = self.eventName.frame.size.height;
    
    M13Checkbox *checkBox = [[M13Checkbox alloc] initWithTitle:@"This is an online event"];
    checkBox.titleLabel.font = [UIFont systemFontOfSize:14];
    checkBox.strokeColor = [UIColor blackColor];
    checkBox.checkColor = [UIColor blackColor];
    [checkBox setCheckAlignment:M13CheckboxAlignmentLeft];
    checkBox.frame = CGRectMake(fieldOriginX, self.eventLocationButton.frame.origin.y + self.eventLocationButton.frame.size.height + 6, fieldWidth, 14);
    [self.eventScrollView addSubview:checkBox];
    
    
    AccordionView *accordion = [[AccordionView alloc] initWithFrame:CGRectMake(fieldOriginX, checkBox.frame.origin.y + checkBox.frame.size.height + 15, fieldWidth, 300)];
    
    [self.eventScrollView addSubview:accordion];
    
    
    self.startDate = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 0, fieldHeight)];
    self.startDate.backgroundColor = [UIColor whiteColor];
    [self.startDate setTitle:@" Starts" forState:UIControlStateNormal];
    self.startDate.titleLabel.textAlignment = UIControlContentHorizontalAlignmentLeft;
    self.startDate.titleLabel.font = [UIFont systemFontOfSize:14];
    [self.startDate setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    self.startDate.layer.borderColor = [UIColor blackColor].CGColor;
    self.startDate.layer.borderWidth = 1.0f;
    
    UIDatePicker *view2 = [[UIDatePicker alloc] init];
    view2.backgroundColor = [UIColor whiteColor];
    view2.tag = 1;
    [view2 addTarget:self action:@selector(dateChanged:) forControlEvents:UIControlEventValueChanged];
    [accordion addHeader:self.startDate withView:view2];
    
    
    self.endDate = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 0, fieldHeight)];
    [self.endDate setTitle:@" Ends" forState:UIControlStateNormal];
    self.endDate.backgroundColor = [UIColor whiteColor];
    self.endDate.titleLabel.font = [UIFont systemFontOfSize:14];
    self.endDate.titleLabel.textAlignment = UIControlContentHorizontalAlignmentLeft;
    self.endDate.layer.borderColor = [UIColor blackColor].CGColor;
    [self.endDate setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    self.endDate.layer.borderWidth = 1.0f;
    
    UIDatePicker *view3 = [[UIDatePicker alloc] init];
    view3.backgroundColor = [UIColor whiteColor];
    view3.tag = 2;
    [view3 addTarget:self action:@selector(dateChanged:) forControlEvents:UIControlEventValueChanged];
    [accordion addHeader:self.endDate withView:view3];
    [accordion setAllowsEmptySelection:YES];
    
    [accordion setNeedsLayout];
    
    EventLocationViewController *el = [[EventLocationViewController alloc] init];
    el.locationDelegate = self;
    
    places = [NSMutableArray arrayWithArray:@[]];
    placeIds = [NSMutableArray arrayWithArray:@[]];
    
    self.eventLocationButton.layer.borderColor = [UIColor blackColor].CGColor;
    self.eventLocationButton.layer.borderWidth = 1.0f;
    
    longitude = -79.4000;
    latitude = 43.7000;
    
    CLLocationManager *locationManager = [[CLLocationManager alloc] init];
    
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    [locationManager startUpdatingLocation];
    
    self.uploadButton.userInteractionEnabled = YES;
    
}

- (IBAction)photoButtonTapped:(id)sender {
    
    NSLog(@"yyg");
//    UIActionSheet *popup = [[UIActionSheet alloc] initWithTitle:@"Select Sharing option:" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:
//                            @"Share on Facebook",
//                            @"Share on Twitter",
//                            @"Share via E-mail",
//                            @"Save to Camera Roll",
//                            @"Rate this App",
//                            nil];
//    popup.tag = 1;
//    [popup showInView:[UIApplication sharedApplication].keyWindow];
}

- (void)actionSheet:(UIActionSheet *)popup clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    switch (popup.tag) {
        case 1: {
            switch (buttonIndex) {
                default:
                    break;
            }
            break;
        }
        default:
            break;
    }
}

- (IBAction)cancleButtonTapped:(id)sender {
    NSLog(@"def");
}

- (void)locationSeleted: (NSString *)location {
    NSLog(@"lllocation: %@", location);
    [self.eventLocationButton setTitle:location forState:UIControlStateNormal];
}

- (void)dateChanged:(UIDatePicker *)datePicker
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    NSString *strDate = [dateFormatter stringFromDate:datePicker.date];
    if (datePicker.tag == 1) {
        [self.startDate setTitle:[NSString stringWithFormat:@" Starts            %@", strDate] forState:UIControlStateNormal];
    } else if (datePicker.tag == 2) {
        [self.endDate setTitle:[NSString stringWithFormat:@" Ends            %@", strDate] forState:UIControlStateNormal];
    }
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
}


@end
