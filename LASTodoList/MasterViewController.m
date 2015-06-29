//
//  MasterViewController.m
//  LASTodoList
//
//  Created by Sun Jin on 6/9/15.
//  Copyright (c) 2015 ilegendsoft. All rights reserved.
//

#import "MasterViewController.h"
#import <LAS/LAS.h>

@interface MasterViewController ()

@property NSMutableArray *objects;
@end

@implementation MasterViewController

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.navigationItem.leftBarButtonItem = self.editButtonItem;

    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject:)];
    self.navigationItem.rightBarButtonItem = addButton;
    
    [self refresh];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)refresh {
    LASQuery *query = [LASQuery queryWithClassName:@"Todo"];
    [query orderByDescending:@"seq"];
    
    // fetch all Todo objects
    [LASQueryManager findObjectsInBackgroundWithQuery:query block:^(NSArray *objects, NSError *error) {
        self.objects = [objects mutableCopy];
        [self.tableView reloadData];
        if (error) {
            NSLog(@"query failed, error: %@", error);
        }
    }];
}

- (void)insertNewObject:(id)sender {
    if (!self.objects) {
        self.objects = [[NSMutableArray alloc] init];
    }
    
    LASObject *object = [LASObject objectWithClassName:@"Todo"];
    object[@"text"] = @"Sample Text";
    object[@"seq"] = @([[(LASObject *)self.objects.firstObject objectForKey:@"seq"] integerValue] + 1);
    
    [LASDataManager saveObjectInBackground:object block:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            [self.objects insertObject:object atIndex:0];
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
            [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        } else {
            // error occurred
        }
    }];
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.objects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];

    LASObject *object = self.objects[indexPath.row];
    cell.textLabel.text = object[@"text"];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"Sequence: %@", object[@"seq"]];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        LASObject *todo = [self.objects objectAtIndex:indexPath.row];
        [LASDataManager deleteObjectInBackground:todo block:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                [self.objects removeObjectAtIndex:indexPath.row];
                [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            } else {
                // error occurred
            }
        }];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }
}

@end
