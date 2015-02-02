//
//  NewEventViewController.m
//  Heyz
//
//  Created by Joshua Jiang on 2015-01-29.
//  Copyright (c) 2015 Teknowledge Software. All rights reserved.
//

#import "NewEventViewController.h"
#import <Parse/Parse.h>

@interface NewEventViewController () {
    NSArray *categoryData;
}

@end

@implementation NewEventViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    categoryData = @[@"Clubbing", @"Chat Time"];
    
    CGSize eventScrollContentSize = self.eventScrollView.frame.size;
    eventScrollContentSize.height = 752;
    self.eventScrollView.contentSize = eventScrollContentSize;
    
    self.eventScrollView.userInteractionEnabled = YES;
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapReceived:)];
    [tapGestureRecognizer setDelegate:self];
    [self.view addGestureRecognizer:tapGestureRecognizer];
    
    //Country Select
    CountryPicker *pickerView = [[CountryPicker alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    pickerView.showsSelectionIndicator = YES;
    pickerView.dataSource = self;
    pickerView.delegate = self;
    
    self.eventCountryLabel.frame = CGRectMake(0, 0, 0, 0);
    
    // set change the inputView (default is keyboard) to UIPickerView
    self.eventCountryLabel.inputView = pickerView;
    
    // add a toolbar with Cancel & Done button
    UIToolbar *toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    toolBar.barStyle = UIBarStyleBlackOpaque;
    
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneTouched:)];
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelTouched:)];
    
    // the middle button is to make the Done button align to right
    [toolBar setItems:[NSArray arrayWithObjects:cancelButton, [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil], doneButton, nil]];
    self.eventCountryLabel.inputAccessoryView = toolBar;
    
    
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

- (void)cancelTouched:(UIBarButtonItem *)sender
{
    // hide the picker view
    [self.eventCountryLabel resignFirstResponder];
    [self.eventFromLabel resignFirstResponder];
    [self.eventToLabel resignFirstResponder];
    [self.eventCategoryTextField resignFirstResponder];
}

- (void)doneTouched:(UIBarButtonItem *)sender
{
    // hide the picker view
    [self.eventCountryLabel resignFirstResponder];
    [self.eventFromLabel resignFirstResponder];
    [self.eventToLabel resignFirstResponder];
    [self.eventCategoryTextField resignFirstResponder];
    
    // perform some action
}

- (void)countryPicker:(__unused CountryPicker *)picker didSelectCountryWithName:(NSString *)name code:(NSString *)code
{
    self.eventCountryName.text = name;
}

-(void)tapReceived:(UITapGestureRecognizer *)tapGestureRecognizer
{
    [self.eventTitle resignFirstResponder];
    [self.eventLocation resignFirstResponder];
    [self.eventAddress resignFirstResponder];
    [self.eventCity resignFirstResponder];
    [self.eventTags resignFirstResponder];
    [self.eventCountryLabel resignFirstResponder];
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


- (IBAction)countrySelect:(id)sender {
    [self.eventCountryLabel becomeFirstResponder];
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



#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSLog(@"PUSHHHHHHHHH");
}


@end
