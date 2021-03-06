//
//  TIMConversation.h
//  ImSDK
//
//  Created by bodeng on 28/1/15.
//  Copyright (c) 2015 tencent. All rights reserved.
//

#ifndef ImSDK_TIMConversation_h
#define ImSDK_TIMConversation_h

#import "TIMComm.h"
#import "TIMCallback.h"

@class TIMMessage;

/**
 *  会话
 */
@interface TIMConversation : NSObject

/**
 *  初始化会话
 *
 *  @param type    会话类型
 *  @param recever 会话ID
 *
 *  @return 0 成功
 */
-(id) init:(TIMConversationType)type receiver:(NSString *)receiver;

/**
 *  发送消息
 *
 *  @param msg  消息体
 *  @param succ 发送成功时回调
 *  @param fail 发送失败时回调
 *
 *  @return 0 本次操作成功
 */
-(int) sendMessage: (TIMMessage*)msg succ:(TIMSucc)succ fail:(TIMFail)fail;

/**
 *  发送消息
 *
 *  @param msg 消息体
 *  @param cb  回调
 *
 *  @return 0 成功
 */
-(int) sendMessage: (TIMMessage*)msg cb:(id<TIMCallback>)cb;

/**
 *  获取本地消息
 *
 *  @param count 获取数量
 *  @param last  上次最后一条消息
 *  @param succ  成功时回调
 *  @param fail  失败时回调
 *
 *  @return 0 本次操作成功
 */
-(int) getMessage: (int)count last:(TIMMessage*)last succ:(TIMGetMsgSucc)succ fail:(TIMFail)fail;


/**
 *  获取本地消息
 *
 *  @param count 获取数量
 *  @param last  上次最后一条消息
 *  @param cb    回调
 *
 *  @return 0 成功
 */
-(int) getMessage: (int)count last:(TIMMessage*)last cb:(id<TIMGetMessageCallback>)cb;

/**
 *  设置已读消息
 *
 *  @param readed 会话内最近一条已读的消息
 *
 *  @return 0 表示成功
 */
-(int) setReadMessage: (TIMMessage*)readed;

/**
 *  获取该会话的未读计数
 *
 *  @return 返回未读计数
 */
-(int) getUnReadMessageNum;

/**
 *  获取会话人，单聊为对方账号，群聊为群组Id
 *
 *  @return 会话人
 */
-(NSString*) getReceiver;

/**
 *  获取会话类型
 *
 *  @return 会话类型
 */
-(TIMConversationType) getType;

@end


#endif
