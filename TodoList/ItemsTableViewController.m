//
//  ItemsTableViewController.m
//  LASTodoList
//
//  Created by Sun Jin on 10/13/15.
//  Copyright © 2015 ilegendsoft. All rights reserved.
//

#import "ItemsTableViewController.h"

@interface ItemsTableViewController () <UIAlertViewDelegate>

@property (nonatomic, strong) NSMutableArray *items;

@end

@implementation ItemsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    UIBarButtonItem *addItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addButtonClicked:)];
     self.navigationItem.rightBarButtonItem = addItem;
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.tintColor = [UIColor darkGrayColor];
    [self.refreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    
    self.title = self.list[@"Name"];
    
    self.items = [NSMutableArray array];
    
    [self refresh];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)refresh {
    if (NO == self.refreshControl.isRefreshing) {
        [self.refreshControl beginRefreshing];
        [self.tableView setContentOffset:CGPointMake(0, self.tableView.contentOffset.y-self.refreshControl.frame.size.height) animated:YES];
    }
    
    MLRelation *itemsRelation = [self.list relationForKey:@"Items"];
    MLQuery *query = [itemsRelation query];
    [query orderByDescending:@"updatedAt"];
    if (query) {
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (error) {
                NSLog(@"Failed to refresh, error: %@", error);
            } else {
                [self.items removeAllObjects];
                [self.items addObjectsFromArray:objects];
                [self.tableView reloadData];
            }
            [self.refreshControl endRefreshing];
        }];
    } else {
        [self.refreshControl endRefreshing];
    }
}

- (void)addButtonClicked:(id)sender {
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"New ToDo List" message:@"Title for new list:" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Create", nil];
    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    alertView.tag = 101;
    [alertView show];
}

- (void)addItemWithName:(NSString *)name {
    MLObject *item = [MLObject objectWithClassName:@"Items"];
    if (name) {
        item[@"Name"] = name;
    }
    [item saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            MLRelation *itemsRelation = [self.list relationForKey:@"Items"];
            [itemsRelation addObject:item];
            [self.list saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (succeeded) {
                    [self.items insertObject:item atIndex:0];
                    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                } else {
                    // error occurred
                    [self showError:error];
                }
            }];
        } else {
            // error occurred
            [self showError:error];
        }
    }];
}

- (void)showError:(NSError *)error {
    // error occurred
    NSString *message = [NSString stringWithFormat:@"code: %ld, %@", (long)error.code, error.localizedDescription];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alertView show];
}

#pragma mark -
#pragma mark UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag != 101) {
        return;
    }
    
    if (buttonIndex == alertView.firstOtherButtonIndex) {
        UITextField *textField = [alertView textFieldAtIndex:0];
        [self addItemWithName:textField.text];
    }
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    // Configure the cell...
    MLObject *item = self.items[indexPath.row];
    cell.textLabel.text = item[@"Name"];
    
    if ([item[@"Status"] boolValue]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    MLObject *item = self.items[indexPath.row];
    BOOL checked = [item[@"Status"] boolValue];
    item[@"Status"] = @( (BOOL) ! checked );
    [item saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewAutomaticDimension];
        } else {
            [self showError:error];
        }
    }];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        MLObject *item = self.items[indexPath.row];
        [item deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                [self.items removeObjectAtIndex:indexPath.row];
                [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            } else {
                [self showError:error];
            }
        }];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}

@end
