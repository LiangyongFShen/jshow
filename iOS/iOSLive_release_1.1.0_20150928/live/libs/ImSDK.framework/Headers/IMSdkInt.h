//
//  IMSdkInt.h
//  ImSDK
//
//  Created by bodeng on 10/12/14.
//  Copyright (c) 2014 tencent. All rights reserved.
//

#ifndef ImSDK_IMSdkInt_h
#define ImSDK_IMSdkInt_h

#import <Foundation/Foundation.h>
#import "IMSdkComm.h"


@class TIMAVTestSpeedResp_PKG;

/**
 *  音视频接口
 */
@interface IMSdkInt : NSObject


/**
 *  设置环境（在Init之前调用）
 *
 *  @param env  0 正式环境（默认）
 *              1 测试环境
 *              2 beta 环境
 */
-(void)setEnv:(int)env;

/**
 *  获取 IMSdkInt 全局对象
 *
 *  @return IMSdkInt 对象
 */
+(IMSdkInt*)sharedInstance;

/**
 *  初始化全局事件
 *  @deprecated 使用TencentIM中的 initSdk 替代.
 *
 *  @param appid＝537039971
 *  @param cb    网络回调
 *
 *  @return 0 成功
 */
// -(id)initWithHandler:(int)appid notifyCB:(id<OMSDKNotifyProtocol>)cb;

/**
 *  使用登陆信息初始化，内部调用，外部尽量不要调用
 *
 *  @param sdkapi 初始化后的sdkapi
 *  @param appid  sdkappid
 *  @param token  token
 *
 *  @return 0 成功
 */
-(id)initWithLoginInfo:(unsigned)appid sdkapptoken:(NSString*)token;

/**
 *  登陆
 *  @deprecated 使用TencentIM中的 login 替代.
 *
 *  @param req  OMLoginReq结构，登陆数据
 *  @param succ 成功回调
 *  @param err  失败回调
 *
 *  @return 0 成功
 */
// -(int)login:(OMLoginReq*)req okBlock:(OMLoginSucc)succ errBlock:(OMLoginErr)err;

/**
 *  获取当前登陆用户 TinyID
 *
 *  @return tinyid
 */
-(unsigned long long) getTinyId;


/**
 *  UserId 转 TinyId
 *
 *  @param userIdList userId列表，IMUserId 结构体
 *  @param succ       成功回调
 *  @param err        失败回调
 *
 *  @return 0 成功
 */
-(int)userIdToTinyId:(NSArray*)userIdList okBlock:(OMUserIdSucc)succ errBlock:(OMErr)err;

/**
 *  TinyId 转 UserId
 *
 *  @param tinyIdList tinyId列表，unsigned long long类型
 *  @param succ       成功回调
 *  @param err        失败回调
 *
 *  @return 0 成功
 */
-(int)tinyIdToUserId:(NSArray*)tinyIdList okBlock:(OMUserIdSucc)succ errBlock:(OMErr)err;


/**
 *  多人音视频请求
 *
 *  @param reqbody 请求二进制数据
 *  @param succ    成功回调
 *  @param err     失败回调
 *
 *  @return 0 成功
 */
-(int)requestMultiVideoApp:(NSData*)reqbody okBlock:(OMCommandSucc)succ errBlock:(OMErr)err;
-(int)requestMultiVideoInfo:(NSData*)reqbody okBlock:(OMCommandSucc)succ errBlock:(OMErr)err;

/**
 *  音频测速请求
 *
 *  @param bussType 业务类型
 *  @param authType 鉴权类型
 *  @param succ    成功回调
 *  @param err     失败回调
 *
 *  @return 0 成功
 */
- (int)requestMeasureSpeedWith:(short)bussType authType:(short)authType succ:(OMCommandSucc)succ fail:(OMErr)fail;

/**
 *  音频测速结果上报
 *
 *  @param resp requestMeasureSpeedWith:authType:succ:fail 成功时返回的响应中序列化出来的对像
 *  @param bussType 鉴权类型(同requestMeasureSpeedWith:authType:succ:fail 中的 bussType)
 *  @param authType 鉴权类型(同requestMeasureSpeedWith:authType:succ:fail 中的 authtype)
 *  @param succ    成功回调
 *  @param err     失败回调
 *
 *  @return 0 成功
 */
- (int)reportMeasureSpeedResult:(TIMAVTestSpeedResp_PKG *)resp  bussType:(short)bussType authType:(short)authType  succ:(OMCommandSucc)succ fail:(OMErr)fail;



/**
 *  多人音视频发送请求
 *
 *  @param serviceCmd 命令字
 *  @param reqbody    发送包体
 *  @param succ       成功回调
 *  @param err        失败回调
 *
 *  @return 0 成功
 */
- (int)requestOpenImRelay:(NSString*)serviceCmd req:(NSData*)reqbody okBlock:(OMCommandSucc)succ errBlock:(OMErr)err;

/**
 *  设置超时时间
 *
 *  @param timeout 超时时间
 */
-(void)setReqTimeout:(int)timeout;


/**
 *  双人音视频请求
 *
 *  @param tinyid  接收方 tinyid
 *  @param reqbody 请求包体
 *  @param succ    成功回调
 *  @param err     失败回调
 *
 *  @return 0 成功
 */
-(int)requestSharpSvr:(unsigned long long)tinyid req:(NSData*)reqbody okBlock:(OMCommandSucc)succ errBlock:(OMErr)err;

-(int)responseSharpSvr:(unsigned long long)tinyid req:(NSData*)reqbody okBlock:(OMCommandSucc)succ errBlock:(OMErr)err;


/**
 *  设置双人音视频监听回调
 *
 *  @param succ 成功回调，有在线消息时调用
 *  @param err  失败回调，在线消息解析失败或者包体错误码不为0时调用
 *
 *  @return 0 成功
 */
-(int)setSharpSvrPushListener:(OMCommandSucc)succ errBlock:(OMErr)err;
-(int)setSharpSvrRspListener:(OMCommandSucc)succ errBlock:(OMErr)err;


/**
 *  发送请求
 *
 *  @param cmd  命令字
 *  @param body 包体
 *  @param succ 成功回调，返回响应数据
 *  @param fail 失败回调，返回错误码
 *
 *  @return 0 发包成功
 */
-(int) request:(NSString*)cmd body:(NSData*)body succ:(OMRequestSucc)succ fail:(OMRequsetFail)fail;

/**
 *  发送开始推流请求
 *
 *  @param relationId  群组id
 *  @param roomId 房间id
 *  @param codeType  编码格式
 *  @param signature  签名，最长255字节
 *  @param succ 成功回调，返回url
 *  @param fail 失败回调，返回错误码
 *
 *  @return 0 发包成功
 */
-(int)requestMultiVideoStreamerStart:(UInt32)relationId roomId:(UInt32)roomId codeType:(AVEncodeType)codeType signature:(NSData *)signature okBlock:(OMMultiVideoStreamerSucc)succ errBlock:(OMMultiFail)fail;

/**
 *  发送停止推流请求
 *
 *  @param relationId  群组id
 *  @param roomId 房间id
 *  @param codeType  编码格式
 *  @param signature  签名，最长255字节
 *  @param succ 成功回调
 *  @param fail 失败回调，返回错误码
 *
 *  @return 0 发包成功
 */
-(int)requestMultiVideoStreamerStop:(UInt32)relationId roomId:(UInt32)roomId codeType:(AVEncodeType)codeType signature:(NSData *)signature okBlock:(OMMultiSucc)succ errBlock:(OMMultiFail)fail;

/**
 *  发送开始录制请求
 *
 *  @param relationId  群组id
 *  @param roomId 房间id
 *  @param signature  签名，最长255字节
 *  @param recordInfo 录制请求参数
 *  @param succ 成功回调
 *  @param fail 失败回调，返回错误码
 *
 *  @return 0 发包成功
 */
-(int)requestMultiVideoRecorderStart:(UInt32)relationId roomId:(UInt32)roomId signature:(NSData *)signature recordInfo:(AVRecordInfo *)recordInfo okBlock:(OMMultiSucc)succ errBlock:(OMMultiFail)fail;

/**
 *  发送停止录制请求
 *
 *  @param relationId  群组id
 *  @param roomId 房间id
 *  @param signature  签名，最长255字节
 *  @param succ 成功回调，返回文件ID
 *  @param fail 失败回调，返回错误码
 *
 *  @return 0 发包成功
 */
-(int)requestMultiVideoRecorderStop:(UInt32)relationId roomId:(UInt32)roomId signature:(NSData *)signature okBlock:(OMMultiVideoRecorderStopSucc)succ errBlock:(OMMultiFail)fail;

/**
 *  发送多人音视频邀请
 *
 *  @param bussType 业务类型
 *  @param authType 鉴权类型
 *  @param authid  鉴权ID
 *  @param requestType:
 *  1-----发起发发起音视频邀请
    2-----发起方取消音视频邀请
    3-----接收方接受音视频邀请
    4-----接收方拒绝音视频邀请
 *  @param receiversArray  向这些人发送邀请, NSString 数组
 *  @param byteBuf : 业务自定义buf
 *  @param succ 成功回调
 *  @param fail 失败回调，返回错误码
 *
 *  @return 0 发包成功
 */
- (int)requestVideoInvitation:(int)bussType authType:(int)authType authid:(unsigned int)authid requestType:(int)requestType receivers:(NSArray *)receiversArray bytesBuffer:(NSData *)byteBuf  okBlock:(OMCommandSucc)succ errBlock:(OMErr)fail;





/**
 *  发送质量上报请求
 *
 *  @param data  上报的数据
 *  @param type  上报数据类型
 *  @param succ  成功回调
 *  @param fail  失败回调，返回错误码
 *
 *  @return 0 发包成功
 */
-(int)requestQualityReport:(NSData *)data type:(unsigned int)type succ:(OMMultiSucc)succ fail:(OMMultiFail)fail;


@end

#endif
