//
//  LoginViewController.m
//  live
//
//  Created by hysd on 15/7/29.
//  Copyright (c) 2015年 kenneth. All rights reserved.
//

#import "LoginViewController.h"
#import "Macro.h"
#import "Common.h"
#import "MBProgressHUD.h"
#import "UserInfo.h"
#import "RegisterViewController.h"
#import "MultiIMManager.h"
#import "Business.h"
#import "TLSLogin.h"
#import "MainTabBarController.h"
#import "LiveAlertView.h"
@interface LoginViewController ()<TLSSmsLoginListenerImplDelegate>
{
    MBProgressHUD *HUD;
    
    NSTimer *authTimer;
    NSInteger nextAuthTime;
}
@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    self.authContainerView.backgroundColor = RGBA16(COLOR_BG_ALPHAWHITE);
    self.authContainerView.layer.cornerRadius = self.authContainerView.frame.size.height/2;
    self.authContainerView.layer.borderColor = RGB16(COLOR_BG_WHITE).CGColor;
    self.authContainerView.layer.borderWidth = 1;
    self.phoneContainerView.backgroundColor = RGBA16(COLOR_BG_ALPHAWHITE);
    self.phoneContainerView.layer.cornerRadius = self.phoneContainerView.frame.size.height/2;
    self.phoneContainerView.layer.borderColor = RGB16(COLOR_BG_WHITE).CGColor;
    self.phoneContainerView.layer.borderWidth = 1;
    
    //切换环境
    self.switchControl.selectedSegmentIndex = [UserInfo sharedInstance].environment;
    self.switchControl.backgroundColor = [UIColor clearColor];
    self.switchControl.tintColor = RGB16(COLOR_BG_RED);
    
    self.switchControl.hidden = YES;
    
    if([UserInfo sharedInstance].isLogin){
        //日志上报
        NSString* log = [[UserInfo sharedInstance] getCrash];
        if(![log isEqualToString:@""]){
            [[Business sharedInstance] logReport:[UserInfo sharedInstance].userPhone log:log];
        }
        //关闭未关闭的直播间
        if([UserInfo sharedInstance].isInLiveRoom){
            if(LIVE_DOING == [UserInfo sharedInstance].liveType){
                [[Business sharedInstance] closeRoom:[UserInfo sharedInstance].liveRoomId succ:^(NSString *msg, id data) {
                    [[UserInfo sharedInstance] resetLiveInfo];
                } fail:^(NSString *error) {
                }];
            }
            if(LIVE_WATCH == [UserInfo sharedInstance].liveType){
                [[Business sharedInstance] leaveRoom:[UserInfo sharedInstance].liveRoomId phone:[UserInfo sharedInstance].userPhone succ:^(NSString *msg, id data) {
                    [[UserInfo sharedInstance] resetLiveInfo];
                } fail:^(NSString *error) {
                }];
            }
        }
    }
    
    self.scrollView.backgroundColor = [UIColor clearColor];
    self.contentView.backgroundColor = [UIColor clearColor];
    self.scrollView.scrollEnabled = NO;
    if( ([[[UIDevice currentDevice] systemVersion] doubleValue]>=7.0)) {
        self.navigationController.navigationBar.translucent = NO;
    }
    
    self.accountTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"请输入手机号码" attributes:@{NSForegroundColorAttributeName: RGB16(COLOR_FONT_LIGHTWHITE)}];
    self.accountTextField.borderStyle = UITextBorderStyleNone;
    self.accountTextField.text = [UserInfo sharedInstance].userPhone;
    self.accountTextField.textColor = RGB16(COLOR_FONT_WHITE);
    
    self.authTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"请输入验证码" attributes:@{NSForegroundColorAttributeName: RGB16(COLOR_FONT_LIGHTWHITE)}];
    self.authTextField.borderStyle = UITextBorderStyleNone;
    self.authTextField.textColor = RGB16(COLOR_FONT_WHITE);
    
    self.loginButton.backgroundColor = RGB16(COLOR_BG_RED);
    self.loginButton.layer.cornerRadius = self.loginButton.frame.size.height/2;
    self.loginButton.clipsToBounds = YES;
    
    self.registerButton.backgroundColor = [UIColor clearColor];
    self.registerButton.layer.cornerRadius = self.registerButton.frame.size.height/2;
    self.registerButton.layer.borderWidth = 1;
    self.registerButton.layer.borderColor = RGB16(COLOR_BG_WHITE).CGColor;
    self.registerButton.clipsToBounds = YES;
    
    self.authCodeButton.backgroundColor = RGB16(COLOR_BG_RED);
    self.authCodeButton.layer.cornerRadius = self.authCodeButton.frame.size.height/2;
    self.authCodeButton.clipsToBounds = YES;
    //为TextField添加inputAccessoryView
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-55, 5, 50.0f, 30.0f)];
    button.layer.cornerRadius = 4;
    [button setBackgroundColor:RGB16(COLOR_FONT_RED)];
    button.titleLabel.font = [UIFont systemFontOfSize: 15.0];
    [button setTitle:@"完成" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(completeInput) forControlEvents:UIControlEventTouchUpInside];
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 40.0f)];
    [toolbar addSubview:button];
    toolbar.backgroundColor = RGB16(COLOR_BG_LIGHTGRAY);
    self.authTextField.inputAccessoryView = toolbar;
    self.accountTextField.inputAccessoryView = toolbar;
    
    //初始化MBProgressHUD
    HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:HUD];
    [HUD show:YES];
    HUD.hidden = YES;
    
    //已经登录了
    if([UserInfo sharedInstance].isLogin){
        self.accountTextField.text = [UserInfo sharedInstance].userPhone;
        //登录到IM服务器
        [HUD showText:@"正在登录IM" atMode:MBProgressHUDModeIndeterminate];
        [[MultiIMManager sharedInstance]
         loginPhone:[UserInfo sharedInstance].userPhone
         sig:[UserInfo sharedInstance].userSig
         succ:^(NSString* msg){
             [HUD hideText:msg
                    atMode:MBProgressHUDModeText
                  andDelay:1
             andCompletion:^{
                 MainTabBarController* main = [[MainTabBarController alloc] init];
                 [self presentViewController:main animated:YES completion:nil];
             }];
         }
         fail:^(NSString *err) {
             [HUD hideText:err
                    atMode:MBProgressHUDModeText
                  andDelay:1
             andCompletion:^{
             }];
             self.authTextField.text = @"";
         }];
    }
    
}
- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}
- (void)viewWillAppear:(BOOL)animated{
    //添加键盘监听
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}
- (void)viewWillDisappear:(BOOL)animated{
    //删除监听
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark 键盘通知
- (void)keyboardWasShown:(NSNotification*)aNotification
{
    [self.scrollView setContentOffset:CGPointMake(0, 50)];
}
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    [self.scrollView setContentOffset:CGPointMake(0, 0)];
}
#pragma mark 输入框隐藏
-(void)completeInput{
    [self.accountTextField resignFirstResponder];
    [self.authTextField resignFirstResponder];
}

#pragma mark 登录
- (IBAction)login:(id)sender{
    //参数判断
    if(![[Common sharedInstance] isValidateMobile:self.accountTextField.text]){
        [[Common sharedInstance] shakeView:self.accountTextField.superview];
        return;
    }
    if([self.authTextField.text  isEqualToString:@""]){
        [[Common sharedInstance] shakeView:self.authTextField.superview];
        return;
    }
    [self.accountTextField resignFirstResponder];
    [self.authTextField resignFirstResponder];
    
    [HUD showText:@"正在登录服务器" atMode:MBProgressHUDModeIndeterminate];
    //验证验证码
    [[TLSLogin sharedInstance] verifyAuthCode:self.authTextField.text andPhone:self.accountTextField.text];
}

#pragma mark 切换环境
- (IBAction)switchEnvironment:(id)sender {
    LiveAlertView* alert = [[LiveAlertView alloc] init];
    [alert showTitle:@"切换环境需要退出应用" confirmTitle:@"退出应用" cancelTitle:@"暂不退出" confirm:^{
        [[UserInfo sharedInstance] setEnv:[NSNumber numberWithInteger:self.switchControl.selectedSegmentIndex]];
        [HUD hideText:@"正在退出App" atMode:MBProgressHUDModeIndeterminate andDelay:1 andCompletion:^{
            exit(0);
        }];
    } cancel:^{
        
        //取消切换
        self.switchControl.selectedSegmentIndex = !self.switchControl.selectedSegmentIndex;
    }];
}

#pragma mark 注册
- (IBAction)registerAccount:(id)sender {
    RegisterViewController* registerViewController = [[RegisterViewController alloc] init];
    [self.navigationController pushViewController:registerViewController animated:YES];
}

#pragma mark tls login

- (IBAction)auth:(id)sender {
    if(![[Common sharedInstance] isValidateMobile:self.accountTextField.text]){
        [[Common sharedInstance] shakeView:self.accountTextField.superview];
        return;
    }
    [HUD showText:@"发送请求" atMode:MBProgressHUDModeIndeterminate];
    //代理
    [TLSLogin sharedInstance].smsLoginListenerImpl.delegate = self;
    //获取验证码
    [[TLSLogin sharedInstance] askAuthCode:self.accountTextField.text];
}
- (void)authTick{
    nextAuthTime = nextAuthTime - 1;
    if(nextAuthTime == 0){
        [authTimer invalidate];
        authTimer = nil;
        self.authCodeButton.enabled = true;
        self.authCodeButton.backgroundColor = RGB16(COLOR_BG_RED);
        [self.authCodeButton setTitleColor:RGB16(COLOR_FONT_WHITE) forState:UIControlStateNormal];
        [self.authCodeButton setTitle:@"获取验证码" forState:UIControlStateNormal];
    }
    else{
        [self.authCodeButton setTitle:[NSString stringWithFormat:@"重新发送(%ld)",(long)nextAuthTime] forState:UIControlStateDisabled];
    }
}

- (void)waitAuthCode:(int)duration{
    //倒计时
    self.authCodeButton.enabled = false;
    self.authCodeButton.backgroundColor = RGB16(COLOR_BG_GRAY);
    [self.authCodeButton setTitleColor:RGB16(COLOR_FONT_LIGHTGRAY) forState:UIControlStateNormal];
    nextAuthTime = duration;
    [self.authCodeButton setTitle:[NSString stringWithFormat:@"重新发送(%ld)",(long)nextAuthTime] forState:UIControlStateDisabled];
    authTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(authTick) userInfo:nil repeats:YES];
}

- (void)OnSmsLoginAskCodeSuccess:(int)reaskDuration andExpireDuration:(int)expireDuration{
    [HUD hideText:@"请求成功" atMode:MBProgressHUDModeText andDelay:1 andCompletion:^{
        [self waitAuthCode:reaskDuration];
    }];
}
- (void)OnSmsLoginFail:(TLSErrInfo *)errInfo{
    [HUD hideText:errInfo.sErrorMsg atMode:MBProgressHUDModeText andDelay:1 andCompletion:^{
        self.authTextField.text = @"";
    }];
    if(0 == nextAuthTime){
        [self waitAuthCode:30];
    }
    else{
        nextAuthTime = 30;
    }
}
- (void)OnSmsLoginReaskCodeSuccess:(int)reaskDuration andExpireDuration:(int)expireDuration{
    [HUD hideText:@"请求成功" atMode:MBProgressHUDModeText andDelay:1 andCompletion:^{
        [self waitAuthCode:reaskDuration];
    }];
}
- (void)OnSmsLoginSuccess:(TLSUserInfo *)userInfo{
    //获取签名
    NSString* userSig = [[TLSLogin sharedInstance].loginHelper getTLSUserSig:userInfo.identifier];
    if(userSig == nil){
        [HUD hideText:@"获取签名为空" atMode:MBProgressHUDModeText andDelay:1 andCompletion:nil];
        return;
    }
    //登录到IM服务器
    [HUD showText:@"正在登录IM" atMode:MBProgressHUDModeIndeterminate];
    [[MultiIMManager sharedInstance]
     loginPhone:self.accountTextField.text
     sig:userSig
     succ:^(NSString* loginMsg){
         [[Business sharedInstance] getUserInfoByPhone:self.accountTextField.text succ:^(NSString *msg, id data) {
             [[UserInfo sharedInstance] setUserFromDBSig:userSig andInfo:data];
             [HUD hideText:loginMsg
                    atMode:MBProgressHUDModeText
                  andDelay:1
             andCompletion:^{
                 MainTabBarController* main = [[MainTabBarController alloc] init];
                 [self presentViewController:main animated:YES completion:nil];
             }];
         } fail:^(NSString *error) {
             self.authTextField.text = @"";
             [HUD hideText:error
                    atMode:MBProgressHUDModeText
                  andDelay:1
             andCompletion:^{
             }];
         }];
     }
     fail:^(NSString *err) {
         self.authTextField.text = @"";
         [HUD hideText:err
                atMode:MBProgressHUDModeText
              andDelay:1
         andCompletion:^{
         }];
     }];
}
- (void)OnSmsLoginTimeout:(TLSErrInfo *)errInfo{
    [HUD hideText:errInfo.sErrorMsg atMode:MBProgressHUDModeText andDelay:1 andCompletion:nil];
}
- (void)OnSmsLoginVerifyCodeSuccess{
    [[TLSLogin sharedInstance] loginCommit:self.accountTextField.text];
}
@end
