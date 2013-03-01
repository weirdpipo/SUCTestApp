//
//  ViewController.h
//  SUCTestApp
//
//  Created by Phillipe Casorla Sagot on 2/28/13.
//  Copyright (c) 2013 Phillipe Casorla Sagot. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "FoursquareAnnotationViewController.h"

@interface FoursquareViewController : UIViewController<MKMapViewDelegate>{
    //controller view for the callout
    FoursquareAnnotationViewController *annotationViewController;
    //total of continuous moves
    int currentPanMoveNumber;
    //last location we used to search places
    CLLocation * lastLocation;
}
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UIToolbar *locationToolbar;

//Buttons Events
- (IBAction)locateMe:(id)sender;
- (IBAction)gotoNYC:(id)sender;
- (IBAction)gotoParis:(id)sender;

@end
