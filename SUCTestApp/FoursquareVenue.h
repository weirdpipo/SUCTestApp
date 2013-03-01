//
//  FousquareVenue.h
//  SUCTestApp
//
//  Created by Phillipe Casorla Sagot on 3/1/13.
//  Copyright (c) 2013 Phillipe Casorla Sagot. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

@interface FoursquareVenue : NSObject<MKAnnotation>
@property (nonatomic,strong) NSString *name;
@property (nonatomic,strong) NSString *venueId;
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@property (nonatomic,strong)  NSNumber *distance;
@property (nonatomic,strong)  NSString *address;
@property (nonatomic,strong)  NSString *imageIconURL;
@property (nonatomic,strong)  NSString *phone;
@property (nonatomic,strong)  NSString *twitter;

-(id) initWithDictionary:(NSDictionary*)data;
@end
