//
//  TLSLogin.m
//  live
//
//  Created by hysd on 15/8/17.
//  Copyright (c) 2015年 kenneth. All rights reserved.
//

#import "TLSLogin.h"
#import "MultiIMManager.h"
#import "UserInfo.h"
@implementation TLSSmsLoginListenerImpl
- (void)OnSmsLoginAskCodeSuccess:(int)reaskDuration andExpireDuration:(int)expireDuration{
    if(self.delegate){
        [self.delegate OnSmsLoginAskCodeSuccess:reaskDuration andExpireDuration:expireDuration];
    }
}
- (void)OnSmsLoginFail:(TLSErrInfo *)errInfo{
    if(self.delegate){
        [self.delegate OnSmsLoginFail:errInfo];
    }
}
- (void)OnSmsLoginReaskCodeSuccess:(int)reaskDuration andExpireDuration:(int)expireDuration{
    if(self.delegate){
        [self.delegate OnSmsLoginReaskCodeSuccess:reaskDuration andExpireDuration:expireDuration];
    }
}
- (void)OnSmsLoginSuccess:(TLSUserInfo *)userInfo{
    if(self.delegate){
        [self.delegate OnSmsLoginSuccess:userInfo];
    }
}
- (void)OnSmsLoginTimeout:(TLSErrInfo *)errInfo{
    if(self.delegate){
        [self.delegate OnSmsLoginTimeout:errInfo];
    }
}
- (void)OnSmsLoginVerifyCodeSuccess{
    if(self.delegate){
        [self.delegate OnSmsLoginVerifyCodeSuccess];
    }
}
@end

@interface TLSLogin(){
}
@end
@implementation TLSLogin
static TLSLogin *sharedObj = nil;

+ (TLSLogin*) sharedInstance
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
        NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
        self.loginHelper = [[TLSLoginHelper getInstance] init:[[UserInfo sharedInstance].sdkAppId intValue]
                                                   andAccountType:[[UserInfo sharedInstance].accountType intValue]
                                                    andAppVer:version];
        [self.loginHelper setLogcat:YES];
        self.smsLoginListenerImpl = [[TLSSmsLoginListenerImpl alloc] init];
        return self;
    }
}

- (void)askAuthCode:(NSString*)phone{
    [self.loginHelper TLSSmsAskCode:[NSString stringWithFormat:@"86-%@",phone] andTLSSmsLoginListener:self.smsLoginListenerImpl];
}

- (void)verifyAuthCode:(NSString*)code andPhone:(NSString*)phone{
    [self.loginHelper TLSSmsVerifyCode:[NSString stringWithFormat:@"86-%@",phone] andCode:code andTLSSmsLoginListener:self.smsLoginListenerImpl];
}
- (void)loginCommit:(NSString*)phone{
    [self.loginHelper TLSSmsLogin:[NSString stringWithFormat:@"86-%@",phone] andTLSSmsLoginListener:self.smsLoginListenerImpl];
}
@end
