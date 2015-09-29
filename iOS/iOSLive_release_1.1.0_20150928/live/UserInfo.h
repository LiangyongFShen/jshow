//
//  UserInfo.h
//  live
//
//  Created by hysd on 15/7/28.
//  Copyright (c) 2015年 kenneth. All rights reserved.
//

#import <Foundation/Foundation.h>
enum LIVETYPE {
    LIVE_WATCH = 0,//看直播
    LIVE_DOING = 1,//直播
    LIVE_NONE = 2
};
enum ENVIRONMENT {
    ENVIRONMENT_FORMAL = 0,//正式
    ENVIRONMENT_TEST = 1,//测试
};

@interface UserInfo : NSObject
+ (UserInfo *) sharedInstance;
//应用信息
@property (strong,nonatomic) NSString* sdkAppId;
@property (strong,nonatomic) NSString* accountType;
//环境
@property (nonatomic) enum ENVIRONMENT environment;
//用户信息
@property (nonatomic) BOOL isLogin;
@property (strong,nonatomic) NSString* userPhone;
@property (strong,nonatomic) NSString* userName;
@property (strong,nonatomic) NSString* userLogo;
@property (strong,nonatomic) NSString* userSignature;
@property (strong,nonatomic) NSString* userAddress;
@property (strong,nonatomic) NSString* userGender;
//通信钥匙
@property (strong,nonatomic) NSString* userSig;
//直播信息
@property (nonatomic) BOOL isInLiveRoom;//是否进入房间
@property (nonatomic) BOOL isInChatRoom;//是否进入房间
@property (nonatomic) NSInteger tmpLiveRoomId;//获取房间号，创建成功后赋予liveRoomId,用户未退出上一个房间时，上一个房间的id不会被此次分配的房间id覆盖
@property (nonatomic) NSInteger liveRoomId;
@property (strong,nonatomic) NSString* chatRoomId;
@property (nonatomic) enum LIVETYPE liveType;
@property (strong,nonatomic) NSString* liveTime;
@property (strong,nonatomic) NSString* liveTitle;
@property (strong,nonatomic) NSString* liveUserPhone;
@property (strong,nonatomic) NSString* liveUserName;
@property (strong,nonatomic) NSString* liveUserLogo;
@property (strong,nonatomic) NSString* livePraiseNum;
@property (strong,nonatomic) NSString* liveAddr;
/**
 *  从数据库设置用户信息
 *  @param sig    签名
 *  @param info   用户信息
 */
- (void)setUserFromDBSig:(NSString*)sig andInfo:(NSDictionary*)info;
/**
 *  从本地设置用户信息
 *  @param info   用户信息
 */
- (void)setUserFromLocalInfo:(NSDictionary*)info;
/**
 *  从本地设置用户上次进入直播间或自己直播的信息
 *  @param info   直播信息
 */
- (void)setLiveFromLocalInfo:(NSDictionary*)live;
/**
 *  保存直播信息
 */
- (void)saveLiveToLocal;
/**
 *  保存用户信息
 */
- (void)saveUserToLocal;
/**
 *  重置直播信息
 */
- (void)resetLiveInfo;
/**
 *  重置信息
 */
- (void)resetInfo;
/**
 *  保存crash信息
 *  @param log   crash日志
 */
- (void)saveCrash:(NSString*)log;
/**
 *  获取crash信息
 *  @return   crash日志
 */
- (NSString*)getCrash;
/**
 *  设置环境
 *  @param env  环境
 */
- (void)setEnv:(NSNumber*)env;
@end
