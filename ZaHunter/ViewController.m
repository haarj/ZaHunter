//
//  ViewController.m
//  ZaHunter
//
//  Created by Justin Haar on 3/25/15.
//  Copyright (c) 2015 Justin Haar. All rights reserved.
//

#import "ViewController.h"
#import "MapViewController.h"
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>


@interface ViewController () <UITableViewDataSource, UITableViewDelegate, CLLocationManagerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property CLLocationManager *locationManager;
@property NSArray *results;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addAnnotationForAddress:@"Sushi"];

    //Alloc init! Or it doesnt exist
    self.locationManager = [CLLocationManager new];

    //first set the delegate of our CLLocationManager instance
    self.locationManager.delegate = self;

    //call the method startUpdatingLocation
    //this will begin calling our delegate method
    [self.locationManager startUpdatingLocation];

    //Get permission (this also requires the plist key)
    [self.locationManager requestWhenInUseAuthorization];
}

//here's our delegate method that gets called whenever our location manager instance updates our location
//it provides with two things: the instance of CLLocationManager who triggered it
//and also, the location (or locations)
//these two things are provided as parameters of this delegate method (which we can reference with the names "manager" and "locations"
-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    for (CLLocation *location in locations) {
        if (location.verticalAccuracy < 1000 && location.horizontalAccuracy < 1000) {
            [self reverseGeocodeLocation:location];
            [self.locationManager stopUpdatingLocation];
        }
    }
}


//HELPER METHOD TO REVERSE GEOCODE BASED ON OUR LOCATION AND DISPLAY PROPERTIES ABOUT MY LOCATION
-(void)reverseGeocodeLocation:(CLLocation *)location
{
    CLGeocoder *geocoder = [CLGeocoder new];
    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error)
     {
         CLPlacemark *placemark = [placemarks objectAtIndex:0];
         MKPointAnnotation *pin = [[MKPointAnnotation alloc]init];
         pin.coordinate = placemark.location.coordinate;
         pin.title = placemark.name;
         [self findSushiNear:location];
     }];
}

-(void)findSushiNear:(CLLocation *)location
{
    MKLocalSearchRequest *request = [MKLocalSearchRequest new];
    request.naturalLanguageQuery = @"Sushi";
    request.region = MKCoordinateRegionMake(location.coordinate, MKCoordinateSpanMake(1.0, 1.0));
    MKLocalSearch *search = [[MKLocalSearch alloc]initWithRequest:request];
    [search startWithCompletionHandler:^(MKLocalSearchResponse *response, NSError *error) {
        MKMapItem *mapItem = [response.mapItems objectAtIndex:0];
        [self pullDirectionsWithMapItem:mapItem];
    }];

}

-(void)pullDirectionsWithMapItem:(MKMapItem *)mapItem
{
    MKDirectionsRequest *request = [MKDirectionsRequest new];
    request.source = [MKMapItem mapItemForCurrentLocation];
    request.destination = mapItem;
    MKDirections *direction = [[MKDirections alloc]initWithRequest:request];
    [direction calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error)
     {
         NSArray *routes = response.routes;
         MKRoute *theRoute = [routes objectAtIndex:0];
         NSMutableString *stepString = [NSMutableString new];
         int stepCount = 1;

         for (MKRouteStep *step in theRoute.steps) {
             [stepString appendFormat:@"%i %@\n", stepCount, step.instructions];
         }
         self.textView.text = stepString;
     }];
}

-(void)addAnnotationForAddress:(NSString *)address
{
    CLGeocoder *geoCoder = [[CLGeocoder alloc]init];
    [geoCoder geocodeAddressString:address completionHandler:^(NSArray *placemarks, NSError *error) {
        NSLog(@"%@", error.localizedDescription);
        CLPlacemark *placemark = [placemarks objectAtIndex:0];
        MKPointAnnotation *pin = [[MKPointAnnotation alloc]init];
        pin.coordinate = placemark.location.coordinate;
        pin.title = placemark.name;
//        [self.mapView addAnnotation:pin];
    }];
}


#pragma MARK TABLE VIEW DELGATE METHODS

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellID"];
    MKMapItem *mapItem = [self.results objectAtIndex:indexPath.row];
    cell.textLabel.text = mapItem.name;
    return cell;
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 4;
}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqual:@"Map"]) {
        MapViewController *mapVC = segue.destinationViewController;
        mapVC.results = self.results;
    }
}


@end



