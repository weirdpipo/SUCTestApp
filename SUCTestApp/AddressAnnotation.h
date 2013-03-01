//
//  AddressAnnotation.h
//  SUCTestApp
//
//  Created by Phillipe Casorla Sagot on 2/28/13.
//  Copyright (c) 2013 Phillipe Casorla Sagot. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>


@interface AddressAnnotation : NSObject<MKAnnotation> {
}
// This is a required property from MKAnnotation
@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;

// This is an optional property from MKAnnotation
@property (nonatomic, copy) NSString *title;

-(id)initWithCoordinate:(CLLocationCoordinate2D) c title:(NSString*)t;
@end
