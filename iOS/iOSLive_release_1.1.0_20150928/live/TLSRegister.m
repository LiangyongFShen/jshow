//
//  TLSRegister.h
//  live
//
//  Created by hysd on 15/8/14.
//  Copyright (c) 2015年 kenneth. All rights reserved.
//

#import "TLSRegister.h"
#import "UserInfo.h"
@implementation TLSSmsRegListenerImpl
- (void)OnSmsRegAskCodeSuccess:(int)reaskDuration andExpireDuration:(int)expireDuration{
    if(self.delegate){
        [self.delegate OnSmsRegAskCodeSuccess:reaskDuration andExpireDuration:expireDuration];
    }
}
- (void)OnSmsRegReaskCodeSuccess:(int)reaskDuration andExpireDuration:(int)expireDuration{
    if(self.delegate){
        [self.delegate OnSmsRegReaskCodeSuccess:reaskDuration andExpireDuration:expireDuration];
    }
}
- (void)OnSmsRegVerifyCodeSuccess{
    if(self.delegate){
        [self.delegate OnSmsRegVerifyCodeSuccess];
    }
}
- (void)OnSmsRegCommitSuccess:(TLSUserInfo *)userInfo{
    if(self.delegate){
        [self.delegate OnSmsRegCommitSuccess:userInfo];
    }
}
- (void)OnSmsRegFail:(TLSErrInfo *)errInfo{
    if(self.delegate){
        [self.delegate OnSmsRegFail:errInfo];
    }
}
- (void)OnSmsRegTimeout:(TLSErrInfo *)errInfo{
    if(self.delegate){
        [self.delegate OnSmsRegTimeout:errInfo];
    }
}
@end


@interface TLSRegister(){
}
@end
@implementation TLSRegister
static TLSRegister *sharedObj = nil;

+ (TLSRegister*) sharedInstance
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
        self.accountHelper = [[TLSAccountHelper getInstance] init:[[UserInfo sharedInstance].sdkAppId intValue]
                                       andAccountType:[[UserInfo sharedInstance].accountType intValue]
                                            andAppVer:version];
        self.smsRegListenerImpl = [[TLSSmsRegListenerImpl alloc] init];
        return self;
    }
}

- (void)askAuthCode:(NSString*)phone{
    [self.accountHelper TLSSmsRegAskCode:[NSString stringWithFormat:@"86-%@",phone] andTLSSmsRegListener:self.smsRegListenerImpl];
}
- (void)verifyAuthCode:(NSString*)code{
    [self.accountHelper TLSSmsRegVerifyCode:code andTLSSmsRegListener:nil];
}
- (void)registerCommit{
    [self.accountHelper TLSSmsRegCommit:nil];
}

@end
