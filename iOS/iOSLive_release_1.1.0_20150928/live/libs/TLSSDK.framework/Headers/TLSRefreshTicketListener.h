//
//  TLSRefreshTicketListener.h
//  WTLoginSDK64ForIOS
//
//  Created by givonchen on 15-5-20.
//
//

#import <Foundation/Foundation.h>
#import "TLSErrInfo.h"

/// 换票回调
@protocol TLSRefreshTicketListener <NSObject>

/**
 *  刷新票据成功
 *
 *  @param userInfo 用户信息
 */
-(void)	OnRefreshTicketSuccess:(TLSUserInfo *)userInfo;

/**
 *  刷新票据失败
 *
 *  @param errInfo 错误信息
 */
-(void)	OnRefreshTicketFail:(TLSErrInfo *)errInfo;

/**
 *  刷新票据超时
 *
 *  @param errInfo 错误信息
 */
-(void)	OnRefreshTicketTimeout:(TLSErrInfo *)errInfo;

@end
