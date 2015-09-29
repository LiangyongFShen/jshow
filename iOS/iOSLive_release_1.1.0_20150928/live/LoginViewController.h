//
//  LoginViewController.h
//  live
//
//  Created by hysd on 15/7/29.
//  Copyright (c) 2015年 kenneth. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UITextField *accountTextField;
@property (weak, nonatomic) IBOutlet UITextField *authTextField;
@property (weak, nonatomic) IBOutlet UIButton *authCodeButton;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UIView *authContainerView;
@property (weak, nonatomic) IBOutlet UIView *phoneContainerView;
- (IBAction)login:(id)sender;
- (IBAction)switchEnvironment:(id)sender;
@property (weak, nonatomic) IBOutlet UISegmentedControl *switchControl;
- (IBAction)registerAccount:(id)sender;
- (IBAction)auth:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *registerButton;
@end
