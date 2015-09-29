//
//  MainTabBarController.m
//  live
//
//  Created by kenneth on 15-7-9.
//  Copyright (c) 2015年 kenneth. All rights reserved.
//

#import "MainTabBarController.h"
#import "Macro.h"
#import "UIImage+Category.h"
#import "DoLiveViewController.h"
#import "UserInfo.h"
#import "LoginViewController.h"
#import "MultiIMManager.h"
#import "MBProgressHUD.h"
#import "WatchLiveTableViewController.h"
#import "MyTableViewController.h"
#import "BaseNavigationController.h"
#import "TrailerLiveViewController.h"
@interface MainTabBarController ()<UITabBarControllerDelegate,TIMConnListenerImplDelegate>
{
    WatchLiveTableViewController* watchController;
    MyTableViewController* myController;
    UITabBarItem* watchLiveItem;//看直播，所在索引0
    UITabBarItem* doLiveItem;   //我来直播，所在索引1
    UITabBarItem* myCenterItem; //我的中心，所在索引2
    
    MBProgressHUD* HUD;
    UIButton* liveButton;
}

@end

@implementation MainTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initTabBar];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark 初始化Tab
- (void)initTabBar{
    //网络时间代理
    [MultiIMManager sharedInstance].connListenerImpl.delegate = self;
    //初始化MBProgressHUD
    HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:HUD];
    [HUD show:YES];
    HUD.hidden = YES;
    
    //viewcontrollers
    watchController = [[WatchLiveTableViewController alloc] init];
    BaseNavigationController* firstNav = [[BaseNavigationController alloc] initWithRootViewController:watchController];
    UIViewController* second = [[UIViewController alloc] init];
    myController = [[MyTableViewController alloc] init];
    BaseNavigationController* thirdNav = [[BaseNavigationController alloc] initWithRootViewController:myController];
    self.viewControllers = [NSArray arrayWithObjects:firstNav, second,thirdNav,nil];
    
    //获取tabBarItem
    watchLiveItem = [self.tabBar.items objectAtIndex:0];
    doLiveItem = [self.tabBar.items objectAtIndex:1];
    myCenterItem = [self.tabBar.items objectAtIndex:2];
    //设置tabBarItem背景图标
    [self setTabBarItem:watchLiveItem withNormalImageName:@"watch_gray" andSelectedImageName:@"watch_red" andTitle:@"看直播"];
    [self setTabBarItem:doLiveItem withNormalImageName:@"" andSelectedImageName:@""  andTitle:@""];
    [self setTabBarItem:myCenterItem withNormalImageName:@"my_gray" andSelectedImageName:@"my_red" andTitle:@"我的中心"];
    
    //设置未选中字体颜色
    [[UITabBarItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:RGB16(COLOR_FONT_BLACK), NSForegroundColorAttributeName, nil] forState:UIControlStateNormal];
    //设置选中字体颜色
    [[UITabBarItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:RGB16(COLOR_FONT_RED), NSForegroundColorAttributeName, nil] forState:UIControlStateSelected];
    //设置tabbar背景颜色
    [[UITabBar appearance] setBackgroundColor:[UIColor groupTableViewBackgroundColor]];
    [[UITabBar appearance] setBackgroundImage:[UIImage imageWithColor:RGB16(COLOR_BG_WHITE) andSize:self.tabBar.frame.size]];
    [[UITabBar appearance] setShadowImage:[UIImage imageWithColor:RGB16(COLOR_BG_WHITE) andSize:CGSizeMake(SCREEN_WIDTH, 1)]];
    
    //我来直播
    liveButton = [UIButton buttonWithType:UIButtonTypeCustom];
    liveButton.frame = CGRectMake(self.tabBar.frame.size.width/2-30, -15, 60, 60);
    [liveButton setImage:[UIImage imageNamed:@"live"] forState:UIControlStateNormal];
    liveButton.adjustsImageWhenHighlighted = NO;//去除按钮的按下效果（阴影）
    [liveButton addTarget:self action:@selector(liveButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    
}
#pragma mark 点击我来直播
- (void)liveButtonClicked{
    DoLiveViewController* live = [[DoLiveViewController alloc] init];
    live.delegate = (id<DoLiveDelegate>)watchController;
    [watchController presentViewController:live animated:YES completion:nil];
}

#pragma mark 设置tabBarItem默认图标和选中图标
- (void)setTabBarItem:(UITabBarItem*) tabBarItem withNormalImageName:(NSString*)normalImageName andSelectedImageName:(NSString*)selectedImageName andTitle:(NSString*)title{
    [tabBarItem setImage:[[UIImage imageNamed:normalImageName] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    [tabBarItem setSelectedImage:[[UIImage imageNamed:selectedImageName] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    [tabBarItem setTitle:title];
}

- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController{
    return YES;
}
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController{

}

- (void)viewDidAppear:(BOOL)animated{
    
    [super viewDidAppear:animated];
    
    if(liveButton.superview != nil){
        [liveButton removeFromSuperview];
    }
    [self.tabBar addSubview:liveButton];
    
    if(![[MultiIMManager sharedInstance] isLogin]){
        [HUD showText:@"正在登录IM" atMode:MBProgressHUDModeIndeterminate];
        [[MultiIMManager sharedInstance] loginPhone:[UserInfo sharedInstance].userPhone sig:[UserInfo sharedInstance].userSig succ:^(NSString *msg) {
            [HUD hideText:msg atMode:MBProgressHUDModeText andDelay:1 andCompletion:nil];
        } fail:^(NSString *err) {
            [HUD hideText:@"登录IM失败" atMode:MBProgressHUDModeText andDelay:1 andCompletion:^{
                [self performSegueWithIdentifier:@"toLogin" sender:self];
            }];
        }];
    }
}

#pragma mark 消息和连接代理
- (void)onConnSucc{
    NSNumber* status = [NSNumber numberWithInt:NETWORK_CONN];
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_IMNETWORK object:status];
}
- (void)onConnFailed:(int)code err:(NSString*)err{
    NSNumber* status = [NSNumber numberWithInt:NETWORK_FAIL];
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_IMNETWORK object:status];
}
- (void)onDisconnect:(int)code err:(NSString*)err{
    NSNumber* status = [NSNumber numberWithInt:NETWORK_DISCONN];
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_IMNETWORK object:status];
}
@end
