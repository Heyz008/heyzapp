//
//  NewEventViewController.h
//  Heyz
//
//  Created by Joshua Jiang on 2015-01-29.
//  Copyright (c) 2015 Teknowledge Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface NewEventViewController : UIViewController<UIPickerViewDataSource, UIPickerViewDelegate, UIImagePickerControllerDelegate, MKMapViewDelegate, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, CLLocationManagerDelegate>

@property (strong, nonatomic) IBOutlet UIBarButtonItem *cancelButton;
@property (strong, nonatomic) IBOutlet UIScrollView *eventScrollView;
@property (retain, nonatomic) IBOutlet UITextField *eventTitle;
@property (strong, nonatomic) IBOutlet UITextField *eventLocation;
@property (strong, nonatomic) IBOutlet UIButton *eventCreateButton;

@property (strong, nonatomic) IBOutlet UITextView *eventDescription;
@property (strong, nonatomic) IBOutlet UITextField *eventAddress;
@property (strong, nonatomic) IBOutlet UIButton *eventFromButton;
@property (strong, nonatomic) IBOutlet UILabel *eventFromName;
@property (strong, nonatomic) IBOutlet UITableView *addressTable;
@property (strong, nonatomic) IBOutlet UIButton *eventToButton;
@property (strong, nonatomic) IBOutlet UILabel *eventToName;
@property (strong, nonatomic) IBOutlet UITextField *eventFromLabel;
@property (strong, nonatomic) IBOutlet UITextField *eventToLabel;
@property (strong, nonatomic) IBOutlet UITextField *eventTags;
@property (strong, nonatomic) IBOutlet UILabel *eventCategoryLabel;
@property (strong, nonatomic) IBOutlet UIButton *eventCategoryButton;
@property (strong, nonatomic) IBOutlet UITextField *eventCategoryTextField;
@property (strong, nonatomic) IBOutlet UIButton *eventPhotoButton;
@property (strong, nonatomic) IBOutlet UIButton *eventOurPhotoButton;
@property (strong, nonatomic) IBOutlet UIImageView *eventImage;
@property (strong, nonatomic) IBOutlet MKMapView *eventLocationMapView;

@property (nonatomic, copy) NSString *selectedOurImage;

- (IBAction)cancleButtonTapped:(id)sender;
- (IBAction)createEvent:(id)sender;
- (IBAction)countrySelect:(id)sender;
- (IBAction)fromSelect:(id)sender;
- (IBAction)toSelect:(id)sender;
- (IBAction)categorySelect:(id)sender;
- (IBAction)photoSelect:(id)sender;

@end
