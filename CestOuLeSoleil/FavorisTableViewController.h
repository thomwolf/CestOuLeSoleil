//
//  FavorisTableViewController.h
//  CestOuLeSoleil
//
//  Created by Thomas Wolf on 13/05/14.
//
//

#import <UIKit/UIKit.h>

@class FavorisTableViewController;

@protocol FavorisTableViewControllerDelegate <NSObject>
- (void)favorisTableViewControllerDidQuit:
(FavorisTableViewController *)controller;
@end

@interface FavorisTableViewController : UITableViewController

@property (nonatomic, weak) id <FavorisTableViewControllerDelegate> delegate;

- (IBAction)done:(id)sender;
@property (strong, nonatomic) IBOutlet UITableView *tableView;

@end
