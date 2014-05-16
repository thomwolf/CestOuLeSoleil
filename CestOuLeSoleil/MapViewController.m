//
//  MapViewController.m
//  CestOuLeSoleil
//
//  Created by Thomas Wolf on 06/05/14.
//
//

#import "MapViewController.h"
#import "TerrasseTableViewController.h"
#import <Mapbox/Mapbox.h>
#import "MapKit/MKAnnotation.h"

#define kNormalMapID  @"thomwolf.i8g664fa"
#define CLUSTER_ZOOM 17

static NSString * const BaseURLString = @"http://terrasses.alwaysdata.net/";

@interface MapViewController ()

@property (strong) RMMapView *mapView;
//@property (strong) NSArray *activeFilterTypes;
@property (strong) NSDictionary *terrasses;
@property (nonatomic, assign) RMSphericalTrapezium boundsstart;
@property (nonatomic, assign) BOOL readyToQueryMarkers;
@property (strong) NSNumber *first_time;
@property (strong) NSMutableArray *numarray;

@end

@implementation MapViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    RMMapboxSource *tileSource = [[RMMapboxSource alloc] initWithMapID:@"thomwolf.i8g664fa"];
    
    self.mapView = [[RMMapView alloc] initWithFrame:self.view.bounds andTilesource:tileSource];
    
    [self.view addSubview:self.mapView];
    
    NSLog(@"youhouh");
    NSLog(tileSource.debugDescription);
    self.mapView.delegate = self;
    
    //    self.mapView.zoom = 16;
    self.mapView.minZoom = 16;
    /** Contrain zooming and panning of the map view to a given coordinate boundary.
     *   @param southWest The southwest point to constrain to.
     *   @param northEast The northeast point to constrain to. */
    [self.mapView setConstraintsSouthWest:(CLLocationCoordinate2D) {.latitude= 48.788092642076286, .longitude= 2.1996688842773433}
                                northEast:(CLLocationCoordinate2D) {.latitude=48.926108577622024, .longitude=2.4757003784179683} ];
    
    self.mapView.userTrackingMode = RMUserTrackingModeFollow;//RMUserTrackingModeNone;
    
    //    [self.mapView setConstraintsSouthWest:[self.mapView.tileSource latitudeLongitudeBoundingBox].southWest
    //                                northEast:[self.mapView.tileSource latitudeLongitudeBoundingBox].northEast];
    
    self.mapView.showsUserLocation = YES;
    
    self.title = @"C'est où le soleil";//[self.mapView.tileSource shortName];
    
    [self.mapView setCenterCoordinate:(CLLocationCoordinate2D) {48.8472876, 2.3482246}];
    [self.mapView setZoom:17];
    self.readyToQueryMarkers = NO;
    self.mapView.clusteringEnabled = YES;
    
    _numarray = [[NSMutableArray alloc] init];
    NSLog(@"youhouh2");
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)getAndAddTerrassesWithParameters:(NSDictionary *)parameters {
    
    // 1
    NSString *string = [NSString stringWithFormat:@"%@position2.php", BaseURLString];
    
    NSURLRequest *request = [[AFHTTPRequestSerializer serializer] requestWithMethod:@"GET" URLString:string parameters:parameters error:nil];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    
    NSLog([request debugDescription]);
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        // 3
        self.terrasses = (NSDictionary *)responseObject;
        //      NSLog(@"Youhou");
        //      NSLog(self.terrasses.description);
        
        self.first_time = [self.terrasses first_time];
        //        NSLog(first_time.description);
        //NSNumber * nexttime = first_time;
        
        NSArray * tableau = [self.terrasses tableau];//['tableau'];
        NSEnumerator *enumerator;
        enumerator =  [tableau objectEnumerator]; // Vous n'êtes pas propriétaire de enumerator
        
        //NSArray * markersarray = new Array();
        NSDictionary * place;
        
        while (place = [enumerator nextObject])
        { // On boucle tant que la méthode ne renvoie pas nil (ce qui casse la condition)
            NSLog(place.description);
            if ([place latitude] && [place longitude])
            {
                if (![self.numarray containsObject:place])
                {
                    [self.numarray addObject:place];
                    RMAnnotation * marker;
                    CLLocationCoordinate2D markercoord = CLLocationCoordinate2DMake([[place latitude] doubleValue], [[place longitude] doubleValue]);
                    
                    marker = [RMAnnotation annotationWithMapView:self.mapView coordinate:markercoord andTitle:[place placename_ter]];
                    
                    NSDictionary *userinfo = [NSDictionary dictionaryWithObjectsAndKeys:[place num],@"num", [place nombresoleil], @"sunny", [place timenext], @"timenext", nil ];//,@"value2",@"key2", nil];
                    [marker setUserInfo:userinfo];
                    
                    [self.mapView addAnnotation:marker];
                } else {
                    //                   NSLog(@"déjà dans numarray");
                }
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error Retrieving Weather"
                                                            message:[error localizedDescription]
                                                           delegate:nil
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles:nil];
        [alertView show];
    }];
    
    [operation start];
}


/**  the location of the user was updated.
 *
 *   While the showsUserLocation property is set to YES, this method is called whenever a new location update is received by the map view. This method is also called if the map view’s user tracking mode is set to RMUserTrackingModeFollowWithHeading and the heading changes.
 *
 *   This method is not called if the application is currently running in the background. If you want to receive location updates while running in the background, you must use the Core Location framework.
 *   @param mapView The map view that is tracking the user’s location.
 *   @param userLocation The location object representing the user’s latest location. */
- (void)mapView:(RMMapView *)mapView didUpdateUserLocation:(RMUserLocation *)userLocation
{
    NSLog(@"youhouh2");
    if(!self.readyToQueryMarkers)
    {
        self.readyToQueryMarkers = YES;
        [self.mapView setUserTrackingMode:RMUserTrackingModeNone animated:NO];

        CLLocation * loc = [userLocation location];
        CLLocationCoordinate2D center= [loc coordinate];
        [self.mapView setCenterCoordinate:center];

        RMSphericalTrapezium boundsend = self.mapView.latitudeLongitudeBoundingBox;
        
        //    self.first_time = [[NSNumber alloc] init];
        
        NSDictionary *parameters = @{@"type": @"move",
                                     @"LON1s": [NSString stringWithFormat:@"%f", center.longitude],
                                     @"LON2s": [NSString stringWithFormat:@"%f",center.longitude],
                                     @"LAT1s": [NSString stringWithFormat:@"%f",center.latitude],
                                     @"LAT2s": [NSString stringWithFormat:@"%f",center.latitude],
                                     @"LON1e": [NSString stringWithFormat:@"%f",boundsend.southWest.longitude ],
                                     @"LAT1e": [NSString stringWithFormat:@"%f",boundsend.southWest.latitude ],
                                     @"LON2e": [NSString stringWithFormat:@"%f",boundsend.northEast.longitude ],
                                     @"LAT2e": [NSString stringWithFormat:@"%f",boundsend.northEast.latitude ],
                                     @"lon": [NSString stringWithFormat:@"%f",center.longitude ],
                                     @"lat": [NSString stringWithFormat:@"%f",center.latitude ]
                                     };
        [self getAndAddTerrassesWithParameters:parameters];
    }
};

/** When a map is about to move.
 *   @param mapView The map view that is about to move.
 *   @param wasUserAction A Boolean indicating whether the map move is in response to a user action or not. */
- (void)beforeMapMove:(RMMapView *)map byUser:(BOOL)wasUserAction
{
	if (self.readyToQueryMarkers && wasUserAction)
	{
        self.boundsstart = map.latitudeLongitudeBoundingBox;
        NSLog(@"before move: %f",self.boundsstart.northEast.latitude);
    }
};

/** When a map has finished moving.
 *   @param map The map view that has finished moving.
 *   @param wasUserAction A Boolean indicating whether the map move was in response to a user action or not. */
- (void)afterMapMove:(RMMapView *)map byUser:(BOOL)wasUserAction{
    NSLog(@"after move zoom: %f",map.zoom);
    BOOL cluster = map.zoom < CLUSTER_ZOOM ? YES : NO;
    [self.mapView setClusteringEnabled:cluster];
    NSLog(@"cluster ?: %d",self.mapView.clusteringEnabled);
    
	if (self.readyToQueryMarkers)// && wasUserAction)
	{
        RMSphericalTrapezium boundsend = self.mapView.latitudeLongitudeBoundingBox;
        CLLocationCoordinate2D center= self.mapView.centerCoordinate;
        
        NSDictionary *parameters = @{@"type": @"move",
                                     @"LON1s": [NSString stringWithFormat:@"%f", self.boundsstart.southWest.longitude],
                                     @"LON2s": [NSString stringWithFormat:@"%f",self.boundsstart.northEast.longitude],
                                     @"LAT1s": [NSString stringWithFormat:@"%f",self.boundsstart.southWest.latitude ],
                                     @"LAT2s": [NSString stringWithFormat:@"%f",self.boundsstart.northEast.latitude ],
                                     @"LON1e": [NSString stringWithFormat:@"%f",boundsend.southWest.longitude ],
                                     @"LAT1e": [NSString stringWithFormat:@"%f",boundsend.southWest.latitude ],
                                     @"LON2e": [NSString stringWithFormat:@"%f",boundsend.northEast.longitude ],
                                     @"LAT2e": [NSString stringWithFormat:@"%f",boundsend.northEast.latitude ],
                                     @"lon": [NSString stringWithFormat:@"%f",center.longitude ],
                                     @"lat": [NSString stringWithFormat:@"%f",center.latitude ]
                                     };
        [self getAndAddTerrassesWithParameters:parameters];
    }
};

/** When a map is about to move.
 *   @param mapView The map view that is about to move.
 *   @param wasUserAction A Boolean indicating whether the map move is in response to a user action or not. */
- (void)beforeMapZoom:(RMMapView *)map byUser:(BOOL)wasUserAction
{
	if (self.readyToQueryMarkers && wasUserAction)
	{
        self.boundsstart = map.latitudeLongitudeBoundingBox;
        NSLog(@"before zoom: %f",self.boundsstart.northEast.latitude);
    }
};

/** When a map has finished moving.
 *   @param map The map view that has finished moving.
 *   @param wasUserAction A Boolean indicating whether the map move was in response to a user action or not. */
- (void)afterMapZoom:(RMMapView *)map byUser:(BOOL)wasUserAction {
    
    NSLog(@"after zoom: %f",map.zoom);
    BOOL cluster = map.zoom < CLUSTER_ZOOM ? YES : NO;
    [self.mapView setClusteringEnabled:cluster];
    NSLog(@"cluster ?: %d",self.mapView.clusteringEnabled);
    
	if (self.readyToQueryMarkers && wasUserAction)
	{
        RMSphericalTrapezium boundsend = self.mapView.latitudeLongitudeBoundingBox;
        CLLocationCoordinate2D center= self.mapView.centerCoordinate;
        
        NSDictionary *parameters = @{@"type": @"move",
                                     @"LON1s": [NSString stringWithFormat:@"%f", self.boundsstart.southWest.longitude],
                                     @"LON2s": [NSString stringWithFormat:@"%f",self.boundsstart.northEast.longitude],
                                     @"LAT1s": [NSString stringWithFormat:@"%f",self.boundsstart.southWest.latitude ],
                                     @"LAT2s": [NSString stringWithFormat:@"%f",self.boundsstart.northEast.latitude ],
                                     @"LON1e": [NSString stringWithFormat:@"%f",boundsend.southWest.longitude ],
                                     @"LAT1e": [NSString stringWithFormat:@"%f",boundsend.southWest.latitude ],
                                     @"LON2e": [NSString stringWithFormat:@"%f",boundsend.northEast.longitude ],
                                     @"LAT2e": [NSString stringWithFormat:@"%f",boundsend.northEast.latitude ],
                                     @"lon": [NSString stringWithFormat:@"%f",center.longitude ],
                                     @"lat": [NSString stringWithFormat:@"%f",center.latitude ]
                                     };
        [self getAndAddTerrassesWithParameters:parameters];
    }
};

- (RMMapLayer *)mapView:(RMMapView *)mapView layerForAnnotation:(RMAnnotation *)annotation
{
    if (annotation.isUserLocationAnnotation)
        return nil;
    
    RMMarker *marker = nil;
    
    if (annotation.isClusterAnnotation)
    {
        marker = [[RMMarker alloc] initWithUIImage:[UIImage imageNamed:@"circle.png"]];
        
        marker.opacity = 1;//0.75;
        
        marker.bounds = CGRectMake(0, 0, 75, 75);
        
        [(RMMarker *)marker setTextForegroundColor:[UIColor whiteColor]];
        
        [(RMMarker *)marker changeLabelUsingText:[NSString stringWithFormat:@"%i", [annotation.clusteredAnnotations count]]];
    }
    else
    {
        
        /** Initializes and returns a newly allocated marker object using the specified image and anchor point.
         *   @param image An image to use for the marker.
         *   @param anchorPoint A point representing a range from `0` to `1` in each of the height and width coordinate space, normalized to the size of the image, at which to place the image.
         *   @return An initialized marker object. */
        //- (id)initWithUIImage:(UIImage *)image anchorPoint:(CGPoint)anchorPoint;
        UIImage * img = nil;
        UIImage * img2 = nil;
        if ([[annotation.userInfo objectForKey:@"sunny"] intValue] > 0)
        {
            img = [UIImage imageNamed: @"leaf-sun.png"];
            img2 = [UIImage imageNamed: @"settingsun.png"];
        } else {
            img = [UIImage imageNamed: @"leaf-shadow.png"];
            img2 = [UIImage imageNamed: @"risingsun.png"];
        }
        marker = [[RMMarker alloc] initWithUIImage:img anchorPoint:CGPointMake(0.5, 1)];
        
        marker.canShowCallout = YES;
        
        marker.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        
        marker.leftCalloutAccessoryView = [[UIImageView alloc] initWithImage:img2];
        /*   if (self.activeFilterTypes)
         marker.hidden = ! [self.activeFilterTypes containsObject:[annotation.userInfo objectForKey:@"marker-symbol"]];*/
    }
    return marker;
}

- (void)tapOnCalloutAccessoryControl:(UIControl *)control forAnnotation:(RMAnnotation *)annotation onMap:(RMMapView *)map
{
    NSLog(@"tapOnCalloutAccessoryControl");
    [self performSegueWithIdentifier: @"Terrasse" sender: annotation];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
	if ([segue.identifier isEqualToString:@"Favoris"])
	{
		UINavigationController *navigationController =
        segue.destinationViewController;
		
        FavorisTableViewController
        *favorisTableViewController =
        [[navigationController viewControllers]
         objectAtIndex:0];
		
        favorisTableViewController.delegate = self;
        
	} else if ([segue.identifier isEqualToString:@"Terrasse"]) {
        NSLog(@"prepareForSegue");
        
        RMAnnotation *annotation = (RMAnnotation *)sender;
        
		TerrasseTableViewController *terrasseTableViewController =
        segue.destinationViewController;
        
//        terrasseTableViewController.delegate = self;
        terrasseTableViewController.terrasseNumber = [annotation.userInfo objectForKey:@"num"];
    }
}

- (IBAction)unwindToMap:(UIStoryboardSegue *)unwindSegue
{
    UIViewController* sourceViewController = unwindSegue.sourceViewController;
    
    if ([sourceViewController isKindOfClass:[TerrasseTableViewController class]])
    {
        NSLog(@"Coming from TerrasseTableViewController!");
        TerrasseTableViewController * terrass = (TerrasseTableViewController *)sourceViewController;
        NSDictionary * place = terrass.terr_info;
        CLLocationCoordinate2D markercoord = CLLocationCoordinate2DMake([[place latitude] doubleValue], [[place longitude] doubleValue]);
        [self.mapView setCenterCoordinate:markercoord];
        
        // Open annotation
        //NSDictionary *userinfo2 = [NSDictionary dictionaryWithObjectsAndKeys:[place num],@"num", [place nombresoleil], @"sunny", [place timenext], @"timenext", nil ];//,@"value2",@"key2", nil];
        for (id<MKAnnotation> currentAnnotation in self.mapView.annotations) {
            if ([currentAnnotation.title isEqual:[place placename_ter]]){
                [self.mapView selectAnnotation:currentAnnotation animated:FALSE];
            }
        }
    }
 /*   else if ([sourceViewController isKindOfClass:[GreenViewController class]])
    {
        NSLog(@"Coming from GREEN!");
    }*/
}

#pragma mark - FavorisTableViewControllerDelegate

- (void)favorisTableViewControllerDidQuit:
(FavorisTableViewController *)controller
{
	[self dismissViewControllerAnimated:YES completion:nil];
}

@end
