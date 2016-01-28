//
//  UserLoginTestViewController.m
//  TodoList
//
//  Created by Sun Jin on 7/16/14.
//  Copyright (c) 2014 MaxLeap. All rights reserved.
//

#import "LoginViewController.h"
#import "SignUpViewController.h"
#import <MaxLeap/MaxLeap.h>

@interface LoginViewController () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *usernameField;
@property (weak, nonatomic) IBOutlet UILabel *usernamePromtLabel;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UILabel *passwordPromtLabel;
@end

@implementation LoginViewController

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
    // Do any additional setup after loading the view.
    self.usernamePromtLabel.text = nil;
    self.passwordPromtLabel.text = nil;
}

#pragma mark -

- (IBAction)signIn:(id)sender {
    NSString *username = self.usernameField.text;
    NSString *password = self.passwordField.text;
    if (username.length == 0) {
        [self.usernameField becomeFirstResponder];
        self.usernamePromtLabel.text = @"Please enter your username!";
        return;
    }
    if (password.length == 0) {
        [self.passwordField becomeFirstResponder];
        self.passwordPromtLabel.text = @"Please enter your password!";
        return;
    }
    
    [MLUser logInWithUsernameInBackground:username password:password block:^(MLUser *user, NSError *error) {
        if (user) {
            NSLog(@"user: %@, isNew: %d", user, user.isNew);
            [self dismissViewControllerAnimated:YES completion:nil];
        } else {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Login Failed" message:[NSString stringWithFormat:@"Code: %ld\n%@", (long)error.code, error.localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alertView show];
        }
    }];
}


#pragma mark -
#pragma mark UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if ([textField isEqual:self.usernameField]) {
        self.usernamePromtLabel.text = nil;
    } else if ([textField isEqual:self.passwordField]) {
        self.passwordPromtLabel.text = nil;
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if ([textField isEqual:self.usernameField]) {
        [self.passwordField becomeFirstResponder];
    } else if ([textField isEqual:self.passwordField]) {
        [textField resignFirstResponder];
    }
    return YES;
}

@end
