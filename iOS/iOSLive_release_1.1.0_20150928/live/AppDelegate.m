//
//  AppDelegate.m
//  live
//
//  Created by kenneth on 15-7-9.
//  Copyright (c) 2015年 kenneth. All rights reserved.
//

#import "AppDelegate.h"
#import "AFHTTPRequestOperationManager.h"
#import "UserInfo.h"
#import "Macro.h"
#import "Business.h"
#import "MultiIMManager.h"
#import "TLSLogin.h"
#import "TLSRegister.h"
#import <AVFoundation/AVAudioSession.h>
@interface AppDelegate ()

@end

@implementation AppDelegate

void uncaughtExceptionHandler(NSException *exception) {
    //crash保存
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    NSString* log = [NSString stringWithFormat:@"%@crash:%@\n,stack trace:%@",version,exception,[exception callStackSymbols]];
    [[UserInfo sharedInstance] saveCrash:log];
    //直播信息保存
    [[UserInfo sharedInstance] saveLiveToLocal];
    
    if(LIVE_DOING == [UserInfo sharedInstance].liveType)
    {
        //关闭房间
        //[HUD showText:@"正在关闭房间" atMode:MBProgressHUDModeIndeterminate];
        [[Business sharedInstance] closeRoom:[UserInfo sharedInstance].liveRoomId succ:nil fail:nil];
    }
    if(LIVE_WATCH == [UserInfo sharedInstance].liveType){
        //离开房间
        //[HUD showText:@"正在离开房间" atMode:MBProgressHUDModeIndeterminate];
        [[Business sharedInstance] leaveRoom:[UserInfo sharedInstance].liveRoomId
                                       phone:[UserInfo sharedInstance].userPhone
                                        succ:nil
                                        fail:nil];
    }
    
    usleep(1*1000*1000);
}
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    //导航条颜色
    [[UINavigationBar appearance] setBarTintColor:[UIColor whiteColor]];
    //注册异常处理
    NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);
    //用户登录信息\直播信息\环境信息
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSDictionary* userDic = [userDefaults objectForKey:@"userInfo"];
    NSDictionary* liveDic = [userDefaults objectForKey:@"liveInfo"];
    NSNumber* environment = [userDefaults objectForKey:@"environment"];
    [[UserInfo sharedInstance] setUserFromLocalInfo:userDic];
    [[UserInfo sharedInstance] setLiveFromLocalInfo:liveDic];
    [[UserInfo sharedInstance] setEnv:environment];
    
    [Business sharedInstance];
    [MultiIMManager sharedInstance];
    [TLSLogin sharedInstance];
    
    //后台定时器开启
    // Override point for customization after application launch.
    NSError *setCategoryErr = nil;
    NSError *activationErr  = nil;
    [[AVAudioSession sharedInstance]
     setCategory: AVAudioSessionCategoryPlayback
     error: &setCategoryErr];
    [[AVAudioSession sharedInstance]
     setActive: YES
     error: &activationErr];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    UIApplication*   app = [UIApplication sharedApplication];
    __block    UIBackgroundTaskIdentifier bgTask;
    bgTask = [app beginBackgroundTaskWithExpirationHandler:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            if (bgTask != UIBackgroundTaskInvalid)
            {
                bgTask = UIBackgroundTaskInvalid;
            }
        });
    }];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            if (bgTask != UIBackgroundTaskInvalid)
            {
                bgTask = UIBackgroundTaskInvalid;
            }
        });
    });
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
//    if([UserInfo sharedInstance].isInLiveRoom){
//        if(LIVE_DOING == [UserInfo sharedInstance].liveType){
//            [[Business sharedInstance] closeRoom:[UserInfo sharedInstance].liveRoomId succ:^(NSString *msg, id data) {
//            } fail:^(NSString *error) {
//            }];
//        }
//        if(LIVE_WATCH == [UserInfo sharedInstance].liveType){
//            [[Business sharedInstance] leaveRoom:[UserInfo sharedInstance].liveRoomId phone:[UserInfo sharedInstance].userPhone succ:^(NSString *msg, id data) {
//            } fail:^(NSString *error) {
//            }];
//        }
//    }
}
//禁止横屏
- (NSUInteger)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window{
    return UIInterfaceOrientationMaskPortrait;
}
@end
