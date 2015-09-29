//
//  TLSLogin.h
//  live
//
//  Created by hysd on 15/8/17.
//  Copyright (c) 2015年 kenneth. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <TLSSDK/TLSLoginHelper.h>


/**
 *  登录事件回调
 */
@protocol TLSSmsLoginListenerImplDelegate <NSObject>
- (void)OnSmsLoginAskCodeSuccess:(int)reaskDuration andExpireDuration:(int)expireDuration;
- (void)OnSmsLoginFail:(TLSErrInfo *)errInfo;
- (void)OnSmsLoginReaskCodeSuccess:(int)reaskDuration andExpireDuration:(int)expireDuration;
- (void)OnSmsLoginSuccess:(TLSUserInfo *)userInfo;
- (void)OnSmsLoginTimeout:(TLSErrInfo *)errInfo;
- (void)OnSmsLoginVerifyCodeSuccess;
@end
@interface TLSSmsLoginListenerImpl : NSObject <TLSSmsLoginListener>
@property (nonatomic, weak) id <TLSSmsLoginListenerImplDelegate> delegate;
- (void)OnSmsLoginAskCodeSuccess:(int)reaskDuration andExpireDuration:(int)expireDuration;
- (void)OnSmsLoginFail:(TLSErrInfo *)errInfo;
- (void)OnSmsLoginReaskCodeSuccess:(int)reaskDuration andExpireDuration:(int)expireDuration;
- (void)OnSmsLoginSuccess:(TLSUserInfo *)userInfo;
- (void)OnSmsLoginTimeout:(TLSErrInfo *)errInfo;
- (void)OnSmsLoginVerifyCodeSuccess;
@end

@interface TLSLogin : NSObject
/**
 * 获取单例
 */
+ (TLSLogin*) sharedInstance;
@property (strong,nonatomic) TLSSmsLoginListenerImpl* smsLoginListenerImpl;
@property (strong,nonatomic) TLSLoginHelper* loginHelper;
/**
 *  获取验证码
 *  @param phone    账号（电话号码）
 */
- (void)askAuthCode:(NSString*)phone;
/**
 *  验证验证码
 *  @param code 验证码
 *  @param phone 用户手机号码
 */
- (void)verifyAuthCode:(NSString*)code andPhone:(NSString*)phone;
/**
 *  提交登录
 *  @param phone 用户手机号码
 */
- (void)loginCommit:(NSString*)phone;
@end
