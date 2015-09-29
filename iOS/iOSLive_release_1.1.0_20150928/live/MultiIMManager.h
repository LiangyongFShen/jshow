//
//  MultiIMManager.h
//  live
//
//  Created by hysd on 15/8/7.
//  Copyright (c) 2015年 kenneth. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ImSDK/TIMManager.h>
#import <ImSDK/TIMGroupManager.h>
enum NETWORK_STATUS{
    NETWORK_CONN = 0,
    NETWORK_FAIL,
    NETWORK_DISCONN
};
/**
 *  网络事件回调
 */
@protocol TIMConnListenerImplDelegate <NSObject>
- (void)onConnSucc;
- (void)onConnFailed:(int)code err:(NSString*)err;
- (void)onDisconnect:(int)code err:(NSString*)err;
@end
@interface TIMConnListenerImpl : NSObject <TIMConnListener>
@property (nonatomic, weak) id <TIMConnListenerImplDelegate> delegate;
- (void)onConnSucc;
- (void)onConnFailed:(int)code err:(NSString*)err;
- (void)onDisconnect:(int)code err:(NSString*)err;
@end


/**
 *  聊天信息回调
 */
@protocol TIMMessageListenerImplDelegate <NSObject>
- (void)onNewMessage:(NSArray*)msgs;
@end
@interface TIMMessageListenerImpl : NSObject<TIMMessageListener>
@property (nonatomic, weak) id <TIMMessageListenerImplDelegate> delegate;
- (void)onNewMessage:(TIMMessage *)msg;
@end

/**
 *  成功回调
 */
typedef void (^imSucc)(NSString *msg);
/**
 *  失败回调
 */
typedef void (^imFail)(NSString * err);

@interface MultiIMManager : NSObject
/**
 * 获取单例
 */
+ (MultiIMManager*) sharedInstance;
@property (strong,nonatomic) TIMMessageListenerImpl* messageListenerImpl;
@property (strong,nonatomic) TIMConnListenerImpl* connListenerImpl;
@property (strong,nonatomic) TIMConversation* conversation;
/**
 *  登录
 *  @param phone    账号（电话号码）
 *  @param succ     成功回调
 *  @param fail     失败回调
 *  @return 0       请求成功
 */
- (int)loginPhone:(NSString*)phone sig:(NSString*)sig succ:(imSucc)succ fail:(imFail)fail;
/**
 *  登录
 *  @param phone  账号（电话号码）
 *  @param succ   成功回调
 *  @param fail   失败回调
 *  @return 0     请求成功
 */
- (int)logoutSucc:(imSucc)succ fail:(imFail)fail;
/**
 *  解散聊天室
 *  @param roomId 房间号
 *  @param succ   成功回调
 *  @param fail   失败回调
 */
- (void)deleteGroup:(NSString*)roomId succ:(imSucc)succ fail:(imFail)fail;
/**
 *  退出聊天室
 *  @param roomId 房间号
 *  @param succ   成功回调
 *  @param fail   失败回调
 */
- (void)quitGroup:(NSString*)roomId succ:(imSucc)succ fail:(imFail)fail;
/**
 *  加入聊天室
 *  @param roomId 房间号
 *  @param succ   成功回调
 *  @param fail   失败回调
 */
- (void)joinGroup:(NSString*)roomId succ:(imSucc)succ fail:(imFail)fail;
/**
 *  创建聊天室
 *  @param succ   成功回调
 *  @param fail   失败回调
 */
- (void)createGroupSucc:(imSucc)succ fail:(imFail)fail;
/**
 *  是否已经登录
 *  @return BOOL  是否已经登陆
 */
-(BOOL)isLogin;
@end
