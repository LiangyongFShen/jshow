//
//  DoLiveViewController.m
//  live
//
//  Created by kenneth on 15-7-9.
//  Copyright (c) 2015年 kenneth. All rights reserved.
//

#import "DoLiveViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "MyLiveViewController.h"
#import "TrailerLiveViewController.h"
#import "UserInfo.h"
@interface DoLiveViewController ()<TrailerLiveViewDelegate>{
    BOOL hideStatus;
    MyLiveViewController* liveController;
    TrailerLiveViewController* trailerLiveController;
}
@end

@implementation DoLiveViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    liveController = [[MyLiveViewController alloc] init];
    trailerLiveController = [[TrailerLiveViewController alloc] init];
    [self addChildViewController:trailerLiveController];
    [self addChildViewController:liveController];
    liveController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    trailerLiveController.view.frame = CGRectMake(0, 20, self.view.frame.size.width, self.view.frame.size.height-20);
    trailerLiveController.delegate = self;
    [self.view addSubview:trailerLiveController.view];
    hideStatus = NO;
    [self hideStatusBar];
}
#pragma mark 代理
- (void)startLiveController:(NSString *)title image:(UIImage *)image{
    hideStatus = YES;
    [self hideStatusBar];
    [UserInfo sharedInstance].liveUserPhone = [UserInfo sharedInstance].userPhone;
    [UserInfo sharedInstance].liveUserName = [UserInfo sharedInstance].userName;
    [UserInfo sharedInstance].liveUserLogo = [UserInfo sharedInstance].userLogo;
    [UserInfo sharedInstance].livePraiseNum = @"0";
    [UserInfo sharedInstance].liveType = LIVE_DOING;
    liveController.liveTitle = title;
    liveController.liveImage = image;
    [self transitionFromViewController:trailerLiveController toViewController:liveController duration:0.2 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
    }  completion:nil];
}
- (void)publishTrailerSuccess{
    if(self.delegate){
        [self.delegate publishTrailerSuccess];
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidAppear:(BOOL)animated{
}

#pragma mark 显示status bar
- (void)hideStatusBar{
    if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)]) {
        [self prefersStatusBarHidden];
        [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
    }
}
- (BOOL)prefersStatusBarHidden
{
    return hideStatus;
}
@end