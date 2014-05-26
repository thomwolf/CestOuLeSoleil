//
//  TerrasseTableViewController.m
//  CestOuLeSoleil
//
//  Created by Thomas Wolf on 13/05/14.
//
//

#import "TerrasseTableViewController.h"

@interface TerrasseTableViewController ()
@property (strong, nonatomic) NSNumber *first_time;
@property (nonatomic) int val_count;
@property (strong, nonatomic) NSArray * terr_time_table;

@property (strong) NSMutableArray *favorites;

@end

@implementation TerrasseTableViewController

static NSString * const BaseURLString = @"http://terrasses.alwaysdata.net/";
static NSString * const MarkerURLString = @"http://terrasses.alwaysdata.net/images/leaf-sun.png";
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSLog(@"%@", [self.terrasseNumber stringValue]);
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    self.favorites = [defaults mutableArrayValueForKey:@"favorites"];
    
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    NSString *string = [NSString stringWithFormat:@"%@position2.php", BaseURLString];
    
    NSDictionary *parameters = @{@"type": @"marker",
                                 @"num": [self.terrasseNumber stringValue]
                                 };
    
    NSURLRequest *request = [[AFHTTPRequestSerializer serializer] requestWithMethod:@"GET" URLString:string parameters:parameters error:nil];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    
    NSLog(@"%@", [request debugDescription]);
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        // 3
        NSDictionary * terrasseDescription = (NSDictionary *)responseObject;
        NSLog(@"%@", @"Youhou");
        NSLog(@"%@", terrasseDescription.description);
        self.terr_info = [terrasseDescription terr_info];
        self.first_time = [terrasseDescription first_time];
        self.val_count = [[terrasseDescription max_time] intValue] + 1;
        NSLog(@"val_count: %i", self.val_count);
        self.terr_info = [terrasseDescription terr_info];
        self.terr_time_table = [terrasseDescription terr_time_table];
        [self setupAll];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        // 4
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error Retrieving Weather"
                                                            message:[error localizedDescription]
                                                           delegate:nil
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles:nil];
        [alertView show];
    }];
    
    // 5
    [operation start];
}

- (void)setupAll{
    
    _terrasseName.text = [self.terr_info placename_ter]; //@"test";
    _terrasseType.text = [self.terr_info dosred_type]; //@"test";
    _terrasseAdresse.text = [NSString stringWithFormat:@"%@ %@",[self.terr_info address], [self.terr_info zip]]; //@"test";
    
    if ([self.favorites containsObject:self.terr_info]) {
        self.favorisLabel.text = @"Retirer des favoris";
    } else {
        self.favorisLabel.text = @"Ajouter aux favoris";
    }
    self.title = [self.terr_info placename_ter];
    
    
    NSString *markerURL = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)MarkerURLString, NULL, (CFStringRef)@"!*'();:@&=+$,/?%#[]", kCFStringEncodingUTF8));
    
    
    double lat = [[self.terr_info latitude] doubleValue];
    double lng = [[self.terr_info longitude] doubleValue];
    
    NSString * terimg = [NSString stringWithFormat:@"http://api.tiles.mapbox.com/v3/thomwolf.hkfl24gn/url-%@(%f,%f)/%f,%f,18/320x180.png",markerURL,lng,lat,lng,lat];
    
    NSLog(@"%@", terimg.description);
    
    [_imgview setImageWithURL:[NSURL URLWithString:terimg]];
    
    //---------------
    
    _sunList.delegate = self;
    
    [_sunList performSelector:@selector(refreshData) withObject:nil afterDelay:0.3f];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)imageClick:(id)sender {
    
}

-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *theCellClicked = [tableView cellForRowAtIndexPath:indexPath];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    //    UITableViewCell *staticCell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]];
    NSLog(@"%@", [NSString stringWithFormat:@"%i %i", indexPath.row, indexPath.section]);
    if (theCellClicked == _addToFavorites) {
        if (![self.favorites containsObject:self.terr_info]){
            NSLog(@"%@", @"add to favorite");
            self.favorisLabel.text = @"Retirer des favoris";
            
            [self.favorites addObject:self.terr_info];
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setValue:self.favorites forKey:@"favorites"];
            [defaults synchronize];
        } else {
            NSLog(@"%@", @"remove from favorite");
            self.favorisLabel.text = @"Ajouter aux favoris";
            
            [self.favorites removeObject:self.terr_info];
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setValue:self.favorites forKey:@"favorites"];
            [defaults synchronize];
        }
    }
}

- (BOOL)tableView:(UITableView *)tableView shouldShowMenuForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 3){
        return YES;
    } else {
        return NO;
    }
}

- (BOOL)tableView:(UITableView *)tableView canPerformAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender
{
    if (indexPath.row == 3){
        return (action == @selector(copy:));
    } else {
        return NO;
    }
}

- (void)tableView:(UITableView *)tableView performAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender
{
    if (indexPath.row == 3){
        if (action == @selector(copy:)) {
            NSLog(@"%@", @"We now copy somehow");
            UITableViewCell *staticCell = [tableView cellForRowAtIndexPath:indexPath];
            NSString *copyStringverse = staticCell.textLabel.text;
            UIPasteboard *pb = [UIPasteboard generalPasteboard];
            [pb setString:copyStringverse];
        }
    }
}

#pragma mark -
#pragma mark HorizontalTableViewDelegate methods

- (NSInteger)numberOfColumnsForTableView:(HorizontalTableView *)tableView {
    NSLog(@"%i", self.val_count);
    return self.val_count + 1;
}

- (UIView *)tableView:(HorizontalTableView *)aTableView viewForIndex:(NSInteger)index {
    
    UIView *vw = [aTableView dequeueColumnView];
    if (!vw) {
        //       NSLog(@"%@", @"Constructing new view");
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, 30, 30)];
        [label setText:@"8"];
        label.textAlignment = NSTextAlignmentCenter;
        label.tag=1234;
        
        UIImageView *img = [[UIImageView alloc] initWithFrame:CGRectMake(0, 40, 30, 30)];
        img.tag=4321;
        
        UIView *mView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 30, 60)];
        
        [mView addSubview:label];
        [mView addSubview:img];
        
        vw = mView;
    }
    [vw setBackgroundColor: [UIColor whiteColor]];
    //    NSLog(@"%@", vw.debugDescription);
    
    
    UILabel *lbl = (UILabel *)[vw viewWithTag:1234];
    int timeS = (int)index + [self.first_time intValue];
    
    lbl.text = [NSString stringWithFormat:@"%d", timeS];
    
    //   [lbl setCenter:CGPointMake(vw.frame.size.width / 2, 10.0)];
    
    UIImageView *imagg = (UIImageView *)[vw viewWithTag:4321];
    NSLog(@"index: %i", index);
    if (index == 0 || index == self.val_count){
        NSString * name = [NSString stringWithFormat: @"night.png"];
        NSLog(@"%@", name);
        imagg.image = [UIImage imageNamed: name];
    } else {
        int quarter = 4;
        if ([[[self.terr_time_table objectAtIndex:index] nombresoleil] intValue] == 0) {
            quarter = 0;
        }
        //(int) floor([[[self.terr_time_table objectAtIndex:index] nombresoleil] doubleValue]/nbrtot)*4;
        NSString * name = [NSString stringWithFormat:@"sun%d.png",quarter];
        NSLog(@"%@", name);
        imagg.image = [UIImage imageNamed: name];
    }
    
	return vw;
}

- (CGFloat)columnWidthForTableView:(HorizontalTableView *)tableView {
    return 30.0f;
}

@end
