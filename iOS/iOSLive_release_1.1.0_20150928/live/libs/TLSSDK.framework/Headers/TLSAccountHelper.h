//
//  TLSAccountHelper.h
//  WTLoginSDK64ForIOS
//
//  Created by givonchen on 15-5-18.
//
//

#import <Foundation/Foundation.h>
#import "TLSErrInfo.h"
#import "TLSPwdRegListener.h"
#import "TLSPwdResetListener.h"
#import "TLSSmsRegListener.h"

/// 国家类别
enum _TLS_COUNTRY_DEFINE
{
    TLS_COUNTRY_CHINA = 86,           ///中国
    TLS_COUNTRY_TAIWAN = 186,         ///台湾
    TLS_COUNTRY_HONGKANG = 152,       ///香港
    TLS_COUNTRY_USA = 174,            ///美国
};

/// 语言类别
enum _TLS_LANG_DEFINE
{
    TLS_LANG_ENGLISH = 1033,          ///英语
    TLS_LANG_SIMPLIFIED = 2052,       ///简体中文，目前只支持简体中文
    TLS_LANG_TRADITIONAL = 1028,      ///繁体中文
    TLS_LANG_JAPANESE = 1041,         ///日语
    TLS_LANG_FRANCE = 1036,           ///法语
};

/// 帐号类 (包括 手机帐号+密码注册、手机帐号重置密码、手机帐号无密码注册 等接口)
@interface TLSAccountHelper : NSObject 

/**
 *  @brief 获取TLSAccountHelper 实例
 *
 *  @return 返回TLSAccountHelper 实例
 */
+(TLSAccountHelper *) getInstance;

/**
 *  @brief 初始化TLSAccountHelper 实例
 *
 *  @param sdkAppid - 用于TLS SDK的appid
 *  @param accountType - 账号类型
 *  @param appVer - app 版本号，业务自定义
 *
 *  @return 返回TLSAccountHelper 实例
 */
-(TLSAccountHelper *) init:(int)sdkAppid
            andAccountType:(int)accountType
                 andAppVer:(NSString *)appVer;

/**
 *  @brief 设置请求超时时间，默认为10000毫秒。
 *  sdk与后台交互时，如果超时，会重试5次，所以不应设置太大的值
 *
 *  @param timeout - 超时时间（单位毫秒）
 */
-(void) setTimeOut:(int)timeout;

/**
 * @brief 设置语言类型（支持国际化）
 * 目前有以下类型供选择：
 * 2052：简体中文;1028：繁体中文;1033：英文; 1041: 日语; 1036: 法语
 *
 *  @param localid - 语言类型
 */
-(void) setLocalId:(int)localid;

/**
 * 设置国家区号（支持国际化）
 *
 *  @param country - 国家区号
 */
-(void) setCountry:(int)country;

/**
 * 获取TLS SDK的版本信息
 *
 *  @return SDK的版本信息
 */
-(NSString *) getSDKVersion;

/**
 * 提交用于验证的手机号码
 *
 *  @param mobile - 手机号码 (国家码-手机号码)
 *  @param listener - TLSPwdRegListener 回调对象
 *
 *  @return 0表示调用成功；其它表示调用失败
 */
-(int) TLSPwdRegAskCode:(NSString *)mobile andTLSPwdRegListener:(id)listener;

/**
 * 当使用下行短信验证手机号码时，用于请求重新发送下行短信
 *
 *  @param listener - TLSPwdRegListener 回调对象
 *
 *  @return 0表示调用成功；其它表示调用失败
 */
-(int) TLSPwdRegReaskCode:(id)listener;

/**
 * 用于提交收到的短信验证码
 *
 *  @param code - 短信验证码
 *  @param listener - TLSPwdRegListener 回调对象
 *
 *  @return 0表示调用成功；其它表示调用失败
 */
-(int) TLSPwdRegVerifyCode:(NSString *)code andTLSPwdRegListener:(id)listener;

/**
 * 注册成功获取账号
 *
 *  @param password - 用户密码
 *  @param listener - TLSPwdRegListener 回调对象
 *
 *  @return 0表示调用成功；其它表示调用失败
 */
-(int) TLSPwdRegCommit:(NSString *)password andTLSPwdRegListener:(id)listener;

/**
 * 提交用于验证的手机号码
 *
 *  @param mobile - 手机号码 (国家码-手机号码)
 *  @param listener - TLSPwdResetListener 回调对象
 *
 *  @return 0表示调用成功；其它表示调用失败
 */
-(int) TLSPwdResetAskCode:(NSString *)mobile andTLSPwdResetListener:(id)listener;

/**
 * 当使用下行短信验证手机号码时，用于请求重新发送下行短信
 *
 *  @param listener - TLSPwdResetListener 回调对象
 *
 *  @return 0表示调用成功；其它表示调用失败
 */
-(int) TLSPwdResetReaskCode:(id)listener;

/**
 * 用于提交收到的短信验证码
 *
 *  @param code - 短信验证码
 *  @param listener - TLSPwdResetListener 回调对象
 *
 *  @return 0表示调用成功；其它表示调用失败
 */
-(int) TLSPwdResetVerifyCode:(NSString *)code andTLSPwdResetListener:(id)listener;

/**
 * 注册成功获取账号
 *
 *  @param password - 用户密码
 *  @param listener - TLSPwdResetListener 回调对象
 *
 *  @return 0表示调用成功；其它表示调用失败
 */
-(int) TLSPwdResetCommit:(NSString *)password andTLSPwdResetListener:(id)listener;

/**
 * 提交用于验证的手机号码
 *
 *  @param mobile - 手机号码 (国家码-手机号码)
 *  @param listener - TLSSmsRegListener 回调对象
 *
 *  @return 0表示调用成功；其它表示调用失败
 */
-(int) TLSSmsRegAskCode:(NSString *)mobile andTLSSmsRegListener:(id)listener;

/**
 * 当使用下行短信验证手机号码时，用于请求重新发送下行短信
 *
 *  @param listener - TLSSmsRegListener 回调对象
 *
 *  @return 0表示调用成功；其它表示调用失败
 */
-(int) TLSSmsRegReaskCode:(id)listener;

/**
 * 用于提交收到的短信验证码
 *
 *  @param code - 短信验证码
 *  @param listener - TLSSmsRegListener 回调对象
 *
 *  @return 0表示调用成功；其它表示调用失败
 */
-(int) TLSSmsRegVerifyCode:(NSString *)code andTLSSmsRegListener:(id)listener;

/**
 * 注册成功获取账号
 *
 *  @param listener - TLSSmsRegListener 回调对象
 *
 *  @return 0表示调用成功；其它表示调用失败
 */
-(int) TLSSmsRegCommit:(id)listener;

@end
