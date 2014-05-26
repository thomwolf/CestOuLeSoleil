//
//  FavorisTableViewController.m
//  CestOuLeSoleil
//
//  Created by Thomas Wolf on 13/05/14.
//
//

#import "FavorisTableViewController.h"
#import "TerrasseTableViewController.h"

@interface FavorisTableViewController ()

@property (strong, nonatomic) NSNumber *first_time;
@property (strong, nonatomic) NSNumber *max_time;
@property (strong, nonatomic) NSDictionary * terr_info;
@property (strong, nonatomic) NSArray * terr_time_table;
@property (strong, nonatomic) NSArray *favoritesInfo;
@property (strong, nonatomic) NSMutableDictionary *favoritesInfoSun;

@end

@implementation FavorisTableViewController

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
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    self.favoritesInfo = [defaults arrayForKey:@"favorites"];
    self.favoritesInfoSun = [NSMutableDictionary dictionary];
    
    NSString *string = [NSString stringWithFormat:@"%@position2.php", BaseURLString];
    
    NSLog(@"%@", self.favoritesInfo.debugDescription);
    for (id item in self.favoritesInfo) {
        NSDictionary *parameters = @{@"type": @"favorite",
                                     @"num": [[item num]  stringValue]
                                     };
        
        NSURLRequest *request = [[AFHTTPRequestSerializer serializer] requestWithMethod:@"GET" URLString:string parameters:parameters error:nil];
        
        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
        operation.responseSerializer = [AFJSONResponseSerializer serializer];
        
        NSLog(@"%@", [request debugDescription]);
        
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            // 3
            NSDictionary * terrasseDescription = (NSDictionary *)responseObject;
            NSLog(@"%@", @"Youhou");
            //            NSLog(@"%@", terrasseDescription.debugDescription);
            //CREATE OR REPLACE FUNCTION terrasses_favorite(ternum integer, timenum integer) RETURNS table(num integer, address varchar, zip char(5), longitude double precision, latitude double precision, placename_ter varchar, dosred_type varchar, nombretot bigint, nombresoleil bigint, timenext integer)  AS
            self.first_time = [terrasseDescription first_time];
            
            NSLog(@"first time: %@", [self.first_time debugDescription]);
            
            NSDictionary * place = [[terrasseDescription tableau] objectAtIndex:0];
            
            NSLog(@"place: %@", [place debugDescription]);
            
            [self.favoritesInfoSun setObject:place forKey:[[item num]  stringValue]];
            NSLog(@"%@", [self.favoritesInfoSun debugDescription]);
            NSLog(@"Ok favori");
            [self.tableView reloadData];
            
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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    NSLog(@"%i", [self.favoritesInfo count]);
    return [self.favoritesInfo count];
}

- (IBAction)done:(id)sender
{
	[self.delegate favorisTableViewControllerDidQuit:self];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"%@", self.favoritesInfo.debugDescription);
    
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    NSLog(@"%@", @"Youhou");
    // Display recipe in the table cell
    NSDictionary * terrasseDescription = [self.favoritesInfo objectAtIndex:indexPath.row];
    NSLog(@"%@", terrasseDescription.debugDescription);
    
    NSLog(@"%@", @"num:");
    NSLog(@"%@", [[terrasseDescription num] stringValue]);
    
    NSDictionary * terrasseDescriptionSun = [self.favoritesInfoSun objectForKey:[[terrasseDescription num] stringValue]];
    
    NSLog(@"%@", @"terrasseDescriptionSun:");
    NSLog(@"%@", terrasseDescriptionSun.debugDescription);
    
    UIImageView *terImageView = (UIImageView *)[cell viewWithTag:100];
    NSLog(@"%@", terImageView.debugDescription);
    

        if (terrasseDescriptionSun != nil) {
            if ([[terrasseDescriptionSun nombresoleil] intValue] > 0)
            {
                terImageView.image = [UIImage imageNamed: @"sun4.png"];
                NSLog(@"%@", @"leaf-sun.png");
                //img2 = [UIImage imageNamed: @"settingsun.png"];
            } else {
                terImageView.image = [UIImage imageNamed: @"sun0.png"];
                //img2 = [UIImage imageNamed: @"risingsun.png"];
                NSLog(@"%@", @"leaf-shadow.png");
            }
        }
    
    UILabel *terNameLabel = (UILabel *)[cell viewWithTag:101];
    NSLog(@"%@", terNameLabel.debugDescription);
    terNameLabel.text = [terrasseDescription placename_ter];
    NSLog(@"%@", [terrasseDescription placename_ter]);
    NSLog(@"%@", terNameLabel.text);
    NSLog(@"%@", @"Youhou");
    
    UILabel *terAddressLabel = (UILabel *)[cell viewWithTag:102];
    NSLog(@"%@", terAddressLabel.debugDescription);
    terAddressLabel.text = [terrasseDescription dosred_type];
    NSLog(@"%@", [terrasseDescription dosred_type]);
    NSLog(@"%@", terAddressLabel.text);
    NSLog(@"%@", @"Youhou");
    
    return cell;
}

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSLog(@"%@", @"tapOnCalloutAccessoryControl");
    NSDictionary * terrasseDescription = [self.favoritesInfo objectAtIndex:indexPath.row];
    [self performSegueWithIdentifier: @"TerrasseFavorite" sender: terrasseDescription];
    
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"TerrasseFavorite"]) {
        NSLog(@"%@", @"prepareForSegue");
        
        NSDictionary * terrasseDescription = (NSDictionary *)sender;
        
        TerrasseTableViewController *terrasseTableViewController =
        segue.destinationViewController;
        
        terrasseTableViewController.terrasseNumber = [terrasseDescription num];
    }
}

// Reload view when we come back from TerrasseFavorite
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    //reload NSUserDefaults
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    self.favoritesInfo = [defaults arrayForKey:@"favorites"];
    [self.tableView reloadData]; // to reload selected cell
}

@end
