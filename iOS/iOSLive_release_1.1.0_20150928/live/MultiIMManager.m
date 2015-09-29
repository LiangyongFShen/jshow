//
//  MultiIMManager.m
//  live
//
//  Created by hysd on 15/8/7.
//  Copyright (c) 2015年 kenneth. All rights reserved.
//

#import "MultiIMManager.h"
#import "UserInfo.h"


#define CHATGROUP_ALREADY 10013
#define CHATGROUP_NOTEXIST 10010
@implementation TIMConnListenerImpl
- (void)onConnSucc {
    if(self.delegate){
        [self.delegate onConnSucc];
    }
}
- (void)onConnFailed:(int)code err:(NSString*)err {
    if(self.delegate){
        [self.delegate onConnFailed:code err:err];
    }
}
- (void)onDisconnect:(int)code err:(NSString*)err {
    if(self.delegate){
        [self.delegate onDisconnect:code err:err];
    }
}
@end

@implementation TIMMessageListenerImpl
- (void)onNewMessage:(NSArray *)msgs{
    if(self.delegate){
        [self.delegate onNewMessage:msgs];
    }
}
@end

@interface MultiIMManager(){
    
}
@end

@implementation MultiIMManager
static MultiIMManager *sharedObj = nil;

+ (MultiIMManager*) sharedInstance
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
- (id)init
{
    @synchronized(self) {
        self = [super init];
        [[TIMManager sharedInstance] setEnv:[UserInfo sharedInstance].environment];
        [[TIMManager sharedInstance] initSdk];
        return self;
    }
}

- (int)loginPhone:(NSString*)phone sig:(NSString*)sig succ:(imSucc)succ fail:(imFail)fail{
    
    self.messageListenerImpl = [[TIMMessageListenerImpl alloc] init];
    self.connListenerImpl = [[TIMConnListenerImpl alloc] init];
    [[TIMManager sharedInstance] setMessageListener:self.messageListenerImpl];
    [[TIMManager sharedInstance] setConnListener:self.connListenerImpl];
    //登录参数
    TIMLoginParam* loginParam = [[TIMLoginParam alloc] init];
    loginParam.accountType = [UserInfo sharedInstance].accountType;
    loginParam.identifier = [NSString stringWithFormat:@"86-%@", phone];
    loginParam.userSig = sig;
    loginParam.appidAt3rd = [UserInfo sharedInstance].sdkAppId;
    loginParam.sdkAppId = [[UserInfo sharedInstance].sdkAppId intValue];
    //发起登陆
    [[TIMManager sharedInstance] login:loginParam succ:^(){
        succ(@"登录IM成功");
    }fail:^(int code, NSString * err){
        fail(@"登录IM失败");
    }];
    return 0;
}

- (int)logoutSucc:(imSucc)succ fail:(imFail)fail{
    //发起退出
    return [[TIMManager sharedInstance] logout:^{
        self.connListenerImpl.delegate = nil;
        self.messageListenerImpl.delegate = nil;
        succ(@"退出IM成功");
    } fail:^(int code, NSString *err) {
        fail(@"退出IM失败");
    }];
}

- (void)deleteGroup:(NSString*)roomId succ:(imSucc)succ fail:(imFail)fail{
    [[TIMGroupManager sharedInstance] DeleteGroup:roomId succ:^{
        succ(@"解散聊天室成功");
    } fail:^(int code, NSString *err) {
        fail(@"解散聊天室失败");
    }];
}

- (void)quitGroup:(NSString*)roomId succ:(imSucc)succ fail:(imFail)fail{
    [[TIMGroupManager sharedInstance] QuitGroup:roomId succ:^{
        succ(@"退出聊天室成功");
    } fail:^(int code, NSString *err) {
        if(CHATGROUP_NOTEXIST == code){
            succ(@"退出聊天室成功");
        }
        else{
            fail(@"退出聊天室失败");
        }
    }];
}

- (void)joinGroup:(NSString*)roomId succ:(imSucc)succ fail:(imFail)fail{
    [[TIMGroupManager sharedInstance] JoinGroup:roomId msg:nil succ:^{
        //获取聊天室会话
        self.conversation = [[TIMManager sharedInstance] getConversation:TIM_GROUP receiver:roomId];
        succ(@"加入聊天室成功");
    }fail:^(int code, NSString* err){
        if(CHATGROUP_ALREADY == code){
            self.conversation = [[TIMManager sharedInstance] getConversation:TIM_GROUP receiver:roomId];
            succ(@"加入聊天室成功");
        }
        else if(CHATGROUP_NOTEXIST == code){
            fail(@"聊天室已经解散");
        }
        else{
            fail(@"加入聊天室失败");
        }
    }];
}

- (void)createGroupSucc:(imSucc)succ fail:(imFail)fail{
    [self clearGroupListSucc:^(NSString *msg) {
        NSMutableArray* members = [[NSMutableArray alloc] init];
        [members addObject:@"@@"];
        [[TIMGroupManager sharedInstance] CreateChatRoomGroup:members groupName:@"@@" succ:^(NSString* group){
            succ(group);
            //获取会话
            self.conversation = [[TIMManager sharedInstance] getConversation:TIM_GROUP receiver:group];
        }fail:^(int code, NSString* err){
            fail(@"创建聊天室失败");
        }];
    } fail:^(NSString *err) {
        fail(err);
    }];
}

- (void)clearGroupListSucc:(imSucc)succ fail:(imFail)fail{
    [[TIMGroupManager sharedInstance] GetGroupList:^(NSArray *list) {
        succ(@"获取群列表成功");
        for(int index = 0; index < list.count; index++){
            TIMGroupInfo* info = list[index];
            if([info.owner isEqualToString:[UserInfo sharedInstance].userPhone]){
                //删除创建的聊天室
                [self deleteGroup:info.group succ:^(NSString *msg) {
                    NSLog(@"delete group %@ success",info.group);
                } fail:^(NSString *err) {
                    NSLog(@"delete group %@ fail",info.group);
                }];
            }
            else{
                //退出加入的聊天室
                [self quitGroup:info.group succ:^(NSString *msg) {
                    NSLog(@"quit group %@ success",info.group);
                } fail:^(NSString *err) {
                    NSLog(@"quit group %@ success",info.group);
                }];
            }
        }
    } fail:^(int code, NSString *err) {
        fail(@"获取群列表失败");
    }];
}

-(BOOL)isLogin{
    return [[TIMManager sharedInstance] getLoginUser] == nil? NO : YES;
}
@end

