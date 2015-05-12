//
//  APTableView.m
//  37 homework + test task
//
//  Created by Андрей on 5/9/15.
//  Copyright (c) 2015 Андрей. All rights reserved.
//

#import "APTableViewController.h"
#import "APStudent.h"


@implementation APTableViewController

- (void)viewDidLoad{

    APStudent* student = [[APStudent alloc] init];
    
    // put check here
    
    student = (APStudent*)self.annotationView.annotation;
    
    self.firstName.detailTextLabel.text = student.firstName;
    self.lastName.detailTextLabel.text = student.lastName;
    
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    formatter.dateStyle = kCFDateFormatterLongStyle;
    
    
    self.birthDate.detailTextLabel.text = [formatter stringFromDate: student.birthDate];
    if (student.gender == male) {
        self.gender.detailTextLabel.text = @"male";
    }
    else
        self.gender.detailTextLabel.text = @"female";
    
    
    NSString* adressString = [NSString stringWithFormat:@"%@, %@ %@ %@",
                              student.placeMark.country,
                              student.placeMark.locality ? student.placeMark.locality : @"",
                              student.placeMark.thoroughfare ? student.placeMark.thoroughfare : @"",
                              student.placeMark.subThoroughfare ? student.placeMark.subThoroughfare : @""];
 
    self.adress.detailTextLabel.text = adressString;
    
}



@end
