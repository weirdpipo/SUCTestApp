//
//  FousquareVenue.m
//  SUCTestApp
//
//  Created by Phillipe Casorla Sagot on 3/1/13.
//  Copyright (c) 2013 Phillipe Casorla Sagot. All rights reserved.
//

#import "FoursquareVenue.h"

@implementation FoursquareVenue
-(id) initWithDictionary:(NSDictionary*)data{
    if (self = [super init]) {
        //translate the json data into our fousquareVenue entity
        self.name = data[@"name"];
        self.venueId = data[@"id"];
        
        self.address = data[@"location"][@"address"];
        self.distance = data[@"location"][@"distance"];
        
        [self setCoordinate:CLLocationCoordinate2DMake([data[@"location"][@"lat"] doubleValue],
                                                               [data[@"location"][@"lng"] doubleValue])];
        self.twitter = data[@"contact"][@"twitter"];
        self.phone = data[@"contact"][@"phone"];
        NSArray *categories = data[@"categories"];
        if (categories.count > 0) {
            NSDictionary *restInfo = [categories objectAtIndex:0];
            self.imageIconURL = [@"" stringByAppendingFormat:@"%@bg_64%@",restInfo[@"icon"][@"prefix"],restInfo[@"icon"][@"suffix"]];
        }
    }
    return self;
}
@end
