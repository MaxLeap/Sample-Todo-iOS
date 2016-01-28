//
//  MLLoginViewController.m
//  MaxLeap
//
//  Created by Sun Jin on 8/5/14.
//  Copyright (c) 2014 MaxLeap. All rights reserved.
//

#import "SignUpViewController.h"
#import <MaxLeap/MaxLeap.h>

@implementation SignUpViewController

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
    self.passwordAgainPromtLabel.text = nil;
}

- (IBAction)signup:(id)sender {
    
    NSString *username = self.usernameTextField.text;
    NSString *password = self.passwordTextField.text;
    NSString *passwordAgain = self.passwordAgainTextField.text;
    
    if (username.length == 0) {
        [self.usernameTextField becomeFirstResponder];
        self.usernamePromtLabel.text = @"Please enter a username.";
        return;
    }
    
    if (password.length == 0 || NO == [password isEqualToString:passwordAgain]) {
        if (passwordAgain.length == 0) {
            [self.passwordAgainTextField becomeFirstResponder];
        } else {
            [self.passwordTextField becomeFirstResponder];
        }
        return;
    }
    
    
    MLUser *user = [MLUser user];
    user.username = username;
    user.password = password;
    [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (error) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Failed" message:[NSString stringWithFormat:@"Code: %ld\n%@", (long)error.code, error.localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
        } else {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"MLUserDidSignupNotification" object:self];
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }];
}

#pragma mark -
#pragma mark UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if ([textField isEqual:self.usernameTextField]) {
        self.usernamePromtLabel.text = nil;
    } else if ([textField isEqual:self.passwordTextField]) {
        self.passwordPromtLabel.text = nil;
    } else if ([textField isEqual:self.passwordAgainTextField]) {
        self.passwordAgainPromtLabel.text = nil;
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if ([textField isEqual:self.usernameTextField]) {
        if (textField.text.length == 0) {
            self.usernamePromtLabel.text = @"You cannot leave this empty!";
        }
    } else if ([textField isEqual:self.passwordTextField]) {
        if (textField.text.length == 0) {
            self.passwordPromtLabel.text = @"You cannot leave this empty!";
        }
    } else if ([textField isEqual:self.passwordAgainTextField]) {
        if (textField.text.length == 0 && self.passwordTextField.text.length == 0) {
            self.passwordAgainPromtLabel.text = @"You cannot leave this empty!";
        } else if (NO == [textField.text isEqualToString:self.passwordTextField.text]) {
            self.passwordAgainPromtLabel.text = @"These passwords don't match. Try Again?";
        }
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if ([textField isEqual:self.usernameTextField]) {
        [self.passwordTextField becomeFirstResponder];
    } else if ([textField isEqual:self.passwordTextField]) {
        [self.passwordAgainTextField becomeFirstResponder];
    } else if ([textField isEqual:self.passwordAgainTextField]) {
        [textField resignFirstResponder];
    }
    return YES;
}

@end
