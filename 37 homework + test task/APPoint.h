//
//  APPoint.h
//  37 homework + test task
//
//  Created by Андрей on 5/9/15.
//  Copyright (c) 2015 Андрей. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface APPoint : UIView <MKAnnotation>

@property (assign, nonatomic) CLLocationCoordinate2D coordinate;
@property (nonatomic, /*readonly,*/ copy) NSString *title;
@property (nonatomic, /*readonly,*/ copy) NSString *subtitle;
- (void)setCoordinate:(CLLocationCoordinate2D)newCoordinate;

@property (strong, nonatomic) NSArray* circlesArray;

@end
