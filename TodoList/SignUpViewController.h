//
//  MLLoginViewController.h
//  MaxLeap
//
//  Created by Sun Jin on 8/5/14.
//  Copyright (c) 2014 MaxLeap. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SignUpViewController : UIViewController <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UILabel *usernamePromtLabel;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UILabel *passwordPromtLabel;
@property (weak, nonatomic) IBOutlet UITextField *passwordAgainTextField;
@property (weak, nonatomic) IBOutlet UILabel *passwordAgainPromtLabel;

- (IBAction)signup:(id)sender;

@end
