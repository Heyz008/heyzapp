//
//  NewEventViewController.m
//  Heyz
//
//  Created by Joshua Jiang on 2015-01-29.
//  Copyright (c) 2015 Teknowledge Software. All rights reserved.
//

#import "NewEventViewController.h"
#import <Parse/Parse.h>
#import "MyAnnotation.h"
#import "ASIHTTPRequest.h"
#import "SBJSON.h"

@interface NewEventViewController () {
    NSArray *categoryData;
    double longitude;
    double latitude;
    NSMutableArray *places;
    NSMutableArray *latitudes;
    NSMutableArray *longitudes;
}

@end

@implementation NewEventViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    categoryData = @[@"Clubbing", @"Chat Time"];
    places = [NSMutableArray arrayWithArray:@[]];
    
    self.eventAddress.tag = 99;
    self.eventAddress.delegate = self;
    
    self.addressTable.hidden = YES;
    
    
    CGSize eventScrollContentSize = self.eventScrollView.frame.size;
    eventScrollContentSize.height = 850;
    self.eventScrollView.contentSize = eventScrollContentSize;
    
    self.eventScrollView.userInteractionEnabled = YES;
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapReceived:)];
    tapGestureRecognizer.cancelsTouchesInView = NO;
    [tapGestureRecognizer setDelegate:self];
    [self.view addGestureRecognizer:tapGestureRecognizer];
    
    // add a toolbar with Cancel & Done button
    UIToolbar *toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    toolBar.barStyle = UIBarStyleBlackOpaque;
    
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneTouched:)];
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelTouched:)];
    
    // the middle button is to make the Done button align to right
    [toolBar setItems:[NSArray arrayWithObjects:cancelButton, [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil], doneButton, nil]];
    
    
    //From date select
    UIDatePicker *fromPickerView = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    fromPickerView.tag = 11;
    UIDatePicker *toPickerView = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    toPickerView.tag = 22;
    self.eventFromLabel.frame = CGRectMake(0, 0, 0, 0);
    
    [fromPickerView addTarget:self action:@selector(datePickerChanged:) forControlEvents:UIControlEventValueChanged];
    [toPickerView addTarget:self action:@selector(datePickerChanged:) forControlEvents:UIControlEventValueChanged];
    
    // set change the inputView (default is keyboard) to UIPickerView
    self.eventFromLabel.inputView = fromPickerView;
    self.eventToLabel.inputView = toPickerView;
    self.eventFromLabel.inputAccessoryView = toolBar;
    self.eventToLabel.inputAccessoryView = toolBar;
    
    
    //Category Picker
    UIPickerView *categoryPicker = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    self.eventCategoryTextField.inputView = categoryPicker;
    self.eventCategoryTextField.inputAccessoryView = toolBar;
    categoryPicker.dataSource = self;
    categoryPicker.delegate = self;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(setOurImage:)
                                                 name:@"OUR IMAGE SELECTED" object:nil];
    
    longitude = -79.4000;
    latitude = 43.7000;
    
    CLLocationManager *locationManager = [[CLLocationManager alloc] init];
    
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    [locationManager startUpdatingLocation];
    
}

-(void)setOurImage:(NSNotification *)notice {
    
    NSString *selectedImage = [notice object];
    self.eventImage.image = [UIImage imageNamed:selectedImage];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

// The number of rows of data
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return categoryData.count;
}

// The data to return for the row and component (column) that's being passed in
- (NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return categoryData[row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    self.eventCategoryLabel.text = categoryData[row];
}

- (void)datePickerChanged:(UIDatePicker *)datePicker
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    NSString *strDate = [dateFormatter stringFromDate:datePicker.date];
    if (datePicker.tag == 11) {
        self.eventFromName.text = strDate;
    } else if (datePicker.tag == 22) {
        self.eventToName.text = strDate;
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (textField.tag == 99) {
        NSString *allText = [textField.text stringByAppendingString:string];
        NSLog(@"%f, %f", latitude, longitude);
        allText = [allText stringByReplacingOccurrencesOfString:@" " withString:@"+"];
        NSString *url = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/autocomplete/json?input=%@&location=%f,%f&radius=12000&key=AIzaSyCIctGj9IUky-uH1nSWdjY8XxSW05tvChA", allText, latitude, longitude];
        if ([allText length] > 3) {
            ASIFormDataRequest *request = [[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString:url]];;
            [request setDelegate:self];
            [request startAsynchronous];
        }
    }
    return YES;
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError: %@", error);
    UIAlertView *errorAlert = [[UIAlertView alloc]
                               initWithTitle:@"Error" message:@"Failed to Get Your Location" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [errorAlert show];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    NSLog(@"didUpdateToLocation: %@", newLocation);
    CLLocation *currentLocation = newLocation;
    
    if (currentLocation != nil) {
        longitude = currentLocation.coordinate.longitude;
        latitude = currentLocation.coordinate.latitude;
    }
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    self.addressTable.hidden = NO;
    places = [NSMutableArray arrayWithArray:@[]];
    NSLog(@"%@", request.responseString);
    SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
    NSDictionary *responseDict = [jsonParser objectWithString:request.responseString];
    NSArray *predictions = [responseDict objectForKey:@"predictions"];
    for (NSDictionary *dic in predictions) {
        [places addObject:[dic objectForKey:@"description"]];
    }
    [self.addressTable reloadData];
    
//    self.searchResults = [@[] mutableCopy];
//    [self.collectionView reloadData];
//    [MBProgressHUD hideHUDForView:self.view animated:YES];
//    if (request.responseStatusCode == 200) {
//        NSString *responseString = [request responseString];
//        if (![MyUtil isLocal]) {
//            NSArray *chunks = [responseString componentsSeparatedByString: @"\n"];
//            responseString = [chunks objectAtIndex:0];
//        }
//        for (NSString* key in responseDict) {
//            if (![key isEqualToString:@"9"]) {
//                NSString *value = [responseDict valueForKey:key];
//                NSDictionary *sectionDict = [jsonParser objectWithString:value error:&error];
//                NSMutableArray *sectionImages = [self getSectionImages:sectionDict];
//                [self.searchResults addObject:sectionImages];
//            }
//        }
//        [self.collectionView reloadData];
//    } else {
//        [self showTextView:@"图片搜索失败"];
//    }
    
}

//- (void)requestFailed:(ASIHTTPRequest *)request
//{
//    [MBProgressHUD hideHUDForView:self.view animated:YES];
//    NSError *error = [request error];
//    [self showTextView:error.localizedDescription];
//}

- (void)cancelTouched:(UIBarButtonItem *)sender
{
    // hide the picker view
    [self.eventFromLabel resignFirstResponder];
    [self.eventToLabel resignFirstResponder];
    [self.eventCategoryTextField resignFirstResponder];
}

- (void)doneTouched:(UIBarButtonItem *)sender
{
    // hide the picker view
    [self.eventFromLabel resignFirstResponder];
    [self.eventToLabel resignFirstResponder];
    [self.eventCategoryTextField resignFirstResponder];
    
    // perform some action
}


-(void)tapReceived:(UITapGestureRecognizer *)tapGestureRecognizer
{
    [self.eventTitle resignFirstResponder];
    [self.eventLocation resignFirstResponder];
    [self.eventAddress resignFirstResponder];
    [self.eventTags resignFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)cancleButtonTapped:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (IBAction)createEvent:(id)sender {
    PFObject *event = [PFObject objectWithClassName:@"Event"];
    event[@"title"] = self.eventTitle.text;
    event[@"description"] = self.eventDescription.text;
    event[@"location"] = self.eventLocation.text;
    event[@"address"] = self.eventAddress.text;
    event[@"from"] = self.eventFromName.text;
    event[@"to"] = self.eventToName.text;
    event[@"tag"] = self.eventTags.text;
    event[@"category"] = self.eventCategoryLabel.text;
    NSData *imageData = UIImagePNGRepresentation(self.eventImage.image);
    PFFile *imageFile = [PFFile fileWithName:@"eventImage.png" data:imageData];
    event[@"image"] = imageFile;
    
    [event saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        NSLog(@"Event SUcceed? ");
        NSLog(@"Error: %@", error.description);
        
    }];
}

- (IBAction)fromSelect:(id)sender {
    [self.eventFromLabel becomeFirstResponder];
}

- (IBAction)toSelect:(id)sender {
    [self.eventToLabel becomeFirstResponder];
}

- (IBAction)categorySelect:(id)sender {
    [self.eventCategoryTextField becomeFirstResponder];
}

- (IBAction)photoSelect:(id)sender {
    UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    UIImagePickerController * picker = [[UIImagePickerController alloc]init];
    picker.delegate = self;
    picker.allowsEditing=YES;
    picker.sourceType = sourceType;
    [self presentViewController:picker animated:YES completion:nil];
}

-(void)imagePickerController:(UIImagePickerController*)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:YES completion:nil];
    UIImage *editedImage = [info objectForKey:UIImagePickerControllerEditedImage];
    self.eventImage.image = editedImage;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger) section {
    return [places count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = nil;
    static NSString *AutoCompleteRowIdentifier = @"AutoCompleteRowIdentifier";
    cell = [tableView dequeueReusableCellWithIdentifier:AutoCompleteRowIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]
                 initWithStyle:UITableViewCellStyleDefault reuseIdentifier:AutoCompleteRowIdentifier];
    }
    
    cell.textLabel.text = [places objectAtIndex:indexPath.row];
    cell.textLabel.font = [UIFont systemFontOfSize:11];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.addressTable.hidden = YES;
    self.eventAddress.text = [places objectAtIndex:indexPath.row];
}


//-(void)addLocationPinOnMap
//{
//    self.eventLocationMapView.delegate = (id)self;
//    
//    MKCoordinateRegion region;
//    MKCoordinateSpan span;
//    span.latitudeDelta=0.2;
//    span.longitudeDelta=0.2;
//    
//    CLLocationCoordinate2D location =   CLLocationCoordinate2DMake([self.eventObj.eventLocationLatitude doubleValue], [self.eventObj.eventLocationLongitude doubleValue]);
//    
//    region.center = location;
//    region.center.latitude  =   location.latitude;
//    region.center.longitude =   location.longitude;
//    region.span.longitudeDelta=0.04f;
//    region.span.latitudeDelta=0.04f;
//    
//    [self.eventLocationMapView setRegion:region animated:YES];
//    MyAnnotation *ann=[[MyAnnotation alloc]init];
//    ann.title   =   self.eventObj.eventName;
//    ann.subtitle=@"";
//    ann.coordinate=region.center;
//    [self.eventLocationMapView addAnnotation:ann];
//    [self.eventLocationMapView setRegion:region animated:YES];
//}
//
//#pragma mark - MapView Delegates
//-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
//{
//    if( annotation == mapView.userLocation )
//    {
//        return nil;
//    }
//    MyAnnotation *delegate = annotation;  //THIS CAST WAS WHAT WAS MISSING!
//    MKPinAnnotationView *annView = nil;
//    annView = (MKPinAnnotationView*)[self.eventLocationMapView dequeueReusableAnnotationViewWithIdentifier:@"eventloc"];
//    if( annView == nil ){
//        annView = [[MKPinAnnotationView alloc] initWithAnnotation:delegate reuseIdentifier:@"eventloc"];
//    }
//    
//    annView.pinColor = MKPinAnnotationColorGreen;
//    annView.animatesDrop=TRUE;
//    annView.canShowCallout = YES;
//    
//    return annView;
//}



#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
}


@end
