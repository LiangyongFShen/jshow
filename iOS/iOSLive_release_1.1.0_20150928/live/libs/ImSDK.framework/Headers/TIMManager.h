//
//  TIMManager.h
//  ImSDK
//
//  Created by bodeng on 28/1/15.
//  Copyright (c) 2015 tencent. All rights reserved.
//

#ifndef ImSDK_TIMManager_h
#define ImSDK_TIMManager_h

#import "TIMComm.h"
#import "TIMMessage.h"
#import "TIMConversation.h"
#import "TIMCallback.h"

/////////////////////////////////////////////////////////
///  Tencent 开放 SDK API
/////////////////////////////////////////////////////////


/////////////////////////////////////////////////////////
///  回调协议
/////////////////////////////////////////////////////////

/**
 *  消息回调
 */
@protocol TIMMessageListener <NSObject>
@optional

/**
 *  新消息通知
 *
 *  @param msgs 新消息列表，TIMMessage 类型数组
 */
- (void)onNewMessage:(NSArray*) msgs;
@end


/*
@protocol TIMConversationRefreshListener <NSObject>
@optional
- (void) onRefreshConversation;
@end
*/

/**
 *  连接通知回调
 */
@protocol TIMConnListener <NSObject>
@optional

/**
 *  网络连接成功
 */
- (void)onConnSucc;

/**
 *  网络连接失败
 *
 *  @param code 错误码
 *  @param err  错误描述
 */
- (void)onConnFailed:(int)code err:(NSString*)err;

/**
 *  网络连接断开
 *
 *  @param code 错误码
 *  @param err  错误描述
 */
- (void)onDisconnect:(int)code err:(NSString*)err;

@end


/**
 *  用户在线状态通知
 */
@protocol TIMUserStatusListener <NSObject>
@optional
/**
 *  踢下线通知
 */
- (void)onForceOffline;

@end


/**
 *  通讯管理
 */
@interface TIMManager : NSObject


/**
 *  获取管理器实例
 *
 *  @return 管理器实例
 */
+(TIMManager*)sharedInstance;


/**
 *  初始化SDK
 *
 *  @return 0 成功
 */
-(int) initSdk;

/**
 *  禁用Crash上报，由用户自己上报，如果需要，必须在initSdk之前调用
 */
-(void) disableCrashReport;

/**
 *  登陆
 *
 *  @param param 登陆参数
 *  @param succ  成功回调
 *  @param fail  失败回调
 *
 *  @return 0 请求成功
 */
-(int) login: (TIMLoginParam *)param succ:(TIMLoginSucc)succ fail:(TIMFail)fail;

/**
 *  初始化存储，仅查看历史消息时使用，如果要收发消息等操作，如login成功，不需要调用此函数
 *
 *  @param param 登陆参数（userSig 不用填写）
 *  @param succ  成功回调，收到回调时，可以获取会话列表和消息
 *  @param fail  失败回调
 *
 *  @return 0 请求成功
 */
-(int) initStorage: (TIMLoginParam *)param succ:(TIMLoginSucc)succ fail:(TIMFail)fail;

/**
 *  获取当前登陆的用户
 *
 *  @return 如果登陆返回用户的identifier，如果未登录返回nil
 */
-(NSString*) getLoginUser;

/**
 *  登陆
 *
 *  @param param 登陆参数
 *  @param cb    回调
 *
 *  @return 0 登陆请求发送成功，等待回调
 */
-(int) login: (TIMLoginParam *)param cb:(id<TIMCallback>)cb;

/**
 *  登出
 *
 *  @param succ 成功回调，登出成功
 *  @param fail 失败回调，返回错误吗和错误信息
 *
 *  @return 0 发送登出包成功，等待回调
 */
-(int) logout:(TIMLoginSucc)succ fail:(TIMFail)fail;

/**
 *  登出
 *
 *  @deprecated 使用logout:fail 替代.
 *
 *  @return 0 成功
 */
-(int) logout;


/**
 *  获取会话
 *
 *  @param type 会话类型，TIM_C2C 表示单聊 TIM_GROUP 表示群聊
 *  @param receiver C2C 为对方用户 identifier， GROUP 为群组Id
 *
 *  @return 会话对象
 */
-(TIMConversation*) getConversation: (TIMConversationType)type receiver:(NSString *)receiver;

/**
 *  删除会话
 *
 *  @param type 会话类型，TIM_C2C 表示单聊 TIM_GROUP 表示群聊
 *  @param receiver    用户identifier 或者 群组Id
 *
 *  @return TRUE:删除成功  FALSE:删除失败
 */
-(BOOL) deleteConversation:(TIMConversationType)type receiver:(NSString*) receiver;

/**
 *  设置消息回调
 *
 *  @param listener 回调
 *
 *  @return 0 成功
 */
-(int) setMessageListener: (id<TIMMessageListener>)listener;

/**
 *  设置连接通知回调
 *
 *  @param listener 回调
 *
 *  @return 0 成功
 */
-(int) setConnListener: (id<TIMConnListener>)listener;

/**
 * 获取网络状态
 */
-(TIMNetworkStatus) networkStatus;

/**
 *  设置用户状态通知回调
 *
 *  @param listener 回调
 *
 *  @return 0 成功
 */
-(int) setUserStatusListener: (id<TIMUserStatusListener>)listener;

/**
 *  获取会话数量
 *
 *  @return 会话数量
 */
-(int) ConversationCount;

/**
 *  通过索引获取会话
 *
 *  @param index 索引
 *
 *  @return 返回对应的会话
 */
-(TIMConversation*) getConversationByIndex:(int)index;

/**
 *  设置Token
 *
 *  @param token token信息
 *
 *  @return 0 成功
 */
-(int) setToken: (TIMTokenParam *)token;

/**
 *  app 切后台时调用
 *
 *  @param param 上报参数
 *  @param succ  成功时回调
 *  @param fail  失败时回调
 *
 *  @return 0 表示成功
 */
-(int) doBackgroud: (TIMBackgroundParam*)param succ:(TIMSucc)succ fail:(TIMFail)fail;

/**
 *  切前台
 *
 *  @return 0 表示成功
 */
-(int) doForeground;


/**
 *  设置环境（在InitSdk之前调用）
 *
 *  @param env  0 正式环境（默认）
 *              1 测试环境
 *              2 beta 环境
 */
-(void)setEnv:(int)env;


/**
 *  发送消息
 *
 *  @param type    会话类型（C2C 或 群）
 *  @param receiver 会话标识
 *  @param msg     消息
 *  @param succ    成功回调
 *  @param fail    失败回调
 *
 *  @return 0 表示成功
 */
// -(int) sendMessage:(TIMConversationType)type receiver:(NSString *)receiver msg:(TIMMessage*)msg succ:(TIMSucc)succ fail:(TIMFail)fail;


/**
 *  设置日志函数
 *
 *  @param cb 日志函数，SDK打印日志会通过此函数返给调用方，内部不进行打印
 */
-(void) setLogFunc:(TIMLogFunc)cb;

/**
 *  设置日志监听
 *
 *  @param cb 日志监听，SDK打印日志会通过此接口返给调用方，内部不进行打印
 */
-(void) setLogListener:(id<TIMLogListener>)cb;


/**
 *  获取版本号
 *
 *  @return 返回版本号，字符串表示，例如v1.1.1
 */
-(NSString*) GetVersion;

/**
 *  打印日志，通过ImSDK提供的日志功能打印日志
 *
 *  @param level 日志级别
 *  @param tag   模块tag
 *  @param msg   要输出的日志内容
 */
-(void) log:(TIMLogLevel)level tag:(NSString*)tag msg:(NSString*)msg;

/**
 *  上传指定时间的日志
 *
 *  @param logtime 指定的时间
 */
-(void) uploadImSDKLogs:(uint64_t)logtime;

@end



#endif
