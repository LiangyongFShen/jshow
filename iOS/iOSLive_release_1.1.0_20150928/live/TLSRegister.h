//
//  TLSRegister.h
//  live
//
//  Created by hysd on 15/8/14.
//  Copyright (c) 2015年 kenneth. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <TLSSDK/TLSAccountHelper.h>

/**
 *  注册事件回调
 */
@protocol TLSSmsRegListenerImplDelegate <NSObject>
- (void)OnSmsRegAskCodeSuccess:(int)reaskDuration andExpireDuration:(int)expireDuration;
- (void)OnSmsRegReaskCodeSuccess:(int)reaskDuration andExpireDuration:(int)expireDuration;
- (void)OnSmsRegVerifyCodeSuccess;
- (void)OnSmsRegCommitSuccess:(TLSUserInfo *)userInfo;
- (void)OnSmsRegFail:(TLSErrInfo *)errInfo;
- (void)OnSmsRegTimeout:(TLSErrInfo *)errInfo;
@end
@interface TLSSmsRegListenerImpl : NSObject <TLSSmsRegListener>
@property (nonatomic, weak) id <TLSSmsRegListenerImplDelegate> delegate;
- (void)OnSmsRegAskCodeSuccess:(int)reaskDuration andExpireDuration:(int)expireDuration;
- (void)OnSmsRegReaskCodeSuccess:(int)reaskDuration andExpireDuration:(int)expireDuration;
- (void)OnSmsRegVerifyCodeSuccess;
- (void)OnSmsRegCommitSuccess:(TLSUserInfo *)userInfo;
- (void)OnSmsRegFail:(TLSErrInfo *)errInfo;
- (void)OnSmsRegTimeout:(TLSErrInfo *)errInfo;
@end


@interface TLSRegister : NSObject
/**
 * 获取单例
 */
+ (TLSRegister*) sharedInstance;
@property (strong,nonatomic) TLSSmsRegListenerImpl* smsRegListenerImpl;
@property (strong,nonatomic) TLSAccountHelper* accountHelper;
/**
 *  获取验证码
 *  @param phone    账号（电话号码）
 */
- (void)askAuthCode:(NSString*)phone;
/**
 *  验证验证码
 *  @param code 验证码
 */
- (void)verifyAuthCode:(NSString*)code;
/**
 *  提交注册
 */
- (void)registerCommit;
@end
