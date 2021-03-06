//
//  APCircle.h
//  37 homework + test task
//
//  Created by Андрей on 5/9/15.
//  Copyright (c) 2015 Андрей. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface APCircle : MKOverlayRenderer <MKOverlay, MKAnnotation>



// From MKAnnotation, for areas this should return the centroid of the area.
@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;

// boundingMapRect should be the smallest rectangle that completely contains the overlay.
// For overlays that span the 180th meridian, boundingMapRect should have either a negative MinX or a MaxX that is greater than MKMapSizeWorld.width.
@property (nonatomic, assign) MKMapRect boundingMapRect;


@end
