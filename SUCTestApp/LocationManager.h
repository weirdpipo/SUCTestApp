//
//  LocationManager.h
//  SUCTestApp
//
//  Created by Phillipe Casorla Sagot on 2/28/13.
//  Copyright (c) 2013 Phillipe Casorla Sagot. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
extern NSString *const kLocationChangedNotification;
extern NSString *const kFQLoadedNotification;
@interface LocationManager : NSObject<CLLocationManagerDelegate>
{
    CLLocationManager *locationManager;
    CLGeocoder        *geocoder;
}
@property(nonatomic,strong) CLPlacemark       *currentLocationReversed;
@property(nonatomic,strong) CLLocation        *currentLocation;
@property(nonatomic,strong) NSMutableArray    *currentVenues;
@property(readonly) BOOL deniedGPSPermission;
@property(readonly) BOOL running;
+(LocationManager*) sharedLocationBoss;
-(void) restartService;
-(void)getVenuesForCurrentLocation:(CLLocation*)newLocation withRadius:(CLLocationDistance)radius;
@end
