//
//  MasterViewController.m
//  TodoList
//
//  Created by Sun Jin on 6/9/15.
//  Copyright (c) 2015 MaxLeap. All rights reserved.
//

#import "TodoListViewController.h"
#import "ItemsTableViewController.h"
#import <MaxLeap/MaxLeap.h>

@interface TodoListViewController () <UIAlertViewDelegate>

@property (nonatomic, strong) NSMutableArray *lists;

@end

@implementation TodoListViewController

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (BOOL)isLoggedIn {
    return [MLUser currentUser] &&  ! [MLAnonymousUtils isLinkedWithUser:[MLUser currentUser]];
}

- (MLUser *)currentUser {
    if ([self isLoggedIn]) {
        return [MLUser currentUser];
    } else {
        return nil;
    }
}

- (void)observeLoginOrSignupNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refresh) name:@"MLUserDidLoginNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refresh) name:@"MLUserDidSignupNotification" object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    UIBarButtonItem *logoutItem = [[UIBarButtonItem alloc] initWithTitle:@"Logout" style:UIBarButtonItemStyleBordered target:self action:@selector(logout)];
    self.navigationItem.leftBarButtonItem = logoutItem;

    UIBarButtonItem *addItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addButtonClicked:)];
    self.navigationItem.rightBarButtonItem = addItem;
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.tintColor = [UIColor darkGrayColor];
    [self.refreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    
    self.lists = [NSMutableArray array];
    
    if ([self isLoggedIn]) {
        [self refresh];
    }
    [self observeLoginOrSignupNotifications];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (! [self isLoggedIn]) {
        [self showLoginView];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showListItems"]) {
        ItemsTableViewController *itemsController = (ItemsTableViewController *)segue.destinationViewController;
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        itemsController.list = self.lists[indexPath.row];
    }
}

- (void)showLoginView {
    [self performSegueWithIdentifier:@"showLoginView" sender:nil];
}

- (void)logout {
    [MLUser logOut];
    [self.lists removeAllObjects];
    [self.tableView reloadData];
    [self showLoginView];
}

- (void)refresh {
    if (NO == self.refreshControl.isRefreshing) {
        [self.refreshControl beginRefreshing];
        [self.tableView setContentOffset:CGPointMake(0, self.tableView.contentOffset.y-self.refreshControl.frame.size.height) animated:YES];
    }
    
    if ( ! [self isLoggedIn]) {
        [self.refreshControl endRefreshing];
        return;
    }
    
    #warning 请前往 MaxLeap 控制台，确保 Lists 表的权限已经设置为 “私有“
    
    // Create a query object targeting Lists Class.
    MLQuery *query = [MLQuery queryWithClassName:@"Lists"];
    // Sort the results ordering by updatedAt descending
    [query orderByDescending:@"updatedAt"];
    if (query) {
        // Run the query
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (error) {
                NSLog(@"query failed, error: %@", error);
            } else {
                [self.lists removeAllObjects];
                [self.lists addObjectsFromArray:objects];
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

- (void)addAListWithName:(NSString *)name {
    
    // Create an object with class name "Lists"
    // The ACL of class "Lists" has been set to "Private(only creator have access)" on the console.
    MLObject *list = [MLObject objectWithClassName:@"Lists"];
    if (name) {
        list[@"Name"] = name;
    }
    
    [list saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            [self.lists insertObject:list atIndex:0];
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
            [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        } else {
            // error occurred
            NSString *message = [NSString stringWithFormat:@"code: %ld, %@", (long)error.code, error.localizedDescription];
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alertView show];
        }
    }];
}

#pragma mark -
#pragma mark UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag != 101) {
        return;
    }
    
    if (buttonIndex == alertView.firstOtherButtonIndex) {
        UITextField *textField = [alertView textFieldAtIndex:0];
        [self addAListWithName:textField.text];
    }
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.lists.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];

    MLObject *list = self.lists[indexPath.row];
    cell.textLabel.text = list[@"Name"];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        MLObject *todo = [self.lists objectAtIndex:indexPath.row];
        [todo deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                [self.lists removeObjectAtIndex:indexPath.row];
                [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            } else {
                // error occurred
                NSString *message = [NSString stringWithFormat:@"code: %ld, %@", (long)error.code, error.localizedDescription];
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alertView show];
            }
        }];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }
}

@end
