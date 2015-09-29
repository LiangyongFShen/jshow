//
//  TLSUserInfo.h
//  WTLoginSDK64ForIOS
//
//  Created by givonchen on 15-5-20.
//
//

#import <Foundation/Foundation.h>

/// 用户信息
@interface TLSUserInfo : NSObject
{
    /// 帐号类型
    uint32_t	accoutType;
    /// 用户id
    NSString*   identifier;
}

/// 帐号类型
@property (assign)  uint32_t    accoutType;

/// 用户id
@property (copy)    NSString*   identifier;

@end
