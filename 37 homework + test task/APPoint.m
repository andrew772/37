//
//  APPoint.m
//  37 homework + test task
//
//  Created by Андрей on 5/9/15.
//  Copyright (c) 2015 Андрей. All rights reserved.
//

#import "APPoint.h"
#import <MapKit/MapKit.h>

@implementation APPoint

- (void)setCoordinate:(CLLocationCoordinate2D)newCoordinate{
 
 _coordinate = newCoordinate;
    NSLog(@"setCoordinate location = {%f, %f}", _coordinate.latitude, _coordinate.longitude);
    
 
 }


@end
