//
//  APTableView.h
//  37 homework + test task
//
//  Created by Андрей on 5/9/15.
//  Copyright (c) 2015 Андрей. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MKAnnotationView;

@interface APTableViewController : UITableViewController

@property (weak, nonatomic) IBOutlet UITableViewCell *firstName;
@property (weak, nonatomic) IBOutlet UITableViewCell *lastName;
@property (weak, nonatomic) IBOutlet UITableViewCell *birthDate;
@property (weak, nonatomic) IBOutlet UITableViewCell *gender;
@property (weak, nonatomic) IBOutlet UITableViewCell *adress;

@property (strong, nonatomic) MKAnnotationView* annotationView;

@end
