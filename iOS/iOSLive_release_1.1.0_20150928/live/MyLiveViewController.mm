//
//  MyLiveViewController.m
//  live
//
//  Created by hysd on 15/7/16.
//  Copyright (c) 2015年 kenneth. All rights reserved.
//

#import "MyLiveViewController.h"
#import "LivingView.h"
#import "Macro.h"
#import "MBProgressHUD.h"
#include "AVRender.h"
#import "UserInfo.h"
#import "UserInfoView.h"
#import <ImSDK/IMSdkInt.h>
#import "SDWebImage/UIImageView+WebCache.h"
#import "UIImage+Category.h"
#import "MultiIMManager.h"
#import "Business.h"
#import "MultiRoomManager.h"
#import "FinishView.h"
#import "LiveAlertView.h"
#import "UserPopView.h"
#import "RecordParamView.h"
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

#define BACKGROUND_TIME 20
@interface MyLiveViewController ()<LivingViewDelegate,TIMMessageListenerImplDelegate,FinishViewDelegate,CLLocationManagerDelegate>
{
    AVCaptureSession* session;
    AVCaptureDeviceInput* vedioInput;
    AVCaptureVideoPreviewLayer* previewLayer;
    
    LivingView* _livingView;
    MBProgressHUD *HUD;
    
    unsigned long innerRoomId;//内部直播间编号（创建房间返回）
    ImageRender* imageRender;//画面渲染
    bool firstInRoom;//是否第一次进入房间
    BOOL isMikeOpen;//mike是否打开
    NSTimer* liveTimer;//直播计时
    NSTimer* backTimer;//后台定时
    
    NSTimer* crashTimer;//主播心跳检测（判断主播当前是否端是否crash）
    NSString *curLivePhone;//当前主播电话，用于心跳检测
    
    BOOL isStartPush;//是否开始推流
    BOOL isStartReco;//是否开始录制
    BOOL isShowParam;//是否显示参数信息
    NSTimer* paramTimer;
    
    BOOL isFirstLoad;
    BOOL isBackground;
    BOOL isFirstEnableCamera;
    MultiRoomManager* roomManager;
    CLLocationManager* locManager;
    
    BOOL isInserting;
}
@end

@implementation MyLiveViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    //变量初始化
    firstInRoom = true;
    isStartPush = NO;
    isStartReco = NO;
    isShowParam = NO;
    isMikeOpen = YES;
    isFirstLoad = YES;
    isBackground = NO;
    isFirstEnableCamera = YES;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)viewWillAppear:(BOOL)animated{
    if(isFirstLoad){
        isFirstLoad = NO;
        [self initView];
        [self startLive];
    }
}

#pragma mark 开始直播
- (void)initView{
    //开始透明背景
    [self initSession];
    //直播视图
    _livingView = [[[NSBundle mainBundle] loadNibNamed:@"LivingView" owner:self options:nil] lastObject];
    _livingView.frame = self.view.bounds;
    _livingView.delegate = self;
    _livingView.hidden = YES;
    [self.view addSubview:_livingView];
    //初始化MBProgressHUD
    HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:HUD];
    [HUD show:YES];
    HUD.hidden = YES;
    [self hideStatusBar];
}
- (void)startLive{
    [HUD showText:@"请稍后" atMode:MBProgressHUDModeIndeterminate];
    if(LIVE_DOING == [UserInfo sharedInstance].liveType){
        //直播需要创建房间号
        //[HUD showText:@"获取房间号" atMode:MBProgressHUDModeIndeterminate];
        [[Business sharedInstance] getRoomnumSucc:^(NSString *msg, id responseObject) {
            [UserInfo sharedInstance].tmpLiveRoomId = [responseObject integerValue];
            [self avStartContext];
        } fail:^(NSString *error) {
            [HUD hideText:error atMode:MBProgressHUDModeText andDelay:1 andCompletion:^{
                [self dismissController];
            }];
        }];
    }
    if(LIVE_WATCH == [UserInfo sharedInstance].liveType){
        //看直播不需要创建房间号,直接进入房间
        [self avStartContext];
    }
}
#pragma mark 切换前后台
- (void)didEnterBackground:(NSNotification*)aNotification{
    isBackground = YES;
    if(LIVE_DOING == [UserInfo sharedInstance].liveType){
        [roomManager pauseVideo];
        [self avEnableCamera:[NSNumber numberWithBool:NO]];
    }
    if(LIVE_WATCH == [UserInfo sharedInstance].liveType){
        [imageRender stopRender];
    }
    backTimer = [NSTimer scheduledTimerWithTimeInterval:BACKGROUND_TIME target:self selector:@selector(backCloseLive) userInfo:nil repeats:NO];
}
- (void)willEnterForeground:(NSNotification*)aNotification{
    isBackground = NO;
    if(LIVE_DOING == [UserInfo sharedInstance].liveType){
        [roomManager resumeVideo];
        [self avEnableCamera:[NSNumber numberWithBool:YES]];
    }
    if(LIVE_WATCH == [UserInfo sharedInstance].liveType){
        [imageRender startRender];
    }
    if(backTimer){
        [backTimer invalidate];
        backTimer = nil;
    }
}
- (void)backCloseLive{
    //删除监听
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_IMNETWORK object:nil];
#warning 推流录制
    if(paramTimer){
        [paramTimer invalidate];
        paramTimer = nil;
    }
    if(liveTimer){
        [liveTimer invalidate];
        liveTimer = nil;
    }
    
    [_livingView.messageTextField resignFirstResponder];
    [self sendDelUser:[UserInfo sharedInstance].userPhone
               result:^(NSString *) {
                   [self avExitChat];
               }];
}
#pragma mark 隐藏status bar
- (void)hideStatusBar{
    if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)]) {
        [self prefersStatusBarHidden];
        [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
    }
}
- (BOOL)prefersStatusBarHidden
{
    return YES;
}

#pragma mark 键盘通知
- (void)keyboardWasShown:(NSNotification*)aNotification{
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    [_livingView.messageScrollView setContentOffset:CGPointMake(0, kbSize.height)];
}

- (void)keyboardWillBeHidden:(NSNotification*)aNotification{
    [_livingView.messageScrollView setContentOffset:CGPointMake(0, 0)];
}

- (void)keyboardDidHidden:(NSNotification*)aNotification{
}

#pragma mark 网络连接通知
- (void)networkStatus:(NSNotification*)aNotification{
    NETWORK_STATUS status = (NETWORK_STATUS)[((NSNumber*)aNotification.object) intValue];
    if(NETWORK_DISCONN == status){
        _livingView.logoContainerView.hidden = YES;
        _livingView.netContainerView.hidden = NO;
        [_livingView netRotateStart];
    }
    else if(NETWORK_CONN == status){
        _livingView.logoContainerView.hidden = NO;
        _livingView.netContainerView.hidden = YES;
        [_livingView netRotateStop];
    }
    else{
    }
}
#pragma mark 定位
- (void)startLocation{
    //locManager不能为局部变量，否则授权定位提示会一闪而过
    locManager = [[CLLocationManager alloc] init];
    [locManager setDesiredAccuracy:kCLLocationAccuracyBest];
    locManager.delegate = self;
    [locManager startUpdatingLocation];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0){
        [locManager requestWhenInUseAuthorization];  //调用了这句,就会弹出允许框了.
    }
}
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    [HUD hideText:@"定位出错" atMode:MBProgressHUDModeText andDelay:1 andCompletion:^{
        [self avExitRoom];
    }];
}
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation* newLocatioin = locations[0];
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder reverseGeocodeLocation:newLocatioin
                   completionHandler:^(NSArray *placemarks, NSError *error) {
                       if (error)
                       {
                       }
                       else
                       {
                           CLPlacemark* placeMark = placemarks[0];
                           //记录地址
                           if (!isInserting && placeMark.name) {
                               isInserting = TRUE;
                               [self insertLivingData:placeMark.name];
                           }
                       }
                   }];
}

#pragma mark 插入直播数据
- (void)insertLivingData:(NSString*)addr{
    [[Business sharedInstance] insertLive:self.liveTitle
                                    phone:[UserInfo sharedInstance].userPhone
                                     room:[UserInfo sharedInstance].tmpLiveRoomId
                                     chat:[UserInfo sharedInstance].chatRoomId
                                     addr:addr
                                    image:self.liveImage
                                     succ:^(NSString *msg, id data) {
                                         //必须在OnRoomEndpointsEnter方法开启摄像头，
                                         //否则无法更新服务器中主播摄像头开启的状态，
                                         //导致没有视频上行
                                         //不自动锁屏
                                         [UIApplication sharedApplication].idleTimerDisabled=YES;
                                         [self initOnlineUserSucc:^{
                                             [self performSelector:@selector(avEnableCamera:) withObject:[NSNumber numberWithBool:YES] afterDelay:1];
                                         } fail:^{
                                             [HUD hideText:@"获取在线列表错误" atMode:MBProgressHUDModeText andDelay:1 andCompletion:^{
                                                 [self avExitRoom];
                                             }];
                                         }];
                                     } fail:^(NSString *error) {
                                         [HUD hideText:error atMode:MBProgressHUDModeText andDelay:1 andCompletion:^{
                                             [self avExitRoom];
                                         }];
                                     }];
    [[UserInfo sharedInstance] saveLiveToLocal];
}
#pragma mark LivingView 代理
- (void)closeLivingView:(LivingView *)livingView{
    //删除监听
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_IMNETWORK object:nil];
#warning 推流录制
    if(paramTimer){
        [paramTimer invalidate];
        paramTimer = nil;
    }
    if(liveTimer){
        [liveTimer invalidate];
        liveTimer = nil;
    }
    
    [_livingView.messageTextField resignFirstResponder];
    [HUD showText:@"请稍后" atMode:MBProgressHUDModeIndeterminate];
    if(LIVE_DOING == [UserInfo sharedInstance].liveType){
        LiveAlertView* alert = [[LiveAlertView alloc] init];
        NSString* count = _livingView.userCountLabel.text;
        NSString* title = [NSString stringWithFormat:@"有%@人正在看您的直播,确定结束直播吗？",count];
        [alert showTitle:title confirmTitle:@"结束直播" cancelTitle:@"继续直播" confirm:^{
            [self sendDelUser:[UserInfo sharedInstance].userPhone
                       result:nil];
            FinishView* fv = [[FinishView alloc] init];
            NSString* audience = _livingView.userCountLabel.text;
            NSString* praise = _livingView.loveCountLabel.text;
            fv.delegate = self;
            [fv showView:self.view audience:audience praise:praise];
        } cancel:nil];
    }
    else{
        [self sendDelUser:[UserInfo sharedInstance].userPhone
                   result:^(NSString *) {
                       [self avExitChat];
                   }];
    }
}
- (void)toggleCamera:(LivingView *)livingView{
    [self avToggleCamera];
}
- (void)openMike:(LivingView *)livingView{
    isMikeOpen = !isMikeOpen;
    if(isMikeOpen){
        [_livingView.mikeButton setImage:[UIImage imageNamed:@"mike_white"] forState:UIControlStateNormal];
    }
    else{
        [_livingView.mikeButton setImage:[UIImage imageNamed:@"mike_gray"] forState:UIControlStateNormal];
    }
    roomManager.avContext->GetAudioCtrl()->EnableMic(isMikeOpen);
}
- (void)sendMessage:(LivingView *)livingView{
    NSString* message = _livingView.messageTextField.text;
    [self sendMsg:message];
}
- (void)sendMsg:(NSString*)message{
    TIMTextElem* textElem = [[TIMTextElem alloc] init];
    [textElem setText:message];
    TIMMessage* timMsg = [[TIMMessage alloc] init];
    [timMsg addElem:textElem];
    [[MultiIMManager sharedInstance].conversation sendMessage:timMsg succ:^(){
        [_livingView addMessage:message andPhone:[UserInfo sharedInstance].userPhone];
    }fail:^(int code, NSString* err){
        NSLog(@"%@",err);
    }];
}
- (void)sendPraise:(NSInteger)praiseCount{
    NSString* sendMessage = [NSString stringWithFormat:
                             MSG_PRAISE,
                             [UserInfo sharedInstance].userPhone,
                             (int)MSG_CMD_PRAISE,
                             (int)praiseCount];
    TIMCustomElem* praiseElem = [[TIMCustomElem alloc] init];
    praiseElem.data = [sendMessage dataUsingEncoding:NSUTF8StringEncoding];
    TIMMessage* timMsg = [[TIMMessage alloc] init];
    [timMsg addElem:praiseElem];
    [[MultiIMManager sharedInstance].conversation sendMessage:timMsg succ:^(){
        [_livingView addLove:praiseCount];
    }fail:^(int code, NSString* err){
        NSLog(@"%@",err);
    }];
}
- (void)sendAddUser:(NSDictionary*)user{
    NSString* sendMessage = [NSString stringWithFormat:
                             MSG_ADDUSER,
                             [UserInfo sharedInstance].userPhone,
                             (int)MSG_CMD_ADDUSER,
                             [UserInfo sharedInstance].userName,
                             [UserInfo sharedInstance].userLogo];
    TIMCustomElem* userElem = [[TIMCustomElem alloc] init];
    userElem.data = [sendMessage dataUsingEncoding:NSUTF8StringEncoding];
    TIMMessage* timMsg = [[TIMMessage alloc] init];
    [timMsg addElem:userElem];
    [[MultiIMManager sharedInstance].conversation sendMessage:timMsg succ:^(){
        NSLog(@"发送用户信息成功");
    }fail:^(int code, NSString* err){
        NSLog(@"发送用户信息失败%d--%@",code,err);
    }];
}
- (void)sendDelUser:(NSString*)phone result:(void(^)(NSString*))result{
    NSString* sendMessage = [NSString stringWithFormat:
                             MSG_DELUSER,
                             phone,
                             (int)MSG_CMD_DELUSER];
    TIMCustomElem* userElem = [[TIMCustomElem alloc] init];
    userElem.data = [sendMessage dataUsingEncoding:NSUTF8StringEncoding];
    TIMMessage* timMsg = [[TIMMessage alloc] init];
    [timMsg addElem:userElem];
    [[MultiIMManager sharedInstance].conversation sendMessage:timMsg succ:^(){
        if(result != nil){
            result(nil);
        }
    }fail:^(int code, NSString* err){
        if(result != nil){
            result(nil);
        }
    }];
}
- (void)initOnlineUserSucc:(void(^)())succ fail:(void(^)())fail{
    
    
    if ([UserInfo sharedInstance].liveType == LIVE_DOING) {
        //获取在线用户列表
        [[Business sharedInstance] getUserListByRoom:[UserInfo sharedInstance].tmpLiveRoomId
                                                succ:^(NSString *msg, id data) {
                                                    NSMutableArray* array = [[NSMutableArray alloc] init];
                                                    for(int i = 0 ; i < ((NSArray*)data).count; i++){
                                                        NSDictionary* tmp = [data objectAtIndex:i];
                                                        NSDictionary* dic = [[NSDictionary alloc] initWithObjectsAndKeys:
                                                                             [tmp objectForKey:@"username"],@"userName",
                                                                             [tmp objectForKey:@"userphone"],@"userPhone",
                                                                             [tmp objectForKey:@"headimagepath"],@"userLogo", nil];
                                                        [array addObject:dic];
                                                    }
                                                    [_livingView addUsers:array];
                                                    succ();
                                                } fail:^(NSString *error) {
                                                    fail();
                                                }];
    }
    else if ([UserInfo sharedInstance].liveType == LIVE_WATCH)
    {
        //获取在线用户列表
        [[Business sharedInstance] getUserListByRoom:[UserInfo sharedInstance].liveRoomId
                                                succ:^(NSString *msg, id data) {
                                                    NSMutableArray* array = [[NSMutableArray alloc] init];
                                                    for(int i = 0 ; i < ((NSArray*)data).count; i++){
                                                        NSDictionary* tmp = [data objectAtIndex:i];
                                                        NSDictionary* dic = [[NSDictionary alloc] initWithObjectsAndKeys:
                                                                             [tmp objectForKey:@"username"],@"userName",
                                                                             [tmp objectForKey:@"userphone"],@"userPhone",
                                                                             [tmp objectForKey:@"headimagepath"],@"userLogo", nil];
                                                        [array addObject:dic];
                                                    }
                                                    [_livingView addUsers:array];
                                                    succ();
                                                } fail:^(NSString *error) {
                                                    fail();
                                                }];
    }
    
}
#warning 推流测试
- (void)pushFLV:(LivingView *)livingView{
    [self push:AV_ENCODE_FLV];
}
- (void)pushHLS:(LivingView *)livingView{
    [self push:AV_ENCODE_HLS];
}
- (void)pushRTMP:(LivingView *)livingView{
    [self push:AV_ENCODE_RTMP];
}
- (void)liveREC:(LivingView *)livingView{
#warning 推流录制
    NSData* sigData = [@"000" dataUsingEncoding:NSUTF8StringEncoding];
    NSInteger roomid = 0;
    if(ENVIRONMENT_TEST == [UserInfo sharedInstance].environment){
        roomid = [[[UserInfo sharedInstance].userPhone substringToIndex:5] intValue];
    }
    else{
        roomid = [UserInfo sharedInstance].liveRoomId;
    }
    if(!isStartReco){
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
        RecordParamView* record = [[RecordParamView alloc] init];
        record.fileTextField.text = [UserInfo sharedInstance].userPhone;
        record.tagTextField.text = [UserInfo sharedInstance].userPhone;
        record.classTextField.text = [[NSNumber numberWithInt:[UserInfo sharedInstance].liveRoomId] stringValue];
        
        [record showTitle:@"录制参数" confirmTitle:@"开始录制" cancelTitle:@"取消录制" confirm:^{
            AVRecordInfo* info = [[AVRecordInfo alloc] init];
            info.fileName = record.fileTextField.text;
            info.tags = [NSArray arrayWithObjects:record.tagTextField.text, nil];
            info.classId = [record.classTextField.text intValue];
            info.isTransCode = record.codeSwitch.on;
            info.isScreenShot = record.cutSwitch.on;
            info.isWaterMark = record.waterSwitch.on;
            //开始录制
            [self.view bringSubviewToFront:HUD];
            [HUD showText:@"请求开始录制" atMode:MBProgressHUDModeIndeterminate];
            int ret = [[IMSdkInt sharedInstance] requestMultiVideoRecorderStart:roomid roomId:innerRoomId signature:sigData recordInfo:info okBlock:^{
                isStartReco = YES;
                [HUD hideText:@"开始录制" atMode:MBProgressHUDModeText andDelay:1 andCompletion:nil];
            } errBlock:^(int code, NSString *err) {
                [HUD hideText:@"请求失败" atMode:MBProgressHUDModeText andDelay:1 andCompletion:^{
                    NSString* message = [NSString stringWithFormat:@"错误码:%d\n错误信息:%@",code,err];
                    LiveAlertView* alert = [[LiveAlertView alloc] init];
                    [alert showTitle:message confirmTitle:@"确定" cancelTitle:@"取消" confirm:nil cancel:nil];
                }];
            }];
            if(ret != 0){
                [HUD hideText:@"发包失败" atMode:MBProgressHUDModeText andDelay:1 andCompletion:nil];
            }
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(keyboardWasShown:)
                                                         name:UIKeyboardDidShowNotification object:nil];
            
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(keyboardWillBeHidden:)
                                                         name:UIKeyboardWillHideNotification object:nil];
        } cancel:^{
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(keyboardWasShown:)
                                                         name:UIKeyboardDidShowNotification object:nil];
            
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(keyboardWillBeHidden:)
                                                         name:UIKeyboardWillHideNotification object:nil];
        }];
        
    }
    else{
        //停止录制
        [HUD showText:@"请求停止录制" atMode:MBProgressHUDModeIndeterminate];
        int ret = [[IMSdkInt sharedInstance] requestMultiVideoRecorderStop:roomid roomId:innerRoomId signature:sigData okBlock:^(NSArray *fileIds) {
            isStartReco = NO;
            NSString* fileId = @"";
            if(fileIds != nil){
                for(int index = 0; index < fileIds.count; index++){
                    [HUD hideText:@"停止录制" atMode:MBProgressHUDModeText andDelay:1 andCompletion:nil];
                    fileId = [fileId stringByAppendingString:[NSString stringWithFormat:@"%@\n",fileIds[index]]];
                }
            }
            LiveAlertView* alert = [[LiveAlertView alloc] init];
            [alert showTitle:fileId confirmTitle:@"确定" cancelTitle:@"取消" confirm:nil cancel:nil];
        } errBlock:^(int code, NSString *err) {
            [HUD hideText:@"请求失败" atMode:MBProgressHUDModeText andDelay:1 andCompletion:^{
                NSString* message = [NSString stringWithFormat:@"错误码:%d\n错误信息:%@",code,err];
                LiveAlertView* alert = [[LiveAlertView alloc] init];
                [alert showTitle:message confirmTitle:@"确定" cancelTitle:@"取消" confirm:nil cancel:nil];
            }];
        }];
        if(ret != 0){
            [HUD hideText:@"发包失败" atMode:MBProgressHUDModeText andDelay:1 andCompletion:nil];
        }
    }
    
}
- (void)livePAR:(LivingView *)livingView{
    if(isShowParam){
        isShowParam = NO;
        _livingView.paramTextView.hidden = YES;
    }
    else{
        isShowParam = YES;
        _livingView.paramTextView.hidden = NO;
    }
}
- (void)refreshPAR{
    _livingView.paramTextView.text = [NSString stringWithFormat:@"Video:\n%@Audio:\n%@Common:\n%@",
                                      [roomManager getVideoParam],
                                      [roomManager getAudioParam],
                                      [roomManager getCommonParam],nil];
}
- (void)push:(AVEncodeType)type{
#warning 推流测试
    NSData* sigData = [@"000" dataUsingEncoding:NSUTF8StringEncoding];
    NSInteger roomid;
    if(ENVIRONMENT_TEST == [UserInfo sharedInstance].environment){
        roomid = [[[UserInfo sharedInstance].userPhone substringToIndex:5] intValue];
    }
    else{
        roomid = [UserInfo sharedInstance].liveRoomId;
    }
    if(!isStartPush){
        //推流
        [HUD showText:@"正在推流" atMode:MBProgressHUDModeIndeterminate];
        int ret = [[IMSdkInt sharedInstance]
                   requestMultiVideoStreamerStart:
                   roomid
                   roomId:innerRoomId
                   codeType:type
                   signature:sigData
                   okBlock:^(NSArray* array){
                       isStartPush = YES;
                       AVLiveUrl* liveUrl = array[0];
                       [HUD hideText:@"推流成功" atMode:MBProgressHUDModeText andDelay:1 andCompletion:^{
                           LiveAlertView* alert = [[LiveAlertView alloc] init];
                           [alert showTitle:liveUrl.playUrl confirmTitle:@"复制" cancelTitle:@"取消" confirm:^{
                               UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
                               pasteboard.string = liveUrl.playUrl;
                               [HUD hideText:@"复制成功" atMode:MBProgressHUDModeText andDelay:1 andCompletion:nil];
                           }cancel:nil];
                       }];
                       
                   }errBlock:^(int code, NSString *err) {
                       [HUD hideText:@"推流失败" atMode:MBProgressHUDModeText andDelay:1 andCompletion:^{
                           NSString* message = [NSString stringWithFormat:@"错误码:%d\n错误信息:%@",code,err];
                           LiveAlertView* alert = [[LiveAlertView alloc] init];
                           [alert showTitle:message confirmTitle:@"确定" cancelTitle:@"取消" confirm:nil
                            cancel:nil];
                       }];
                   }];
        if(0 != ret){
            [HUD hideText:@"发包失败" atMode:MBProgressHUDModeText andDelay:1 andCompletion:nil];
        }
    }
    else{
        //断流
        [HUD showText:@"正在断流" atMode:MBProgressHUDModeIndeterminate];
        int ret = [[IMSdkInt sharedInstance]
                   requestMultiVideoStreamerStop:roomid
                   roomId:innerRoomId
                   codeType:AV_ENCODE_HLS
                   signature:sigData
                   okBlock:^{
                       isStartPush = NO;
                       [HUD hideText:@"断流成功" atMode:MBProgressHUDModeText andDelay:1 andCompletion:nil];
                   }errBlock:^(int code, NSString *err) {
                       [HUD hideText:@"断流失败" atMode:MBProgressHUDModeText andDelay:1 andCompletion:^{
                           NSString* message = [NSString stringWithFormat:@"错误码:%d\n错误信息:%@",code,err];
                           LiveAlertView* alert = [[LiveAlertView alloc] init];
                           [alert showTitle:message confirmTitle:@"确定" cancelTitle:@"取消" confirm:nil
                                     cancel:nil];
                       }];
                   }];
        if(0 != ret){
            [HUD hideText:@"发包失败" atMode:MBProgressHUDModeText andDelay:1 andCompletion:nil];
        }
    }
}

- (void)logoTap:(LivingView *)livingView{
    UserPopView* pop = (UserPopView*)[_livingView.logoContainerView viewWithTag:101];
    if(pop){
        [pop hideView];
    }
    else{
        [HUD showText:@"正在获取用户信息" atMode:MBProgressHUDModeIndeterminate];
        [[Business sharedInstance] getUserInfoByPhone:[UserInfo sharedInstance].liveUserPhone
                                                 succ:^(NSString *msg, id userData) {
                                                     [[Business sharedInstance] getLive:[UserInfo sharedInstance].liveRoomId succ:^(NSString *msg, id liveData) {
                                                         [HUD hide:YES];
                                                         NSString* name = [UserInfo sharedInstance].liveUserName;
                                                         NSString* address = [liveData objectForKey:@"addr"];
                                                         NSString* praise = [[NSNumber numberWithInt:[[userData objectForKey:@"praisenum"] intValue]] stringValue];
                                                         UserPopView* pop = [[UserPopView alloc] init];
                                                         pop.tag = 101;
                                                         [pop showView:_livingView.userLogoImageView name:name address:address praise:praise];
                                                     } fail:^(NSString *error) {
                                                         [HUD hideText:error atMode:MBProgressHUDModeText andDelay:1 andCompletion:nil];
                                                     }];
                                                 } fail:^(NSString *error) {
                                                     [HUD hideText:error atMode:MBProgressHUDModeText andDelay:1 andCompletion:nil];
                                                 }];
    }
}
- (void)loveTap:(LivingView *)livingView{
    [[Business sharedInstance] loveLive:[UserInfo sharedInstance].liveRoomId
                               addCount:1
                                   succ:^(NSString *msg, id data) {
                                       [self sendPraise:1];
                                   } fail:^(NSString *error) {
                                   }];
}
- (void)clickAudienceLogo:(LivingView *)livingView withPhone:(NSString *)phone{
    [self getUserInfoByPhone:phone];
}
- (void)getUserInfoByPhone:(NSString*)phone{
    [HUD showText:@"正在获取用户信息" atMode:MBProgressHUDModeIndeterminate];
    [[Business sharedInstance] getUserInfoByPhone:phone
                                             succ:^(NSString *msg, id data) {
                                                 [HUD hide:YES];
                                                 NSString* name = [data objectForKey:@"username"];
                                                 NSString* sig = [data objectForKey:@"signature"];
                                                 NSString* praise = [[NSNumber numberWithInt:[[data objectForKey:@"praisenum"] intValue]] stringValue];
                                                 NSString* logo = [data objectForKey:@"headimagepath"];
                                                 UserInfoView* user = [[UserInfoView alloc] init];
                                                 [user showWithName:name signature:sig praise:praise logo:logo];
                                             } fail:^(NSString *error) {
                                                 [HUD hideText:error atMode:MBProgressHUDModeText andDelay:1 andCompletion:nil];
                                             }];
}
#pragma mark 初始化拍摄环境
- (void)avEnableCamera:(NSNumber*)enable{
    //[HUD showText:@"正在打开摄像头" atMode:MBProgressHUDModeIndeterminate];
    [roomManager avEnableCamera:[enable boolValue] succ:^(NSString *msg) {
    } fail:^(NSString *error) {
        [HUD hideText:error atMode:MBProgressHUDModeText andDelay:1 andCompletion:^{
            [self avExitRoom];
        }];
    }];
}
- (void)initSession{
    session = [[AVCaptureSession alloc] init];
    vedioInput = [[AVCaptureDeviceInput alloc] initWithDevice:[self backCamera] error:nil];
    if ([session canAddInput:vedioInput]) {
        [session addInput:vedioInput];
    }
    [self setUpCameraLayer];
    [session startRunning];
}
- (AVCaptureDevice *)cameraWithPosition:(AVCaptureDevicePosition) position {
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices) {
        if ([device position] == position) {
            return device;
        }
    }
    return nil;
}
- (AVCaptureDevice *)frontCamera {
    return [self cameraWithPosition:AVCaptureDevicePositionFront];
}
- (AVCaptureDevice *)backCamera {
    return [self cameraWithPosition:AVCaptureDevicePositionBack];
}
- (void)setUpCameraLayer
{
    if (previewLayer == nil) {
        previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:session];
        [previewLayer setFrame:self.view.bounds];
        [previewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
        [self.view.layer addSublayer:previewLayer];
    }
}

#pragma mark 有关直播的方法
- (void)OnRoomCreateComplete:(int)result{
    if(tencent::av::AV_OK == result){
        [UserInfo sharedInstance].isInLiveRoom = YES;
        innerRoomId = (unsigned long)roomManager.avContext->GetRoom()->GetRoomId();
        tencent::av::AVAudioCtrl* avAudioCtrl = roomManager.avContext->GetAudioCtrl();
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            //设置麦克风和扬声器（在进入房间设置才有效）
            if(LIVE_DOING == [UserInfo sharedInstance].liveType){
                [UserInfo sharedInstance].liveRoomId = [UserInfo sharedInstance].tmpLiveRoomId;
                //主播开麦克风和扬声器
                avAudioCtrl->EnableMic(true);
                //avAudioCtrl->EnableSpeaker(true);
            }
            if(LIVE_WATCH == [UserInfo sharedInstance].liveType){
                //观众开扬声器关麦克风
                avAudioCtrl->EnableMic(false);
                //avAudioCtrl->EnableSpeaker(true);
            }
            AVAudioSession *audioSession = [AVAudioSession sharedInstance];
            [audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
            [audioSession setActive:YES error:nil];
        });
    }
    else{
        if(LIVE_DOING == [UserInfo sharedInstance].liveType){
            [HUD hideText:@"创建直播间失败" atMode:MBProgressHUDModeText andDelay:1 andCompletion:^{
                [self avExitRoom];
            }];
        }
        if(LIVE_WATCH == [UserInfo sharedInstance].liveType){
            [HUD hideText:@"进入直播间失败" atMode:MBProgressHUDModeText andDelay:1 andCompletion:^{
                [self avExitRoom];
            }];
        }
    }
    
    
    
    //点赞数量
    _livingView.loveCountLabel.text = [UserInfo sharedInstance].livePraiseNum;
    //直播用户头像
    NSString* liveLogoPath = [UserInfo sharedInstance].liveUserLogo;
    if([liveLogoPath isEqualToString:@""]){
        _livingView.userLogoImageView.image = [UIImage imageNamed:@"userlogo"];
    }
    else{
        NSInteger width = _livingView.userLogoImageView.frame.size.width*SCALE;
        NSInteger height = width;
        NSString *liveLogoUrl = [NSString stringWithFormat:URL_IMAGE,liveLogoPath,width,height];
        [_livingView.userLogoImageView sd_setImageWithURL:[NSURL URLWithString:liveLogoUrl] placeholderImage:[UIImage imageWithColor:RGB16(COLOR_FONT_WHITE) andSize:_livingView.userLogoImageView.frame.size]];
    }
    if(firstInRoom && LIVE_WATCH == [UserInfo sharedInstance].liveType){
        firstInRoom = false;
        //[HUD showText:@"插入进入直播数据" atMode:MBProgressHUDModeIndeterminate];
        [[Business sharedInstance] enterRoom:[UserInfo sharedInstance].liveRoomId
                                       phone:[UserInfo sharedInstance].userPhone
                                        succ:^(NSString *msg, id data) {
                                            //不自动锁屏
                                            [UIApplication sharedApplication].idleTimerDisabled=YES;
                                            [self initOnlineUserSucc:^{
                                                [self performSelector:@selector(avRequestView) withObject:nil afterDelay:1];
                                            } fail:^{
                                                [HUD hideText:@"获取在线列表错误" atMode:MBProgressHUDModeText andDelay:1 andCompletion:^{
                                                    [self avExitRoom];
                                                }];
                                            }];
                                        } fail:^(NSString *error) {
                                            [HUD hideText:error atMode:MBProgressHUDModeText andDelay:1 andCompletion:^{
                                                [self avExitRoom];
                                            }];
                                        }];
        [[UserInfo sharedInstance] saveLiveToLocal];
    }
    if(firstInRoom && LIVE_DOING == [UserInfo sharedInstance].liveType){
        firstInRoom = false;
        isInserting = FALSE;
        [self startLocation];
        if (crashTimer) {
            [crashTimer invalidate];
            crashTimer = nil;
        }
        curLivePhone = [UserInfo sharedInstance].liveUserPhone;
        crashTimer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(crashCheck) userInfo:nil repeats:YES];
    }
}
- (void)crashCheck{
    Business *instance = [Business sharedInstance];
    [instance heartBeatCheckCrash:curLivePhone];
}
- (void)OnRoomLeaveComplete:(int)result{
    
    if(tencent::av::AV_OK == result){
        [UserInfo sharedInstance].isInLiveRoom = NO;
        [self avStopContext];
    }
    else{
        NSString* tip;
        if(LIVE_DOING == [UserInfo sharedInstance].liveType){
            tip = @"关闭直播间失败";
        }
        if(LIVE_WATCH == [UserInfo sharedInstance].liveType){
            tip = @"离开直播间失败";
        }
        [HUD hideText:tip atMode:MBProgressHUDModeText andDelay:1 andCompletion:^{
            [self avStopContext];
        }];
    }
    
}
#warning 1.2版本已经弃用
- (void)OnRoomEndpointsEnter:(int)endpoint_count list:(tencent::av::AVEndpoint**)endpoint_list{
}
#warning 1.2版本已经弃用
- (void)OnRoomEndpointsLeave:(int)endpoint_count list:(tencent::av::AVEndpoint**)endpoint_list{
}
- (void)OnRoomEndpointsUpdate:(int)endpoint_count list:(tencent::av::AVEndpoint**)endpoint_list{
    NSLog(@"update");
}
- (void)OnContextStartComplete:(int)result{
    if(tencent::av::AV_OK == result){
        [self avCreateChat];
    }
    else{
        [HUD hideText:@"开始上下文失败" atMode:MBProgressHUDModeText andDelay:1 andCompletion:^{
            [self dismissController];
        }];
    }
}

- (void)OnContextCloseComplete{
    [self dismissController];
}
- (void)VideoframeDataCallback:(tencent::av::VideoFrame*)frameData{
    AVFrameInfo* frameInfo = [[AVFrameInfo alloc] init];
    frameInfo.identifier=[[NSString alloc] initWithUTF8String:frameData->identifier.c_str()];
    frameInfo.data=[[NSData alloc] initWithBytesNoCopy:frameData->data length:frameData->data_size freeWhenDone:NO];
    
    
    frameInfo.width=frameData->desc.width;
    frameInfo.height=frameData->desc.height;
    frameInfo.rotate=frameData->desc.rotate;
    frameInfo.source_type=frameData->desc.src_type;
    
    [imageRender displayVideoFrame:frameInfo];
}
- (void)OnEnableCameraComplete:(bool)bEnable result:(int)result{
    if(result == tencent::av::AV_OK){
        if(isFirstEnableCamera){
            isFirstEnableCamera = NO;
            [roomManager.previewLayer setFrame:self.view.bounds];
            [self.view.layer replaceSublayer:previewLayer with:roomManager.previewLayer];
            [self showLivingView];
        }
    }
    else{
        [HUD hideText:@"打开摄像头失败" atMode:MBProgressHUDModeText andDelay:1 andCompletion:^{
            [self avExitRoom];
        }];
    }
}

- (void)showLivingView{
    //添加键盘监听
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidHidden:)
                                                 name:UIKeyboardDidHideNotification object:nil];
    //添加切入后台切回前台监听
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didEnterBackground:)
                                                 name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(willEnterForeground:)
                                                 name:UIApplicationWillEnterForegroundNotification object:nil];
    //网络链接状态监听
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(networkStatus:) name:NOTIFICATION_IMNETWORK object:nil];
    if(LIVE_DOING == [UserInfo sharedInstance].liveType){
#warning 推流录制
        paramTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(refreshPAR) userInfo:nil repeats:YES];
        _livingView.mikeButton.hidden = NO;
        _livingView.cameraButton.hidden = NO;
    }
    else{
        _livingView.mikeButton.hidden = YES;
        _livingView.cameraButton.hidden = YES;
    }
    [HUD hide:YES];
    //[HUD hideText:@"进入直播间成功" atMode:MBProgressHUDModeText andDelay:1 andCompletion:nil];
    [UIView animateWithDuration:0.5 animations:^{
        _livingView.alpha = 1;
    }completion:^(BOOL finish){
        _livingView.hidden = NO;
    }];
    liveTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(modLiveTime) userInfo:nil repeats:YES];
    [session stopRunning];
}
- (void)OnSwitchCameraComplete:(bool)bEnable result:(int)result{
    if(result == tencent::av::AV_OK){
    }
    else{
    }
}
-(void)OnRequestViewComplete:(std::string)identifier result:(int)result{
    if (result==tencent::av::AV_OK) {
        //发送个人信息给其他成员
        NSDictionary* myDic = [[NSDictionary alloc] initWithObjectsAndKeys:
                               [UserInfo sharedInstance].userPhone,@"userPhone",
                               [UserInfo sharedInstance].userName,@"userName",
                               [UserInfo sharedInstance].userLogo,@"userLogo",nil];
        [self sendAddUser:myDic];
        //开始渲染画面
        imageRender = [[ImageRender alloc] init];
        imageRender.videoView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
        [self.view.layer replaceSublayer:previewLayer with:imageRender.videoView.layer];
        [imageRender startRender];
        [self showLivingView];
    }else{
        [HUD hideText:@"请求画面失败" atMode:MBProgressHUDModeText andDelay:1 andCompletion:^{
            [self avExitRoom];
        }];
    }
}


- (void)avStartContext{
    //[HUD showText:@"开始上下文" atMode:MBProgressHUDModeIndeterminate];
    roomManager = [[MultiRoomManager alloc] avInitWithController:self];
    if(tencent::av::AV_OK != [roomManager avStartContext]){
        [HUD hideText:@"调用开始上下文失败" atMode:MBProgressHUDModeText andDelay:1 andCompletion:^{
            [self dismissController];
        }];
    }
}
- (void)avStopContext{
    //[HUD showText:@"正在关闭上下文" atMode:MBProgressHUDModeIndeterminate];
    [roomManager avStopContext];
}

- (void)avCreateChat{
    if(LIVE_DOING == [UserInfo sharedInstance].liveType){
        //[HUD showText:@"正在创建聊天室" atMode:MBProgressHUDModeIndeterminate];
        [[MultiIMManager sharedInstance] createGroupSucc:^(NSString *msg) {
            [MultiIMManager sharedInstance].messageListenerImpl.delegate = self;
            [UserInfo sharedInstance].chatRoomId = msg;
            [UserInfo sharedInstance].isInChatRoom = YES;
            [self avCreateRoom];
        } fail:^(NSString *err) {
            [HUD hideText:err atMode:MBProgressHUDModeText andDelay:1 andCompletion:^{
                [self avStopContext];
            }];
        }];
    }
    if(LIVE_WATCH == [UserInfo sharedInstance].liveType){
        //[HUD showText:@"正在进入聊天室" atMode:MBProgressHUDModeIndeterminate];
        [[MultiIMManager sharedInstance] joinGroup:[UserInfo sharedInstance].chatRoomId succ:^(NSString *msg) {
            [MultiIMManager sharedInstance].messageListenerImpl.delegate = self;
            [UserInfo sharedInstance].isInChatRoom = YES;
            [self avCreateRoom];
        } fail:^(NSString *err) {
            [HUD hideText:err atMode:MBProgressHUDModeText andDelay:1 andCompletion:^{
                [self avStopContext];
            }];
        }];
    }
}
- (void)avCreateRoom{
    
    if(LIVE_DOING == [UserInfo sharedInstance].liveType){
        //[HUD showText:@"正在创建房间" atMode:MBProgressHUDModeIndeterminate];
    }
    if(LIVE_WATCH == [UserInfo sharedInstance].liveType){
        //[HUD showText:@"正在进入房间" atMode:MBProgressHUDModeIndeterminate];
    }
#warning 推流录制
    NSInteger roomid;
    if(LIVE_DOING == [UserInfo sharedInstance].liveType){
        if(ENVIRONMENT_TEST == [UserInfo sharedInstance].environment){
            roomid = [[[UserInfo sharedInstance].userPhone substringToIndex:5] intValue];
        }
        else{
            roomid = [UserInfo sharedInstance].tmpLiveRoomId;
        }
    }
    else{
        _livingView.buttonContainer.hidden = YES;
        if(ENVIRONMENT_TEST == [UserInfo sharedInstance].environment){
            roomid = [[[UserInfo sharedInstance].liveUserPhone substringToIndex:5] intValue];
        }
        else{
            roomid = [UserInfo sharedInstance].liveRoomId;
        }
    }
    int createRet = [roomManager avCreateRoom:roomid];
    if(tencent::av::AV_OK != createRet){
        if(tencent::av::AV_ERR_CONTEXT_CLOSED == createRet
           || tencent::av::AV_ERR_CONTEXT_NOT_EXIST == createRet){
            [HUD hideText:@"上下文未开启" atMode:MBProgressHUDModeText andDelay:1 andCompletion:^{
                [self dismissController];
            }];
        }
        else if(tencent::av::AV_ERR_INVALID_ARGUMENT == createRet){
            [HUD hideText:@"委托和配置信息错误" atMode:MBProgressHUDModeText andDelay:1 andCompletion:^{
                [self avStopContext];
            }];
        }
        else if(tencent::av::AV_ERR_ALREADY_EXISTS == createRet){
            [HUD hideText:@"未退出上一个房间" atMode:MBProgressHUDModeText andDelay:1 andCompletion:^{
                [self avExitRoom];
            }];
        }
    }
}
- (void)avJoinRoom{
}
- (void)avExitChat{
    if(LIVE_DOING == [UserInfo sharedInstance].liveType){
        //关闭房间
        //[HUD showText:@"正在关闭房间" atMode:MBProgressHUDModeIndeterminate];
        [[Business sharedInstance] closeRoom:[UserInfo sharedInstance].liveRoomId
                                        succ:^(NSString *msg, id data) {
                                            [self avExitRoom];
                                        }
                                        fail:^(NSString *error) {
                                            [self avExitRoom];
                                        }];
    }
    if(LIVE_WATCH == [UserInfo sharedInstance].liveType){
        //离开房间
        //[HUD showText:@"正在离开房间" atMode:MBProgressHUDModeIndeterminate];
        [[Business sharedInstance] leaveRoom:[UserInfo sharedInstance].liveRoomId
                                       phone:[UserInfo sharedInstance].userPhone
                                        succ:^(NSString *msg, id data) {
                                            [self avExitRoom];
                                        }
                                        fail:^(NSString *error) {
                                            [self avExitRoom];
                                        }];
    }
}
- (void)avExitRoom{
    [UIApplication sharedApplication].idleTimerDisabled=NO;// 自动锁屏
    if(LIVE_DOING == [UserInfo sharedInstance].liveType){
        //群主解散聊天室
        if([UserInfo sharedInstance].isInChatRoom){
            //[HUD showText:@"正在解散聊天室" atMode:MBProgressHUDModeIndeterminate];
            [[MultiIMManager sharedInstance] deleteGroup:[UserInfo sharedInstance].chatRoomId succ:^(NSString *msg) {
                [UserInfo sharedInstance].isInChatRoom = NO;
                if([UserInfo sharedInstance].isInLiveRoom){
                    //[HUD showText:@"正在关闭直播间" atMode:MBProgressHUDModeIndeterminate];
                    if(tencent::av::AV_OK == [roomManager avExitRoom]){
                    }
                    else{
                        [HUD hideText:@"调用关闭直播间出错" atMode:MBProgressHUDModeText andDelay:1 andCompletion:^{
                            [self avStopContext];
                        }];
                    }
                }
            } fail:^(NSString *err) {
                [HUD hideText:err atMode:MBProgressHUDModeText andDelay:1 andCompletion:^{
                    if([UserInfo sharedInstance].isInLiveRoom){
                        //[HUD showText:@"正在关闭直播间" atMode:MBProgressHUDModeIndeterminate];
                        if(tencent::av::AV_OK == [roomManager avExitRoom]){
                        }
                        else{
                            [HUD hideText:@"调用关闭直播间出错" atMode:MBProgressHUDModeText andDelay:1 andCompletion:^{
                                [self avStopContext];
                            }];
                        }
                    }
                }];
            }];
        }
        else{
            //退出直播间
            if([UserInfo sharedInstance].isInLiveRoom){
                //[HUD showText:@"正在关闭直播间" atMode:MBProgressHUDModeIndeterminate];
                if(tencent::av::AV_OK == [roomManager avExitRoom]){
                }
                else{
                    [HUD hideText:@"调用关闭直播间出错" atMode:MBProgressHUDModeText andDelay:1 andCompletion:^{
                        [self avStopContext];
                    }];
                }
            }
        }
        if (crashTimer) {
            [crashTimer invalidate];
            crashTimer = nil;
        }
        if (curLivePhone) {
            curLivePhone = nil;
        }
    }
    if(LIVE_WATCH == [UserInfo sharedInstance].liveType){
        //观众退出聊天室
        if([UserInfo sharedInstance].isInChatRoom){
            //[HUD showText:@"正在退出聊天室" atMode:MBProgressHUDModeIndeterminate];
            [[MultiIMManager sharedInstance] quitGroup:[UserInfo sharedInstance].chatRoomId succ:^(NSString *msg) {
                [UserInfo sharedInstance].isInChatRoom = NO;
                if([UserInfo sharedInstance].isInLiveRoom){
                    //[HUD showText:@"正在离开直播间" atMode:MBProgressHUDModeIndeterminate];
                    if(tencent::av::AV_OK == [roomManager avExitRoom]){
                    }
                    else{
                        [HUD hideText:@"调用离开直播间出错" atMode:MBProgressHUDModeText andDelay:1 andCompletion:^{
                            [self avStopContext];
                        }];
                    }
                }
            } fail:^(NSString *err) {
                [HUD hideText:err atMode:MBProgressHUDModeText andDelay:1 andCompletion:^{
                    if([UserInfo sharedInstance].isInLiveRoom){
                        //[HUD showText:@"正在离开直播间" atMode:MBProgressHUDModeIndeterminate];
                        if(tencent::av::AV_OK == [roomManager avExitRoom]){
                        }
                        else{
                            [HUD hideText:@"调用离开直播间出错" atMode:MBProgressHUDModeText andDelay:1 andCompletion:^{
                                [self avStopContext];
                            }];
                        }
                    }
                }];
            }];
        }
        else{
            //离开直播间
            if([UserInfo sharedInstance].isInLiveRoom){
                //[HUD showText:@"正在离开直播间" atMode:MBProgressHUDModeIndeterminate];
                if(tencent::av::AV_OK == [roomManager avExitRoom]){
                }
                else{
                    [HUD hideText:@"调用离开直播间出错" atMode:MBProgressHUDModeText andDelay:1 andCompletion:^{
                        [self avStopContext];
                    }];
                }
            }
        }
    }
}
- (void)avRequestView{
    //[HUD showText:@"正在请求画面" atMode:MBProgressHUDModeIndeterminate];
    [roomManager avRequestViewPhone:[UserInfo sharedInstance].liveUserPhone succ:^(NSString *msg) {
    } fail:^(NSString *error) {
        [HUD hideText:error atMode:MBProgressHUDModeText andDelay:1 andCompletion:^{
            [self avExitRoom];
        }];
    }];
}
- (void)avToggleCamera{
    [roomManager avToggleCamera];
}

- (void)synLiveTime{
    
}
- (void)modLiveTime{
    NSString* nowTime = _livingView.livingTimeLabel.text;
    NSArray *array = [nowTime componentsSeparatedByString:@":"];
    int hour = [[array objectAtIndex:0] intValue];
    int minute = [[array objectAtIndex:1] intValue];
    int second = [[array objectAtIndex:2] intValue];
    NSString* newTime = @"";
    second++;
    if(second >= 60){
        second = second%60;
        minute += 1;
    }
    if(minute >= 60){
        minute = minute%60;
        hour += 1;
    }
    if(hour >= 60){
        hour = hour%60;
    }
    newTime = [newTime stringByAppendingFormat:@"%d%d:",hour/10,hour%10];
    newTime = [newTime stringByAppendingFormat:@"%d%d:",minute/10,minute%10];
    newTime = [newTime stringByAppendingFormat:@"%d%d",second/10,second%10];
    _livingView.livingTimeLabel.text = newTime;
}
#pragma mark 消息代理
- (void)onNewMessage:(NSArray *)msgs{
    for(TIMMessage* msg in msgs)
    {
        if (msg.getConversation.getType == TIM_SYSTEM)
        {
            for(int index=0;index<[msg elemCount];index++)
            {
                TIMElem* elem = [msg getElem:index];
                if ([elem isKindOfClass:[TIMGroupSystemElem class]])
                {
                    TIMGroupSystemElem *item = (TIMGroupSystemElem *)elem;
                    
                    if ([item.group isEqualToString:[UserInfo sharedInstance].chatRoomId])
                    {
                        if (item.type == TIM_GROUP_SYSTEM_DELETE_GROUP_TYPE)
                        {
                            FinishView* fv = [[FinishView alloc] init];
                            fv.titleLabel.text = @"主播已经离开";
                            NSString* audience = _livingView.userCountLabel.text;
                            NSString* praise = _livingView.loveCountLabel.text;
                            fv.delegate = self;
                            [fv showView:self.view audience:audience praise:praise];

                            return;
                        }
                    }
                }
            }
            
        }

        if(![[msg.getConversation getReceiver] isEqualToString:[UserInfo sharedInstance].chatRoomId])
        {
            //只接受来着该聊天室的消息
            continue;
        }
        for(int index=0;index<[msg elemCount];index++){
            TIMElem* elem = [msg getElem:index];
            if([elem isKindOfClass:[TIMTextElem class]]){
                //消息
                TIMTextElem* textElem = (TIMTextElem*)elem;
                NSArray* phones = [(NSString*)msg.sender componentsSeparatedByString:@"-"];
                if(2 != phones.count ){
                    //数据错误
                    continue;
                }
                [_livingView addMessage:textElem.text andPhone:phones[1]];
            }
            else if([elem isKindOfClass:[TIMCustomElem class]]){
                TIMCustomElem* customElem = (TIMCustomElem*)elem;
                NSString* data = [[NSString alloc] initWithData:customElem.data encoding:NSUTF8StringEncoding];
                NSArray* array = [data componentsSeparatedByString:MSG_SEPERATOR];
                if(array.count < 2){
                    return;
                }
                
                NSString* userPhone = array[0];
                int cmd = [array[1] intValue];
                switch (cmd) {
                    case MSG_CMD_PRAISE:
                        if(3 == array.count){
                            NSInteger addCount = [array[2] integerValue];
                            [_livingView addLove:addCount];
                        }
                        break;
                    case MSG_CMD_ADDUSER:
                        if(4 == array.count){
                            NSString* userName = array[2];
                            NSString* userLogo = array[3];
                            NSDictionary* userDic = [[NSDictionary alloc] initWithObjectsAndKeys:
                                                     userPhone,@"userPhone",
                                                     userName,@"userName",
                                                     userLogo,@"userLogo",nil];
                            NSArray* newUser = [NSArray arrayWithObjects:userDic, nil];
                            [_livingView addUsers:newUser];
                            [_livingView addWelcome:userName];
                        }
                        break;
                    case MSG_CMD_DELUSER:
                        if(2 == array.count){
                            NSArray* delUser = [NSArray arrayWithObjects:userPhone, nil];
                            [_livingView delUsers:delUser];
                            //主播离开
                            if([userPhone isEqualToString:[UserInfo sharedInstance].liveUserPhone] &&
                               ![userPhone isEqualToString:[UserInfo sharedInstance].userPhone]){
                                FinishView* fv = [[FinishView alloc] init];
                                fv.titleLabel.text = @"主播已经离开";
                                NSString* audience = _livingView.userCountLabel.text;
                                NSString* praise = _livingView.loveCountLabel.text;
                                fv.delegate = self;
                                [fv showView:self.view audience:audience praise:praise];
                            }
                        }
                        break;
                    default:
                        break;
                }
            }
        }
    }
}

#pragma mark dismiss view
- (void)dismissController{
    [UserInfo sharedInstance].liveType = LIVE_NONE;
    [self dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark finishview 代理
- (void)finishViewClose:(FinishView *)fv{
    [self.view bringSubviewToFront:HUD];
    [self avExitChat];
}
@end

