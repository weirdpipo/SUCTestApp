//
//  ViewController.m
//  SUCTestApp
//
//  Created by Phillipe Casorla Sagot on 2/28/13.
//  Copyright (c) 2013 Phillipe Casorla Sagot. All rights reserved.
//

#import "FoursquareViewController.h"
#import "LocationManager.h"
#import "AddressAnnotation.h"
#import "SMCalloutView.h"
#import "FoursquareVenue.h"
#import "AsyncImageView.h"
@interface FoursquareViewController ()

@end
//basic constant size for the default region
static const int REGION_SIZE = 2000;
@implementation FoursquareViewController{
    //our callout view, we reused it everytime
    SMCalloutView *calloutView;
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if(self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        //The NotificationCenter is a useful singleton that enables loosely coupled communications between views, controllers or services
        //notification to receive the users location
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveLocation:) name:kLocationChangedNotification object:nil];
        //notification to receive foursquare places
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveRestaurants:) name:kFQLoadedNotification object:nil];
        calloutView = [SMCalloutView new];
        //init our custom callout view
        annotationViewController = [[FoursquareAnnotationViewController alloc] initWithNibName:@"FoursquareAnnotationView" bundle:nil];
    }
    return self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [_mapView setShowsUserLocation:YES];

}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark Notifications
-(void)didReceiveLocation:(NSNotification*) notification{
    CLLocation *currentLocation = (CLLocation*)notification.object;
    CLLocationCoordinate2D coord = currentLocation.coordinate;
    [_mapView setCenterCoordinate:coord animated:YES];
    // Zoom the region to the current user location
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(coord, REGION_SIZE, REGION_SIZE);
    [_mapView setRegion:region animated:YES];
    
}
-(void)didReceiveRestaurants:(NSNotification*) notification{
    //add all fousquare places to the map, remove current ones
    [self removeAllAnnotationExceptOfCurrentUser];
    LocationManager *lManager = [LocationManager sharedLocationBoss];
    [self.mapView addAnnotations:lManager.currentVenues];
}
-(void)removeAllAnnotationExceptOfCurrentUser
{
    //remove all current annotations in the map except the current user
    NSMutableArray *annForRemove = [[NSMutableArray alloc] initWithArray:self.mapView.annotations];
    if ([self.mapView.annotations.lastObject isKindOfClass:[MKUserLocation class]]) {
        [annForRemove removeObject:self.mapView.annotations.lastObject];
    }else{
        for (id <MKAnnotation> annot_ in self.mapView.annotations)
        {
            if ([annot_ isKindOfClass:[MKUserLocation class]] ) {
                [annForRemove removeObject:annot_];
                break;
            }
        }
    }
    
    
    [self.mapView removeAnnotations:annForRemove];
}
#pragma mark Buttons Events
- (IBAction)locateMe:(id)sender {
    //move the map to current location 
    LocationManager *lManager = [LocationManager sharedLocationBoss];
    if (lManager.running) {
        CLLocationCoordinate2D coord = [lManager currentLocation].coordinate;
        [_mapView setCenterCoordinate:coord animated:YES];
        // Zoom the region to this location
        MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(coord, REGION_SIZE, REGION_SIZE);
        [_mapView setRegion:region animated:YES];
    } else {
        [lManager restartService];
    }
}

- (IBAction)gotoNYC:(id)sender {
    //move the map to NYC 
    CLLocationCoordinate2D coord = CLLocationCoordinate2DMake(40.739661,-74.001042);//random location in NYC
    [_mapView setCenterCoordinate:coord animated:YES];
    // Zoom the region to this location
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(coord, REGION_SIZE, REGION_SIZE);
    [_mapView setRegion:region animated:YES];
    //add pin
    AddressAnnotation *addAnnotation = [[AddressAnnotation alloc] initWithCoordinate:coord title:@"New York"];
    [_mapView addAnnotation:addAnnotation];
}

- (IBAction)gotoParis:(id)sender {
    //move the map to Paris
    CLLocationCoordinate2D coord = CLLocationCoordinate2DMake(48.856686,2.350022);//random location in Paris
    [_mapView setCenterCoordinate:coord animated:YES];
    // Zoom the region to this location
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(coord, REGION_SIZE, REGION_SIZE);
    [_mapView setRegion:region animated:YES];
    //add pin
    AddressAnnotation *addAnnotation = [[AddressAnnotation alloc] initWithCoordinate:coord title:@"Paris"];
    [_mapView addAnnotation:addAnnotation];
}

#pragma mark MKMapView
- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated{
    //Search For Foursquare places, will try to call it everytime the user pan the map
    //We will wait until the map is finally steady to make a search, otherwise it will be looking for restaurants on every map move, even if the user is only dragging to a specific location
    currentPanMoveNumber++;    
    [self performSelector:@selector(willSeachForVenues:) withObject:@(currentPanMoveNumber) afterDelay:1.0f];
    //NSLog(@"CHECK FOR VENUES");
}
-(void) willSeachForVenues:(NSNumber*) moveCount{
    if ([moveCount intValue] == currentPanMoveNumber) {
        //there wasn't any more moves/pans after the current one, proceed to load fousquare restaurants
        CLLocation *newLocation = [[CLLocation alloc] initWithLatitude:self.mapView.centerCoordinate.latitude longitude:self.mapView.centerCoordinate.longitude];
        LocationManager *lManager = [LocationManager sharedLocationBoss];        
        if (lastLocation) {
            //we have the lastLocation, will calculate the movement in meters to check if is worth doing a fousquare api call, moves also depend on the current radius
            //on a lowest radio, movements are very low but sometimes still important, so the movement threshold will depend on the current radius
            CLLocationDistance lastMovement = [lastLocation distanceFromLocation:newLocation]; // in meters
            CLLocationDistance radius = [self getCurrentRadius];
            //NSLog(@"CURRENT RADIUS %f %f",radius,radius/6);
            //the movement needs to be higher than 1/6 radius
            if (lastMovement > radius/6) {
                [lManager getVenuesForCurrentLocation:newLocation withRadius:radius];
               // NSLog(@"ACTUALLY GET VENUES ___________ %f",lastMovement);
            }
        } else {
            //there is no a lastLocation set, first time we call it
            [lManager getVenuesForCurrentLocation:newLocation withRadius:[self getCurrentRadius]];
            //NSLog(@"ACTUALLY GET VENUES FIRST TIME___________");
        }
        lastLocation = newLocation;
        currentPanMoveNumber = 0;
    }
}
-(CLLocationDistance) getCurrentRadius{
    MKCoordinateRegion region = _mapView.region;
    CLLocationCoordinate2D centerCoordinate = _mapView.centerCoordinate;
    CLLocation * newLocation = [[CLLocation alloc] initWithLatitude:centerCoordinate.latitude+region.span.latitudeDelta longitude:centerCoordinate.longitude];
    CLLocation * centerLocation = [[CLLocation alloc] initWithLatitude:centerCoordinate.latitude longitude:centerCoordinate.longitude];
    return [centerLocation distanceFromLocation:newLocation]; // in meters
}
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation{
    //use an specific icon for the fourquare places
    if (annotation == mapView.userLocation)
        return nil;
    
    static NSString *s = @"ann";
    MKAnnotationView *pin = [mapView dequeueReusableAnnotationViewWithIdentifier:s];
    if (!pin) {
        pin = [[MKPinAnnotationView alloc]initWithAnnotation:annotation reuseIdentifier:s];
        pin.image = [UIImage imageNamed:@"restaurant.png"];
        pin.calloutOffset = CGPointMake(0, 0);
        UIButton *button = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        pin.rightCalloutAccessoryView = button;
        
    }
    return pin;
}
- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    // dismiss out callout if it's already shown but on a different parent view
    if (calloutView.window)
        [calloutView dismissCalloutAnimated:NO];
    
    // Introduce an artificial delay in order to make our popup feel identical to MKMapView.
    // MKMapView has a delay after tapping so that it can intercept a double-tap for zooming. We don't need that delay but we'll
    // add it just so things feel the same.
    [self performSelector:@selector(popupMapCalloutView:) withObject:view afterDelay:1.0/3.0];
}
- (void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view {
    // again, we'll introduce an artifical delay to feel more like MKMapView for this demonstration.
    [calloutView performSelector:@selector(dismissCalloutAnimated:) withObject:nil afterDelay:1.0/3.0];
}
- (void)popupMapCalloutView:(MKAnnotationView*) view {
    
    if ([view.annotation isKindOfClass:[FoursquareVenue class]]) {

        // custom view to be used in our callout
        FoursquareVenue *venue = view.annotation;
        if (venue.imageIconURL) {
            //assign restaurant image icon and load it async
            AsyncImageView *imageView = [[AsyncImageView alloc] initWithFrame:CGRectMake(7.0f, 10.0f, 64.0f, 64.0f)];
            imageView.contentMode = UIViewContentModeScaleAspectFill;
            imageView.clipsToBounds = YES;
            imageView.imageURL = [NSURL URLWithString:venue.imageIconURL];
            [annotationViewController.view addSubview:imageView];
        }
        if (venue.twitter) {
            [annotationViewController.twitter setText:[@"@" stringByAppendingString:venue.twitter]];
        } else {
            //the restaurant doesn't have a twitter handle
            [annotationViewController.twitter setText:@"@noTwitter"];
        }
        [annotationViewController.name setText:venue.name];
        if (venue.phone) {
            [annotationViewController.phone setText:venue.phone];
        } else {
            //the restaurant doesn't have a phone number
            [annotationViewController.phone setText:@"No Phone #"];
        }
        
        // if you provide a custom view for the callout content, the title and subtitle will not be displayed
        calloutView.contentView = annotationViewController.view;
        calloutView.backgroundView = nil; // reset background view to the default SMCalloutDrawnBackgroundView
        [calloutView presentCalloutFromRect:view.bounds
                                     inView:view
                          constrainedToView:_mapView
                   permittedArrowDirections:SMCalloutArrowDirectionAny
                                   animated:YES];
    }
}
@end
