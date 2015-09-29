//
//  RegisterViewController.m
//  live
//
//  Created by hysd on 15/7/29.
//  Copyright (c) 2015年 kenneth. All rights reserved.
//

#import "RegisterViewController.h"
#import "MBProgressHUD.h"
#import "Macro.h"
#import "Common.h"
#import "AFHTTPRequestOperationManager.h"
#import "TLSRegister.h"
#import "Business.h"
@interface RegisterViewController ()<UITextFieldDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate,UIActionSheetDelegate,TLSSmsRegListenerImplDelegate>
{
    MBProgressHUD *HUD;
    
    NSTimer *authTimer;
    NSInteger nextAuthTime;
    BOOL isHasLogo;
}
@end

@implementation RegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if( ([[[UIDevice currentDevice] systemVersion] doubleValue]>=7.0)) {
        self.navigationController.navigationBar.translucent = NO;
    }
    self.scrollView.backgroundColor = RGB16(COLOR_BG_LIGHTGRAY);
    self.contentView.backgroundColor = [UIColor clearColor];
    //导航栏
    self.navigationItem.title = @"注册";
    //头像
    self.logoImageView.layer.cornerRadius = self.logoImageView.frame.size.width/2;
    self.logoImageView.clipsToBounds = YES;
    self.logoImageView.layer.borderWidth = 2;
    self.logoImageView.layer.borderColor = RGB16(COLOR_BG_WHITE).CGColor;
    self.logoImageView.image = [UIImage imageNamed:@"userlogo"];
    self.logoImageView.userInteractionEnabled = YES;
    UITapGestureRecognizer* logoTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(logoTap:)];
    [self.logoImageView addGestureRecognizer:logoTap];
    
    self.view.backgroundColor = RGB16(COLOR_BG_LIGHTGRAY);
    self.phoneTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"请输入手机号码" attributes:@{NSForegroundColorAttributeName: RGB16(COLOR_FONT_LIGHTGRAY)}];
    self.phoneTextField.borderStyle = UITextBorderStyleNone;
    self.phoneTextField.delegate = self;
    
    self.nameTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"请输入您的昵称" attributes:@{NSForegroundColorAttributeName: RGB16(COLOR_FONT_LIGHTGRAY)}];
    self.nameTextField.borderStyle = UITextBorderStyleNone;
    self.nameTextField.delegate = self;
    
    self.authTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"请输入验证码" attributes:@{NSForegroundColorAttributeName: RGB16(COLOR_FONT_LIGHTGRAY)}];
    self.authTextField.borderStyle = UITextBorderStyleNone;
    self.authTextField.delegate = self;
    
    self.registerButton.backgroundColor = RGB16(COLOR_BG_RED);
    self.registerButton.layer.cornerRadius = 5;
    self.registerButton.clipsToBounds = YES;
    
    self.authCodeButton.backgroundColor = RGB16(COLOR_BG_RED);
    self.authCodeButton.layer.cornerRadius = 5;
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
    self.phoneTextField.inputAccessoryView = toolbar;
    self.nameTextField.inputAccessoryView = toolbar;
    self.authTextField.inputAccessoryView = toolbar;
    
    //初始化MBProgressHUD
    HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:HUD];
    [HUD show:YES];
    HUD.hidden = YES;
    
    //是否有头像
    isHasLogo = NO;
    //添加键盘监听
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

- (void)dealloc{
    //删除键盘监听
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    //定时器
    if(authTimer){
        [authTimer invalidate];
        authTimer = nil;
    }
}

#pragma mark 键盘通知
- (void)keyboardWasShown:(NSNotification*)aNotification
{
    CGRect curFrame;
    if([self.phoneTextField isFirstResponder]){
        curFrame = self.phoneTextField.superview.frame;
    }
    else if([self.nameTextField isFirstResponder]){
        curFrame = self.nameTextField.superview.frame;
    }
    else if([self.authTextField isFirstResponder]){
        curFrame = self.authTextField.superview.frame;
    }
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    CGFloat offset = kbSize.height - (self.view.frame.size.height - curFrame.origin.y - curFrame.size.height);
    [self.scrollView setContentOffset:CGPointMake(0, offset)];
}

- (void)keyboardWillBeHidden:(NSNotification*)aNotification{
    [self.scrollView setContentOffset:CGPointMake(0, 0)];
}
#pragma mark 输入框代理

- (void)completeInput{
    [self resignTextField];
}
- (void)resignTextField{
    [self.phoneTextField resignFirstResponder];
    [self.nameTextField resignFirstResponder];
    [self.authTextField resignFirstResponder];
}
#pragma mark 用户注册
- (IBAction)register:(id)sender {
    if(![[Common sharedInstance] isValidateMobile:self.phoneTextField.text]){
        [[Common sharedInstance] shakeView:self.phoneTextField.superview];
        return;
    }
    if([self.nameTextField.text  isEqualToString:@""]){
        [[Common sharedInstance] shakeView:self.nameTextField.superview];
        return;
    }
    if([self.authTextField.text  isEqualToString:@""]){
        [[Common sharedInstance] shakeView:self.authTextField.superview];
        return;
    }
    [self resignTextField];
    
    [HUD showText:@"正在注册" atMode:MBProgressHUDModeIndeterminate];
    //验证验证码
    [[TLSRegister sharedInstance] verifyAuthCode:self.authTextField.text];
}
#pragma mark 图片选择
- (void)logoTap:(UITapGestureRecognizer*)recognizer{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:@"取消"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"拍照",
                                  @"相册", nil];
    actionSheet.cancelButtonIndex = 2;
    [actionSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == actionSheet.cancelButtonIndex) {
        return;
    };
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    imagePicker.allowsEditing = YES;
    if (buttonIndex == 0 && [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    } else if (buttonIndex == 1 && [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    [self presentViewController:imagePicker animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    self.logoImageView.image = info[UIImagePickerControllerEditedImage];
    isHasLogo = YES;
    [picker dismissViewControllerAnimated:YES completion:nil];
    //显示在最上方
    [self.view bringSubviewToFront:HUD];
}

#pragma mark 验证码
- (IBAction)auth:(id)sender {
    if(![[Common sharedInstance] isValidateMobile:self.phoneTextField.text]){
        [[Common sharedInstance] shakeView:self.phoneTextField.superview];
        return;
    }
    [HUD showText:@"发送请求" atMode:MBProgressHUDModeIndeterminate];
    //代理
    [TLSRegister sharedInstance].smsRegListenerImpl.delegate = self;
    //获取验证码
    [[TLSRegister sharedInstance] askAuthCode:self.phoneTextField.text];
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
#pragma mark tls注册代理
- (void)OnSmsRegAskCodeSuccess:(int)reaskDuration andExpireDuration:(int)expireDuration{
    [HUD hideText:@"请求成功" atMode:MBProgressHUDModeText andDelay:1 andCompletion:^{
        [self waitAuthCode:reaskDuration];
    }];
}
- (void)OnSmsRegReaskCodeSuccess:(int)reaskDuration andExpireDuration:(int)expireDuration{
    [HUD hideText:@"请求成功" atMode:MBProgressHUDModeText andDelay:1 andCompletion:^{
        [self waitAuthCode:reaskDuration];
    }];
}
- (void)OnSmsRegVerifyCodeSuccess{
    UIImage *image = self.logoImageView.image;
    if(!isHasLogo){
        image = nil;
    }
    [[Business sharedInstance] saveUserInfo:self.phoneTextField.text
                                       name:self.nameTextField.text
                                     gender:@"男"
                                    address:@""
                                  signature:@""
                                      image:image
                                       succ:^(NSString *msg, id data) {
                                           [[TLSRegister sharedInstance] registerCommit];
                                       }
                                       fail:^(NSString *error) {
                                           [HUD hideText:@"注册失败,请重试" atMode:MBProgressHUDModeText andDelay:1 andCompletion:nil];
                                       }];
}
- (void)OnSmsRegCommitSuccess:(TLSUserInfo *)userInfo{
    [HUD hideText:@"注册成功" atMode:MBProgressHUDModeText andDelay:1 andCompletion:^{
        [self.navigationController popViewControllerAnimated:YES];
    }];
}
- (void)OnSmsRegFail:(TLSErrInfo *)errInfo{
    if(TLS_ACCOUNT_SUCCESS == errInfo.wErrorCode){
        [HUD hideText:errInfo.sErrorMsg atMode:MBProgressHUDModeText andDelay:1 andCompletion:^{
            self.authTextField.text = @"";
        }];
    }
    //    else if(TLS_ACCOUNT_SMSCODE_INVALID == errInfo.wErrorCode){
    //        [HUD hideText:@"验证码无效" atMode:MBProgressHUDModeText andDelay:1 andCompletion:nil];
    //    }
    //    else if(TLS_ACCOUNT_SMSCODE_EXPIRED == errInfo.wErrorCode){
    //        [HUD hideText:@"验证码过期" atMode:MBProgressHUDModeText andDelay:1 andCompletion:nil];
    //    }
    //    else if(TLS_ACCOUNT_REGISTERED == errInfo.wErrorCode){
    //        [HUD hideText:@"已经注册过了" atMode:MBProgressHUDModeText andDelay:1 andCompletion:nil];
    //    }
    else{
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
}
- (void)OnSmsRegTimeout:(TLSErrInfo *)errInfo{
    [HUD hideText:errInfo.sErrorMsg atMode:MBProgressHUDModeText andDelay:1 andCompletion:nil];
}
@end
