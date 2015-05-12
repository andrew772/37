//
//  ViewController.h
//  37 homework + test task
//
//  Created by Андрей on 5/7/15.
//  Copyright (c) 2015 Андрей. All rights reserved.
//


#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "APStudent.h"
//@class APPoint;




@interface ViewController : UIViewController <MKMapViewDelegate , CLLocationManagerDelegate,UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) IBOutlet MKMapView  *mapView;
@property (strong, nonatomic) CLLocationManager   *locationManager;
@property (strong, nonatomic) CLLocation          *location;

@property (strong, nonatomic) NSArray* studentsArray;
@end

