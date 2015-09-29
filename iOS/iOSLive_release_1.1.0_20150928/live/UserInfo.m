//
//  UserInfo.m
//  live
//
//  Created by hysd on 15/7/28.
//  Copyright (c) 2015年 kenneth. All rights reserved.
//

#import "UserInfo.h"

static UserInfo *sharedObj = nil; //第一步：静态实例，并初始化。
@implementation UserInfo
+ (UserInfo*) sharedInstance  //第二步：实例构造检查静态实例是否为nil
{
    @synchronized (self)
    {
        if (sharedObj == nil)
        {
            sharedObj = [[self alloc] init];
        }
    }
    return sharedObj;
}

+ (id) allocWithZone:(NSZone *)zone //第三步：重写allocWithZone方法
{
    @synchronized (self) {
        if (sharedObj == nil) {
            sharedObj = [super allocWithZone:zone];
            return sharedObj;
        }
    }
    return nil;
}

- (id) copyWithZone:(NSZone *)zone //第四步
{
    return self;
}

- (id)init
{
    @synchronized(self) {
        self = [super init];
        self.environment = ENVIRONMENT_FORMAL;
        self.isLogin = NO;
        self.userPhone = @"";
        self.userName = @"";
        self.userSignature = @"";
//        self.sdkAppId = @"1400001237";
//        self.accountType = @"766";
        self.sdkAppId = @"1400001692";
        self.accountType = @"884";
        self.liveType = LIVE_NONE;
        self.isInChatRoom = NO;
        self.isInLiveRoom = NO;
        return self;
    }
}

- (void)setUserFromDBSig:(NSString*)sig andInfo:(NSDictionary*)info{
    self.isLogin = YES;
    self.userSig = sig;
    self.userPhone = [info objectForKey:@"userphone"];
    self.userName = [info objectForKey:@"username"];
    self.userLogo = [info objectForKey:@"headimagepath"];
    self.userSignature = [info objectForKey:@"signature"];
    self.userAddress = [info objectForKey:@"address"];
    self.userGender = ([[info objectForKey:@"sex"] intValue] == 0?@"男":@"女");
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSDictionary* userDic = [[NSDictionary alloc] initWithObjectsAndKeys:
                             @"yes",@"isLogin",
                             self.userSig,@"userSig",
                             self.userPhone,@"userPhone",
                             self.userLogo,@"userLogo",
                             self.userName,@"userName",
                             self.userAddress,@"userAddress",
                             self.userGender,@"userSex",
                             self.userSignature,@"userSignature",nil];
    [userDefaults setObject:userDic forKey:@"userInfo"];
}
- (void)saveUserToLocal{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSDictionary* userDic = [[NSDictionary alloc] initWithObjectsAndKeys:
                             @"yes",@"isLogin",
                             self.userSig,@"userSig",
                             self.userPhone,@"userPhone",
                             self.userLogo,@"userLogo",
                             self.userName,@"userName",
                             self.userAddress,@"userAddress",
                             self.userGender,@"userSex",
                             self.userSignature,@"userSignature",nil];
    [userDefaults setObject:userDic forKey:@"userInfo"];
}
- (void)saveLiveToLocal{
    NSString* isInLiveRoom;
    if(self.isInLiveRoom){
        isInLiveRoom = @"yes";
    }
    else{
        isInLiveRoom = @"no";
    }
    NSString* isInChatRoom;
    if(self.isInChatRoom){
        isInChatRoom = @"yes";
    }
    else{
        isInChatRoom = @"no";
    }
    NSString* liveRoomId = [NSString stringWithFormat:@"%ld", (long)self.liveRoomId];
    NSString* liveType = [NSString stringWithFormat:@"%d",self.liveType];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSDictionary* liveDic = [[NSDictionary alloc] initWithObjectsAndKeys:
                             isInLiveRoom,@"isInLiveRoom",
                             isInChatRoom,@"isInChatRoom",
                             liveType,@"liveType",
                             liveRoomId,@"liveRoomId",
                             self.chatRoomId,@"chatRoomId",
                             self.liveUserPhone,@"liveUserPhone",nil];
    [userDefaults setObject:liveDic forKey:@"liveInfo"];
}

- (void)setLiveFromLocalInfo:(NSDictionary*)live{
    if(live != nil){
        NSString* isInLiveRoom = [live objectForKey:@"isInLiveRoom"];
        if([isInLiveRoom isEqualToString:@"yes"]){
            self.isInLiveRoom = YES;
        }
        else{
            self.isInLiveRoom = NO;
        }
        NSString* isInChatRoom = [live objectForKey:@"isInChatRoom"];
        if([isInChatRoom isEqualToString:@"yes"]){
            self.isInChatRoom = YES;
        }
        else{
            self.isInChatRoom = NO;
        }
        self.liveType = [[live objectForKey:@"liveType"] intValue];
        self.liveRoomId = [[live objectForKey:@"liveRoomId"] integerValue];
        self.chatRoomId = [live objectForKey:@"chatRoomId"];
        self.liveUserPhone = [live objectForKey:@"liveUserPhone"];
    }
}
- (void)resetLiveInfo{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSDictionary* userDic = [[NSDictionary alloc] initWithObjectsAndKeys:
                             @"no",@"isInLiveRoom",
                             @"no",@"isInChatRoom",
                             @"0",@"liveType",
                             @"0",@"liveRoomId",
                             @"0",@"chatRoomId",
                             @"",@"liveUserPhone",nil];
    [userDefaults setObject:userDic forKey:@"liveInfo"];
}
- (void)setUserFromLocalInfo:(NSDictionary*)info{
    if(info != nil){
        NSString* login = [info objectForKey:@"isLogin"];
        if([login isEqualToString:@"yes"]){
            self.isLogin = YES;
        }
        else{
            self.isLogin = NO;
        }
        self.userPhone = [info objectForKey:@"userPhone"];
        self.userLogo = [info objectForKey:@"userLogo"];
        self.userName = [info objectForKey:@"userName"];
        self.userSignature = [info objectForKey:@"userSignature"];
        self.userSig = [info objectForKey:@"userSig"];
        self.userAddress = [info objectForKey:@"userAddress"];
        self.userGender = [info objectForKey:@"userSex"];
    }
}
- (void)resetUserInfo{
    self.isLogin = NO;
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSDictionary* userDic = [[NSDictionary alloc] initWithObjectsAndKeys:
                             @"no",@"isLogin",
                             @"",@"userSig",
                             @"",@"userPhone",
                             @"",@"userLogo",
                             @"",@"userName",
                             @"",@"userAddress",
                             @"",@"userSex",
                             @"",@"userSignature",nil];
    [userDefaults setObject:userDic forKey:@"userInfo"];
}

- (void)saveCrash:(NSString*)log{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:log forKey:@"crash"];
}
- (NSString*)getCrash{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString* log = [userDefaults objectForKey:@"crash"];
    [userDefaults setObject:@"" forKey:@"crash"];
    if(log == nil){
        log = @"";
    }
    return log;
}
- (void)resetCrash{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:@"" forKey:@"crash"];
}
- (void)resetInfo{
    [self resetUserInfo];
    [self resetLiveInfo];
    [self resetCrash];
}

- (void)setEnv:(NSNumber*)env{
    if(env != nil){
        self.environment = [env intValue];
    }
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
   [userDefaults setObject:[NSNumber numberWithInt:self.environment] forKey:@"environment"];
    [userDefaults synchronize];
}
@end