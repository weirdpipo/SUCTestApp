//
//  LocationManager.m
//  SUCTestApp
//
//  Created by Phillipe Casorla Sagot on 2/28/13.
//  Copyright (c) 2013 Phillipe Casorla Sagot. All rights reserved.
//

#import "LocationManager.h"
#import "FoursquareAPI.h"
#import "FoursquareVenue.h"
NSString *const kLocationChangedNotification = @"kLocationChangedNotification";
NSString *const kFQLoadedNotification = @"kFQLoadedNotification";
@implementation LocationManager


- (void)locationManager:(CLLocationManager *)manager
	didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation{
    // if the location is older than 30s ignore
    if (fabs([newLocation.timestamp timeIntervalSinceDate:[NSDate date]]) > 30)
    {
        return;
    }
    self.currentLocation = newLocation;
    [self reverseCurrentLocation];
    //send notification to let know that we have our current position, helps to have decoupled classes
    [[NSNotificationCenter defaultCenter] postNotificationName:kLocationChangedNotification object:_currentLocation];
}

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error{
    [locationManager stopUpdatingLocation];
    _running = NO;
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status{
    if (status != kCLAuthorizationStatusAuthorized) {
        _deniedGPSPermission = YES;
        _running = NO;
    }
}
-(void) reverseCurrentLocation {
    
    if (_currentLocation != nil) {
        if (!geocoder) {
            geocoder = [[CLGeocoder alloc] init];
        }
        [geocoder reverseGeocodeLocation: _currentLocation completionHandler:
         ^(NSArray *placemarks, NSError *error) {
             
             if (!error && placemarks.count > 0) {
                 self.currentLocationReversed = [placemarks objectAtIndex:0];
             }
         }];
    }
}
//init the location manager and start receiving GPS data
-(void) restartService{
    //Check if location services are enabled on the device
    if (([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorized ||
         [CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined ) && [CLLocationManager locationServicesEnabled]) {
        if (nil == locationManager)
            locationManager = [[CLLocationManager alloc] init];
        _currentLocation = nil;
        _currentLocationReversed = nil;
        locationManager.delegate = self;
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        // Set a movement threshold for new events.
        locationManager.distanceFilter = 5000;// 5KM Location Change
        
        [locationManager startUpdatingLocation];
        _running = YES;
    }
}
#pragma  mark Foursquare Methods
//Search API Example ttps://api.foursquare.com/v2/venues/search?ll=40.7,-74&&categoryId=4d4b7105d754a06374d81259&client_id=5Y5J2KEBAGFCFZDUM3UU0BHUWSSWLLP40Z3FXQPK5RZQJXQP&client_secret=N4GDGW1FTTCD0IZUDRATWZ0PJH21UVXCCY1MIRD2NLUWI2PP
-(void)getVenuesForCurrentLocation:(CLLocation*)newLocation withRadius:(CLLocationDistance)radius{
    [FoursquareAPI searchVenuesNearByLatitude:@(newLocation.coordinate.latitude)
								  longitude:@(newLocation.coordinate.longitude)
								 accuracyLL:nil
								   altitude:@(newLocation.altitude)
								accuracyAlt:nil
									  query:nil
									  limit:nil
									 intent:intentCheckin
                                     radius:@(radius)
                                 categoryId:@"4d4b7105d754a06374d81259" //food category
								   callback:^(BOOL success, id result){
									   if (success) {
                                           //convert json dictionaries into our entities
										   NSDictionary *dic = result;
										   NSArray* venues = [dic valueForKeyPath:@"response.venues"];
                                           [_currentVenues removeAllObjects];
                                           for(NSDictionary *venue in venues){
                                               FoursquareVenue *fVenue = [[FoursquareVenue alloc] initWithDictionary:venue];
                                               [_currentVenues addObject:fVenue];
                                               //send notification to the view, so he can add the venues in the map
                                               [[NSNotificationCenter defaultCenter] postNotificationName:kFQLoadedNotification object:nil];
                                           }
                                           
									   }
								   }];
}
#pragma mark Singleton stuff

-(id) init
{
	if ((self = [super init]))
	{
        _currentVenues = [[NSMutableArray alloc] initWithCapacity:10];
    }
    return self;
}
+(LocationManager*) sharedLocationBoss
{
	@synchronized(self)
	{
        
        static LocationManager *defaultLocationManager = nil;
        if(!defaultLocationManager)
            defaultLocationManager = [[super allocWithZone:nil] init];
        
        return defaultLocationManager;
	}
	
	// to avoid compiler warning
	return nil;
}
@end