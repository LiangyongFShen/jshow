//
//  TLSLoginHelper.h
//  WTLoginSDK64ForIOS
//
//  Created by givonchen on 15-5-20.
//
//

#import <Foundation/Foundation.h>
#import "TLSErrInfo.h"
#import "TLSUserInfo.h"
#import "TLSPwdLoginListener.h"
#import "TLSSmsLoginListener.h"
#import "TLSRefreshTicketListener.h"

/// 登录类
@interface TLSLoginHelper : NSObject
{
#if __has_feature(objc_arc_weak)
    id __weak               defaultDeleaget;
#elif __has_feature(objc_arc)
    id __unsafe_unretained  defaultDeleaget;
#else
    id                      defaultDeleaget;
#endif
    
    uint32_t dwFailedCount;
}

@property (readonly) uint32_t dwFailedCount;

/**
 *  @brief 获取TLSLoginHelper 实例
 *
 *  @return 返回TLSLoginHelper 实例
 */
+(TLSLoginHelper *) getInstance;

/**
 *  @brief 初始化TLSLoginHelper 实例
 *
 *  @param sdkAppid - 用于TLS SDK的appid
 *  @param accountType - 账号类型
 *  @param appVer - app 版本号，格式为 x.x.x.x， 例如，客户端版本为1.1，传入参数为 @"1.1.0.0"
 *
 *  @return 返回TLSLoginHelper 实例
 */
-(TLSLoginHelper *) init:(int)sdkAppid
          andAccountType:(int)accountType
               andAppVer:(NSString *)appVer;

/**
 *  设置是否访问wtlogin的测试ip
 *
 *  @param host - 测试ip
 *  @param wPort - 测试端口
 */
-(void) setTestHost:(NSString *)host andPort:(uint16_t)wPort;

/**
 *  设置请求超时时间，默认为10000毫秒。
 *  sdk与后台交互时，如果超时，会重试5次，所以不应设置太大的值
 *
 *  @param timeout - 超时时间（单位毫秒）
 */
-(void) setTimeOut:(int)timeout;

/**
 * 设置语言类型（支持国际化）
 * 目前有以下类型供选择：
 * 2052：简体中文;1028：繁体中文;1033：英文; 1041: 日语; 1036: 法语
 *
 *  @param localid - 语言类型
 */
-(void) setLocalId:(int)localid;

/**
 *  打印调试日志
 *
 *  @param show - 是否输出日志到logcat
 */
-(void) setLogcat:(BOOL)show;

/**
 * 获取TLS SDK的版本信息
 *
 *  @return SDK的版本信息
 */
-(NSString *) getSDKVersion;

/**
 * 获取guid
 *
 *  @return guid
 */
-(NSData *) getGUID;

/**
 *  获取登录过当前app的帐号列表
 *
 *  @return 账号列表信息 TLSUserInfo数组
 */
-(NSArray *) getAllUserInfo;

/**
 *  获取最后一次登录记录
 *
 *  @return 账号信息
 */
-(TLSUserInfo *) getLastUserInfo;

/**
 *  清除用户登录数据
 *
 *  @param identifier - 用户手机号码
 *  @param deleteAccount - 是否将identifier从历史登录账号列表中删除 NO表示不删除 YES表示删除
 *
 *  @return ture
 */
-(BOOL) clearUserInfo:(NSString *)identifier withOption:(BOOL)deleteAccount;

/**
 *  判断是否需要用户登录（输入密码或者短信验证）
 *
 *  @param identifier - 用户帐号
 *
 *  @return true：需要用户登录；false：本地已有登录态，无需登录，可直接换票
 */
-(BOOL) needLogin:(NSString *)identifier;

/**
 *  获取本地保存的SSO票据
 *
 *  @param identifier - 用户手机号码
 *
 *  @return {"A2": xxx, "A2Key": xxx, "D2": xxx, "D2Key": xxx}
 */
-(NSDictionary*) getSSOTicket:(NSString *)identifier;

/**
 *  获取本地保存TLS票据
 *
 *  @param identifier - 用户手机号码
 *
 *  @return json webtoken
 */
-(NSString*) getTLSUserSig:(NSString *)identifier;

/**
 *  密码登录，获取票据
 *
 *  @param identifier - 用户账号
 *  @param password - 用户密码
 *  @param listener - TLSPwdLoginListener 回调对象
 *
 *  @return 0表示调用成功；其它表示调用失败
 */
-(int) TLSPwdLogin:(NSString *)identifier andPassword:(NSString *)password andTLSPwdLoginListener:(id)listener;

/**
 *  刷新图片验证码
 *
 *  @param listener - TLSPwdLoginListener 回调对象
 *
 *  @return 0表示调用成功；其它表示调用失败
 */
-(int) TLSPwdLoginReaskImgCode:(id)listener;

/**
 *  验证图片验证码，如果验证成功则登录成功，否则要重新验证
 *
 *  @param imgCode - 用户账号
 *  @param listener - TLSPwdLoginListener 回调对象
 *
 *  @return 0表示调用成功；其它表示调用失败
 */
-(int) TLSPwdLoginVerifyImgCode:(NSString *)imgCode andTLSPwdLoginListener:(id)listener;

/**
 *  换票，刷新票据
 *
 *  @param identifier - 用户账号
 *  @param listener - TLSRefreshTicketListener 回调对象
 *
 *  @return 0表示调用成功；其它表示调用失败
 */
-(int) TLSRefreshTicket:(NSString *)identifier andTLSRefreshTicketListener:(id) listener;


/**************************************以下是短信登录相关的接口************************************/

/**
 *  短信登录，手机号验证
 *
 *  @param mobile - 用户手机号码
 *  @param listener - TLSSmsLoginListener 回调对象
 *
 *  @return 0表示调用成功；其它表示调用失败
 */
-(int) TLSSmsAskCode:(NSString *)mobile andTLSSmsLoginListener:(id)listener;

/**
 *  短信登录，刷新短信验证码
 *
 *  @param mobile - 用户手机号码
 *  @param listener - TLSSmsLoginListener 回调对象
 *
 *  @return 0表示调用成功；其它表示调用失败
 */
-(int) TLSSmsReaskCode:(NSString *)mobile andTLSSmsLoginListener:(id)listener;

/**
 *  短信登录，验证短信验证码
 *
 *  @param mobile - 用户手机号码
 *  @param  code - 验证码
 *  @param listener - TLSSmsLoginListener 回调对象
 *
 *  @return 0表示调用成功；其它表示调用失败
 */
-(int) TLSSmsVerifyCode:(NSString *)mobile andCode:(NSString *)code andTLSSmsLoginListener:(id)listener;

/**
 *  短信登录，获取票据
 *
 *  @param mobile - 用户手机号码
 *  @param listener - TLSSmsLoginListener 回调对象
 *
 *  @return 0表示调用成功；其它表示调用失败
 */
-(int) TLSSmsLogin:(NSString *)mobile andTLSSmsLoginListener:(id)listener;

@end
