//
//  Business.h
//  live
//
//  Created by hysd on 15/8/6.
//  Copyright (c) 2015年 kenneth. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFHTTPRequestOperationManager.h"

/**
 *  成功回调
 */
typedef void (^businessSucc)(NSString* msg, id data);
/**
 *  失败回调
 */
typedef void (^businessFail)(NSString *error);
@interface Business : NSObject
/**
 * 获取单例
 */
+ (Business*) sharedInstance;
/**
 *  登录
 *  @param phone  账号（电话号码）
 *  @param succ   成功回调
 *  @param fail   失败回调
 */
- (void)loginPhone:(NSString*)phone pass:(NSString*)pass succ:(businessSucc)succ fail:(businessFail)fail;
/**
 *  获取房间号
 *  @param succ   成功回调
 *  @param fail   失败回调
 */
- (void)getRoomnumSucc:(businessSucc)succ fail:(businessFail)fail;
/**
 *  插入创建直播到数据库
 *  @param title  直播标题
 *  @param phone  账号（电话号码）
 *  @param room   直播房间号
 *  @param chat   聊天室号码
 *  @param image  直播封面
 *  @param succ   成功回调
 *  @param fail   失败回调
 */
- (void)insertLive:(NSString*)tilte phone:(NSString*)phone room:(NSInteger)room chat:(NSString*)chat addr:(NSString*)addr image:(UIImage*)image succ:(businessSucc)succ fail:(businessFail)fail;
/**
 *  插入进入直播到数据库
 *  @param phone  观众账号（电话号码）
 *  @param room   直播房间号
 *  @param succ   成功回调
 *  @param fail   失败回调
 */
- (void)enterRoom:(NSInteger)room phone:(NSString*)phone succ:(businessSucc)succ fail:(businessFail)fail;
/**
 *  获取用户信息
 *  @param phone  账号（电话号码）
 *  @param succ   成功回调
 *  @param fail   失败回调
 */
- (void)getUserInfoByPhone:(NSString*)phone succ:(businessSucc)succ fail:(businessFail)fail;
/**
 *  点赞
 *  @param room   房间号
 *  @param count  增加点赞数
 *  @param succ   成功回调
 *  @param fail   失败回调
 */
-(void)loveLive:(NSInteger)room addCount:(int)count succ:(businessSucc)succ fail:(businessFail)fail;
/**
 *  关闭房间
 *  @param room   房间号
 *  @param succ   成功回调
 *  @param fail   失败回调
 */
-(void)closeRoom:(NSInteger)room succ:(businessSucc)succ fail:(businessFail)fail;
/**
 *  离开房间
 *  @param room   房间号
 *  @param phone  用户手机
 *  @param succ   成功回调
 *  @param fail   失败回调
 */
- (void)leaveRoom:(NSInteger)room phone:(NSString*)phone succ:(businessSucc)succ fail:(businessFail)fail;
/**
 *  日志上报
 *  @param phone  用户手机
 *  @param log    日志
 */
- (void)logReport:(NSString*)phone log:(NSString*)log;
/**
 *  获取用户列表
 *  @param phones  用户手机号（15002626262&15282837462）
 *  @param succ   成功回调
 *  @param fail   失败回调
 */
- (void)getUserList:(NSString*)phones succ:(businessSucc)succ fail:(businessFail)fail;
/**
 *  获取用户列表
 *  @param room   房间id
 *  @param succ   成功回调
 *  @param fail   失败回调
 */
- (void)getUserListByRoom:(NSInteger)room succ:(businessSucc)succ fail:(businessFail)fail;
/**
 *  获取直播信息
 *  @param room   房间id
 *  @param succ   成功回调
 *  @param fail   失败回调
 */
- (void)getLive:(NSInteger)room succ:(businessSucc)succ fail:(businessFail)fail;
/**
 *  保存用户信息
 *  @param phone  账号（电话号码）
 *  @param name   用户昵称
 *  @param gender 写别
 *  @param address地址
 *  @param sig    个人签名
 *  @param image  头像
 *  @param succ   成功回调
 *  @param fail   失败回调
 */
- (void)saveUserInfo:(NSString*)phone name:(NSString*)name gender:(NSString*)gender address:(NSString*)address signature:(NSString*)sig image:(UIImage*)image succ:(businessSucc)succ fail:(businessFail)fail;
/**
 *  保存用户信息
 *  @param phone  账号（电话号码）
 *  @param key    字段名
 *  @param value  字段值
 *  @param succ   成功回调
 *  @param fail   失败回调
 */
- (void)saveUserInfo:(NSString*)phone key:(NSString*)key value:(NSString*)value succ:(businessSucc)succ fail:(businessFail)fail;
/**
 *  保存用户头像
 *  @param phone  账号（电话号码）
 *  @param image  头像
 *  @param succ   成功回调
 *  @param fail   失败回调
 */
- (void)saveUserInfo:(NSString*)phone image:(UIImage*)image succ:(businessSucc)succ fail:(businessFail)fail;
/**
 *  插入预告数据
 *  @param title  标题
 *  @param phone  账号（电话号码）
 *  @param time   时间
 *  @param image  封面
 *  @param succ   成功回调
 *  @param fail   失败回调
 */
- (void)insertTrailer:(NSString*)tilte phone:(NSString*)phone time:(NSString*)time image:(UIImage*)image succ:(businessSucc)succ fail:(businessFail)fail;
/**
 *  获取预告列表
 *  @param lastTime 最新时间
 *  @param succ   成功回调
 *  @param fail   失败回调
 */
- (void)getTrailers:(NSString*)lastTime succ:(businessSucc)succ fail:(businessFail)fail;
/**
 *  获取直播列表
 *  @param lastTime 最新时间
 *  @param succ   成功回调
 *  @param fail   失败回调
 */
- (void)getLives:(NSString*)lastTime succ:(businessSucc)succ fail:(businessFail)fail;
/**
 *  心跳检查,主播房间是否还存在
 *  @param phone 主播电话
 */
- (void)heartBeatCheckCrash:(NSString*)phone;
@end
