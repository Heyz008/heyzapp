//
//  EventLocationViewController.m
//  Heyz
//
//  Created by Joshua Jiang on 2015-02-27.
//  Copyright (c) 2015 Teknowledge Software. All rights reserved.
//

#import "EventLocationViewController.h"
#import "ASIHTTPRequest.h"
#import "SBJSON.h"
#import "LocationCell.h"
#import "NSString+FontAwesome.h"

@interface EventLocationViewController () {
    double longitude;
    double latitude;
    
    NSMutableArray *places;
    NSMutableArray *placeIds;
    
    double selectedLatitude;
    double selectedLongitude;
}

@end

@implementation EventLocationViewController

- (void)viewDidLoad {

    longitude = -79.4000;
    latitude = 43.7000;
    
    places = [NSMutableArray arrayWithArray:@[@"University of Toronto", @"Chat Time Dundas", @"Guu Izakaya", @"Yorkdale Shopping Center", @"Lake of Ontario"]];
    placeIds = [NSMutableArray arrayWithArray:@[]];
    
    self.searchBar.delegate = self;
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
}


- (void)requestFinished:(ASIHTTPRequest *)request
{
    if (request.tag == 11) {
        places = [NSMutableArray arrayWithArray:@[]];
        placeIds = [NSMutableArray arrayWithArray:@[]];
        //NSLog(@"%@", request.responseString);
        SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
        NSDictionary *responseDict = [jsonParser objectWithString:request.responseString];
        NSArray *predictions = [responseDict objectForKey:@"predictions"];
        for (NSDictionary *dic in predictions) {
            [places addObject:[dic objectForKey:@"description"]];
            [placeIds addObject:[dic objectForKey:@"place_id"]];
        }
        [self.tableView reloadData];
    } else if (request.tag == 22) {
        SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
        NSDictionary *responseDict = [jsonParser objectWithString:request.responseString];
        NSDictionary *location = [responseDict objectForKey:@"result"][@"geometry"][@"location"];
        selectedLatitude = [location[@"lat"] doubleValue];
        selectedLongitude = [location[@"lng"] doubleValue];
        if ([_delegate respondsToSelector:@selector(locationSeleted:latitude:longitude:)]) {
            [_delegate locationSeleted:self.searchBar.text latitude:selectedLatitude longitude:selectedLongitude];
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
    
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


- (BOOL)searchBar:(UISearchBar *)searchBar shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    NSString *allText = [searchBar.text stringByAppendingString:text];
    allText = [allText stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    NSString *url = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/autocomplete/json?input=%@&location=%f,%f&radius=12000&key=AIzaSyCIctGj9IUky-uH1nSWdjY8XxSW05tvChA", allText, latitude, longitude];
    if ([allText length] > 3) {
        ASIFormDataRequest *request = [[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString:url]];
        request.tag = 11;
        [request setDelegate:self];
        [request startAsynchronous];
    }
    
    return YES;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger) section {
    return [places count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    LocationCell *cell = nil;
    static NSString *locationCell = @"LocationCell";
    cell = [tableView dequeueReusableCellWithIdentifier:locationCell];
    if (cell == nil) {
        cell = (LocationCell*)[[UITableViewCell alloc]
                initWithStyle:UITableViewCellStyleDefault reuseIdentifier:locationCell];
    }
    
    cell.location.font = [UIFont fontWithName:kFontAwesomeFamilyName size:12];
    cell.location.text = [NSString stringWithFormat:@"%@  %@", [NSString fontAwesomeIconStringForIconIdentifier:@"fa-map-marker"], [places objectAtIndex:indexPath.row]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.searchBar.text = [places objectAtIndex:indexPath.row];
    
    NSString *url = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/details/json?placeid=%@&key=AIzaSyCIctGj9IUky-uH1nSWdjY8XxSW05tvChA", [placeIds objectAtIndex:indexPath.row]];
    ASIFormDataRequest *request = [[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString:url]];
    request.tag = 22;
    [request setDelegate:self];
    [request startAsynchronous];
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

@end
