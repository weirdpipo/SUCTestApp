//
//  FoursquareAPI.h
//  SUCTestApp
//
//  Created by Phillipe Casorla Sagot on 2/28/13.
//  Copyright (c) 2013 Phillipe Casorla Sagot. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FSRequester.h"




//current key and secrent for SUCTestApp
#define OAUTH_KEY    (@"5Y5J2KEBAGFCFZDUM3UU0BHUWSSWLLP40Z3FXQPK5RZQJXQP")
#define OAUTH_SECRET (@"N4GDGW1FTTCD0IZUDRATWZ0PJH21UVXCCY1MIRD2NLUWI2PP")

//3 update this date to use up-to-date Foursquare API
#define VERSION (@"20130117")
#define kBaseUrl @"https://api.foursquare.com/v2/"



typedef void(^Foursquare2Callback)(BOOL success, id result);

typedef enum {
	intentCheckin,
	intentBrowse,
	intentGlobal,
	intentMatch
} FoursquareIntentType;

@interface FoursquareAPI : FSRequester {
	
}

+ (void)setBaseURL:(NSString *)uri;
+(FoursquareAPI*) sharedInstance;


#pragma mark ---------------------------- Venues ------------------------------------------------------------------------
//search for venues is a Userless access endpoint, we don't need an accessToken
+(void)searchVenuesNearByLatitude:(NSNumber*) lat
						longitude:(NSNumber*)lon
					   accuracyLL:(NSNumber*)accuracyLL
						 altitude:(NSNumber*)altitude
					  accuracyAlt:(NSNumber*)accuracyAlt
							query:(NSString*)query
							limit:(NSNumber*)limit
						   intent:(FoursquareIntentType)intent
                           radius:(NSNumber*)radius
                       categoryId:(NSString*)categoryId
						 callback:(Foursquare2Callback)callback;

@end
