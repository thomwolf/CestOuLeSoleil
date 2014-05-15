//
//  TerrasseTableViewController.h
//  CestOuLeSoleil
//
//  Created by Thomas Wolf on 13/05/14.
//
//

#import <UIKit/UIKit.h>
#import "HorizontalTableView.h"

@interface TerrasseTableViewController : UITableViewController <HorizontalTableViewDelegate>

//@property (nonatomic, weak) id <TerrasseTableViewControllerDelegate> delegate;
@property (strong, nonatomic) NSNumber *terrasseNumber;
@property (strong, nonatomic) NSDictionary * terr_info;

@property (weak, nonatomic) IBOutlet UIImageView *imgview;
@property (weak, nonatomic) IBOutlet HorizontalTableView *sunList;
@property (weak, nonatomic) IBOutlet UILabel *terrasseName;
@property (weak, nonatomic) IBOutlet UILabel *terrasseType;
@property (weak, nonatomic) IBOutlet UILabel *terrasseAdresse;
@property (nonatomic, weak) IBOutlet UITableViewCell *addToFavorites;
@property (weak, nonatomic) IBOutlet UILabel *favorisLabel;

@end
