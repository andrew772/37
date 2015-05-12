

#import "ViewController.h"
#import "UIView+MKAnnotationView.h"
#import "APTableViewController.h"
#import "APPoint.h"
#import "APCircle.h"

@interface ViewController ()<UIPopoverControllerDelegate>

@property (strong, nonatomic) UIPopoverController* popover;
@property (strong, nonatomic) CLGeocoder* geoCoder;
@property (strong, nonatomic) APPoint* centerPoint;
@property (strong, nonatomic) UITableView* studentsTable;
@property (strong, nonatomic) NSArray* rangedStudents;
@property (strong, nonatomic) MKDirections* directions;
@property (strong, nonatomic) NSArray* studentsRouts;

@end
/* please set custom location
 
 48,460164
 35,054795
 
 you can edit quantity of circles at line 319. just add or remove some number(s).
  self.centerPoint.circlesArray = @[@500 ,@1000 ,@1500, @2500, @3500];

 */



@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    self.studentsTable = [[UITableView alloc] init];
    
    self.locationManager = [[CLLocationManager alloc ] init];
    self.locationManager.delegate = self;
    
    [self.locationManager requestAlwaysAuthorization];
    [self.locationManager startUpdatingLocation];
    _mapView.showsUserLocation = YES;
    
    self.studentsRouts = [[NSArray alloc] init];
    
    
    UIBarButtonItem* zoomButton =
    [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch
                                                  target:self
                                                  action:@selector(actionShowAll:)];
    
    UIBarButtonItem* actionButton =
    [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction
                                                  target:self
                                                  action:@selector(actionAddPoint:)];
    
    UIBarButtonItem* directionButton =
    [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
                                                  target:self
                                                  action:@selector(actionDirection:)];
    
     directionButton.tintColor = [UIColor lightGrayColor];
    
    
    
    self.navigationItem.rightBarButtonItems = @[zoomButton, actionButton, directionButton];
    
    self.studentsArray = [[NSMutableArray alloc] init];
    NSMutableArray* studArray = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < 10; i++) {
        APStudent* stud = [APStudent randomStudent];
        [studArray addObject:stud];
    }
    
    self.studentsArray = studArray;
    for (APStudent* stud in self.studentsArray) {
        
        [self.mapView addAnnotation:stud];
    }
    NSLog(@"%@", self.mapView.annotations.description);
    self.geoCoder = [[CLGeocoder alloc] init];
}

- (void) actionShowAll:(UIBarButtonItem*) sender {
    
    MKMapRect zoomRect = MKMapRectNull;
    
    for (id <MKAnnotation> annotation in self.mapView.annotations) {
        
        CLLocationCoordinate2D location = annotation.coordinate;
        MKMapPoint center = MKMapPointForCoordinate(location);
        static double delta = 20000;
        MKMapRect rect = MKMapRectMake(center.x - delta, center.y - delta, delta * 2, delta * 2);
        zoomRect = MKMapRectUnion(zoomRect, rect);
    }
    
    zoomRect = [self.mapView mapRectThatFits:zoomRect];
    [self.mapView setVisibleMapRect:zoomRect
                        edgePadding:UIEdgeInsetsMake(50, 50, 50, 50)
                           animated:YES];
    
}

-(void) locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    
    [self.locationManager requestAlwaysAuthorization];
    [self.locationManager startUpdatingLocation];
    
    self.location = locations.lastObject;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

#pragma mark - MKMapViewDelegate

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view didChangeDragState:(MKAnnotationViewDragState)newState
   fromOldState:(MKAnnotationViewDragState)oldState {
    
    if (newState == MKAnnotationViewDragStateStarting) {
        view.dragState = MKAnnotationViewDragStateDragging;
        [self.mapView removeOverlays:self.mapView.overlays];
    }
    else if (newState == MKAnnotationViewDragStateEnding || newState == MKAnnotationViewDragStateCanceling) {
        view.dragState = MKAnnotationViewDragStateNone;
        if ([view.annotation isKindOfClass:[APPoint class]]) {
            [self drawCirclesForPoint:(APPoint*)view.annotation];
        }
    }
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation{
    
    if ([annotation isKindOfClass:[MKUserLocation class]])
    {
        return nil;
    }
    
    CGFloat iconHight = 30.0;
    UIImage* manImage = [UIImage imageNamed:@"man.png"];
    CGFloat iconWidth = manImage.size.width * (iconHight / manImage.size.height);
    CGRect iconFrame = CGRectMake(0, 0, iconWidth, iconHight);
    
    if([annotation isKindOfClass:[APStudent class]]){
        
        static  NSString* const reuseIdentifierMan   = @"man";
        static  NSString* const reuseIdentifierWoman = @"woman";
        
        MKAnnotationView* manAnnotationView   = [self.mapView dequeueReusableAnnotationViewWithIdentifier:reuseIdentifierMan];
        MKAnnotationView* womanAnnotationView = [self.mapView dequeueReusableAnnotationViewWithIdentifier:reuseIdentifierWoman];
        
        UIButton* descriptionButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        [descriptionButton addTarget:self action:@selector(actionDescription:) forControlEvents:UIControlEventTouchUpInside];
        
        if (((APStudent*)annotation).gender == male) {
            
            if (manAnnotationView) {
                manAnnotationView.annotation = annotation;
            }
            else{
                manAnnotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:reuseIdentifierMan];
            }
            manAnnotationView.image = [UIImage imageNamed:@"man.png"];
            manAnnotationView.frame = iconFrame;
            manAnnotationView.canShowCallout = YES;
            manAnnotationView.draggable = NO;
            manAnnotationView.rightCalloutAccessoryView = descriptionButton;
            return manAnnotationView;
        }
        else if (((APStudent*)annotation).gender == female){
            
            if (womanAnnotationView) {
                womanAnnotationView.annotation = annotation;
            }
            else{
                womanAnnotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:reuseIdentifierWoman];
            }
            womanAnnotationView.image = [UIImage imageNamed:@"woman.png"];
            womanAnnotationView.frame = iconFrame;
            womanAnnotationView.canShowCallout = YES;
            womanAnnotationView.draggable = NO;
            womanAnnotationView.rightCalloutAccessoryView = descriptionButton;
            
            return womanAnnotationView;
        }
        else
            return nil;
    }
    else if ([annotation isKindOfClass:[APPoint class]]){
        
        MKAnnotationView* pointAnnotationView = [[MKAnnotationView alloc] init];
        
        pointAnnotationView.image = [UIImage imageNamed:@"point.png"];
        pointAnnotationView.frame = iconFrame;
        pointAnnotationView.canShowCallout = YES;
        pointAnnotationView.draggable = YES;
        return pointAnnotationView;
    }
    return nil;
}
#pragma mark - Actions

- (void) actionBack:(UIButton*) sender {
    
    [self.navigationController popToViewController:self.presentedViewController animated:YES];
    
    /*[self presentViewController:self.presentingViewController
                       animated:YES
                     completion:nil];*/
}


- (void) actionDirection:(UIButton*) sender {
    
    if (!self.centerPoint) {
        return;
    }
    
    ((UIBarButtonItem*)self.navigationItem.rightBarButtonItems[1]).tintColor = [UIColor lightGrayColor];
    
    
    [self.mapView removeOverlays:self.studentsRouts];
    
    if ([self.directions isCalculating]) {
        [self.directions cancel];
    }
    
    NSMutableArray* mutableRoutsArray = [[NSMutableArray alloc] init];
    int j = 0;
    
    for (int i = 0; i < self.rangedStudents.count - 1; i++) {
        
        NSLog(@"for_1 entered");
        
        for (APStudent* stud in ((NSArray*)self.rangedStudents)[i]) {
            
            j++;
            
            NSLog(@"for_2 entered");
            
            MKDirectionsRequest* request = [[MKDirectionsRequest alloc] init];
            
            MKPlacemark* studPlacemark = [[MKPlacemark alloc] initWithCoordinate:stud.coordinate
                                                               addressDictionary:nil];
            MKMapItem* studMapItem = [[MKMapItem alloc] initWithPlacemark:studPlacemark];
            request.source = studMapItem;
            
            MKPlacemark* centerPointPlacemark = [[MKPlacemark alloc] initWithCoordinate:self.centerPoint.coordinate
                                                                      addressDictionary:nil];
            MKMapItem* centerPointMapItem = [[MKMapItem alloc] initWithPlacemark:centerPointPlacemark];
            request.destination = centerPointMapItem;
            
            request.transportType = MKDirectionsTransportTypeAutomobile;
            request.requestsAlternateRoutes = NO;
            
            self.directions = [[MKDirections alloc] initWithRequest:request];
            
            [self.directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error) {
                
                if ([self.directions isCalculating]) {
                    NSLog(@"[self.directions isCalculating]");
                }
                else{
                    NSLog(@"[self.directions isEnded]");
                }
                
                if (error) {
                    NSLog(@"Error");
                    [self showAlertWithTitle:@"Error" andMessage:[error localizedDescription]];
                    
                    
                } else if ([response.routes count] == 0) {
                    NSLog(@"No routes found");
                    [self showAlertWithTitle:@"Error" andMessage:@"No routes found"];
                    
                    
                } else {
                    NSLog(@"routes found");
                    for (MKRoute* route in response.routes) {
                        [mutableRoutsArray addObject:route.polyline];
                        NSLog(@"mutableRoutsArray.count = %u", mutableRoutsArray.count);
                        
                    }
                    if(j == mutableRoutsArray.count){
                        NSLog(@"cicle ended");
                        
                        self.studentsRouts = mutableRoutsArray;
                        [self.mapView addOverlays:self.studentsRouts level:MKOverlayLevelAboveLabels];
                    }
                }
            }];
        }
    }
}


- (void) actionAddPoint:(UIButton*) sender {
    
    if (self.centerPoint) {
        return;
    }
    
    ((UIBarButtonItem*)self.navigationItem.rightBarButtonItems[1]).tintColor = [UIColor lightGrayColor];
    ((UIBarButtonItem*)self.navigationItem.rightBarButtonItems[2]).tintColor = [UIColor blueColor];

    APPoint* annotation = [[APPoint alloc] init];
    self.centerPoint = annotation;
    self.centerPoint.title = @"Party Here!";
    self.centerPoint.subtitle = @"everybody come on!";
    self.centerPoint.coordinate = self.mapView.region.center;
    
    [self.mapView addAnnotation:self.centerPoint];
    self.centerPoint.circlesArray = @[@500 ,@1000 ,@1500, @2500, @3500];
    [self drawCirclesForPoint:self.centerPoint];
}

- (void) actionDescription:(UIButton*) sender {
    
    MKAnnotationView* annotationView = [sender superAnnotationView];
    
    if (!annotationView) {
        return;
    }
    if ([annotationView.annotation isKindOfClass:[APStudent class]]) {
        
        CLLocationCoordinate2D coordinate = annotationView.annotation.coordinate;
        CLLocation* location = [[CLLocation alloc] initWithLatitude:coordinate.latitude
                                                          longitude:coordinate.longitude];
        if ([self.geoCoder isGeocoding]) {
            [self.geoCoder cancelGeocode];
        }
        [self.geoCoder
         reverseGeocodeLocation:location
         completionHandler:^(NSArray *placemarks, NSError *error) {
             
             NSString* message = nil;
             
             if (error) {
                 message = [error localizedDescription];
             } else {
                 
                 if ([placemarks count] > 0) {
                     MKPlacemark* placeMark = [placemarks firstObject];
                     if ([annotationView.annotation isKindOfClass:[APStudent class]]) {
                         ((APStudent*)annotationView.annotation).placeMark = placeMark;
                     }
                 } else {
                     message = @"No Placemarks Found";
                 }
             }
             
             APTableViewController* vc = [self.storyboard instantiateViewControllerWithIdentifier:@
                                          "APDetailsViewController"];
             vc.annotationView  = annotationView;
             
            
             
             if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                 
                 [self showController:vc inPopoverFromSender:sender];
//                 [self showControllerAsModal:vc];
             }
             else{
                 
                 [self.navigationController pushViewController:vc animated:YES];

             }
         }];
    }
}

- (void) showController: (APTableViewController*) vc inPopoverFromSender: (id) sender{
    
    if ([sender isKindOfClass:[UIButton class]]) {
        NSLog(@"showController sender is UIButton");
        
        if (!sender) {
            return;
        }

        UIPopoverController* popover = [[UIPopoverController alloc] initWithContentViewController:vc];
        popover.delegate = self;
        self.popover = popover;
        
        [vc.tableView reloadData];
        CGSize tableViewSize = vc.tableView.contentSize;
        popover.popoverContentSize = CGSizeMake(300, tableViewSize.height);
 
        UIView* cloud = ((UIButton*)sender).superview.superview;
        CGRect rectForPopover = [cloud convertRect:cloud.frame toView:nil];
        
        [popover presentPopoverFromRect:rectForPopover
                                 inView:self.view
               permittedArrowDirections:UIPopoverArrowDirectionAny
                               animated:YES];
    }
}

- (void) showControllerAsModal:(UIViewController*) vc{
    
//    UINavigationController* nav = [[UINavigationController alloc] initWithRootViewController:vc];
    
    /*UINavigationController* nav = vc.navigationController;
    
    UIBarButtonItem* backButton =
    [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                  target:self
                                                  action:@selector(actionBack:)];
    
    vc.navigationItem.leftBarButtonItem = backButton;*/
    
    /*[self presentViewController:nav
                       animated:YES
                     completion:nil];*/

}

- (void) drawCirclesForPoint: (APPoint*) point{
    
    for (NSNumber* num in point.circlesArray) {
        
        MKCircle *circle  = [MKCircle circleWithCenterCoordinate:point.coordinate radius:[num intValue]];
        [self.mapView addOverlay:circle];
    }
    self.rangedStudents = [self studentsInCircle];
    [self addResultSubview];
}

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id <MKOverlay>)overlay {
    
    if ([overlay isKindOfClass:[MKCircle class]]) {
        
        MKCircleRenderer *circleRendere = [[MKCircleRenderer alloc] initWithOverlay:overlay];
        circleRendere.fillColor = [[UIColor redColor] colorWithAlphaComponent:0.03];
        return circleRendere;
    }
    else if ([overlay isKindOfClass:[MKPolyline class]]) {
        
        MKPolylineRenderer* renderer = [[MKPolylineRenderer alloc] initWithOverlay:overlay];
        renderer.lineWidth = 2.f;
        renderer.strokeColor = [UIColor colorWithRed:0.f green:0.5f blue:1.f alpha:0.9f];
        return renderer;
    }
    else
        return nil;
}

- (NSArray*) studentsInCircle{
    
    NSMutableArray* arrayMain = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < self.centerPoint.circlesArray.count; i++) {
        
        NSMutableArray* array = [[NSMutableArray alloc] init];
        [arrayMain addObject:array];
    }
    
    CLLocation *centerLocation =
    [[CLLocation alloc] initWithCoordinate: self.centerPoint.coordinate
                                  altitude:1
                        horizontalAccuracy:1
                          verticalAccuracy:1
                                 timestamp:nil];
    
    for (APStudent* stud in self.studentsArray) {
        
        CLLocation *studLocation =
        [[CLLocation alloc] initWithCoordinate:stud.coordinate
                                      altitude:1
                            horizontalAccuracy:1
                              verticalAccuracy:1
                                     timestamp:nil];
        
        CLLocationDistance studDist = [studLocation distanceFromLocation:centerLocation];
        for (int i = 0; i < self.centerPoint.circlesArray.count; i++) {
            if (studDist < [((NSNumber*) self.centerPoint.circlesArray[i]) integerValue]) {
                [arrayMain[i] addObject:stud];
                break;
            }
        }
    }
    return arrayMain;
}

- (void) addResultSubview {
    
    [self.studentsTable removeFromSuperview];
    self.studentsTable.dataSource = self;
    
    [self.studentsTable reloadData];
    self.studentsTable.alpha = 0.7;
    
    CGSize tableViewSize = self.studentsTable.contentSize;
    float viewHeight = self.mapView.frame.size.height;
    
    float tableHeight = viewHeight < tableViewSize.height ? viewHeight : tableViewSize.height;
    CGRect rect = CGRectMake(0, 0, 200, tableHeight);
    NSLog(@"%f, %f", rect.size.width, rect.size.height);
    self.studentsTable.frame = rect;
    
    __weak UITableView* weakStudentsTable = self.studentsTable;
    [self.mapView addSubview:weakStudentsTable];
}

#pragma mark - UITableViewDataSource


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    if ([tableView isEqual:self.studentsTable]) {
        return ((NSArray*)self.rangedStudents[section]).count;
    }
    return 0;
    
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static  NSString* const reuseIdentifierCell = @"cell";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifierCell];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifierCell];
    }
    
    APStudent* stud = ((NSArray*)self.rangedStudents[indexPath.section])[indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%@ %@ ", stud.firstName, stud.lastName];
    return cell;
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.rangedStudents.count;
    
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    
    NSInteger integer = [((NSNumber*)self.centerPoint.circlesArray[section]) integerValue];
    
    if (((NSArray*)self.rangedStudents[section]).count == 0) {
        return nil;
    }
    else{
        return [NSString stringWithFormat:@"  %d meter", integer];
    }
    
}

#pragma mark UITableViewDelegate

- (void) showAlertWithTitle:(NSString*) title andMessage:(NSString*) message {
    [[[UIAlertView alloc]
      initWithTitle:title
      message:message
      delegate:nil
      cancelButtonTitle:@"OK"
      otherButtonTitles:nil] show];
}


@end












