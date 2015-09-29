//
//  IMSdkComm.h
//  ImSDK
//
//  Created by bodeng on 10/12/14.
//  Copyright (c) 2014 tencent. All rights reserved.
//

#ifndef ImSDK_IMSdkComm_h
#define ImSDK_IMSdkComm_h

@interface OMErrResp : NSObject
{
    NSString*   cmd;                // 返回的命令字
    int         seq;                // 请求包的seq
    NSString*   uin;                // uin
    int         errCode;          // 错误码
    NSString*   errTips;            // error tips
}

@property(nonatomic,retain) NSString* cmd;
@property(nonatomic,retain) NSString* uin;
@property(nonatomic,assign) int seq;
@property(nonatomic,assign) int errCode;
@property(nonatomic,retain) NSString* errTips;

@end


/// 业务相关回调

/**
 *  userid和tinyid 转换回包
 *  userList 存储IMUserId结构
 */
@interface OMUserIdResp : NSObject{
    NSArray*   userList;         // 用户的登录的open id
}


@property(nonatomic,retain) NSArray* userList;

@end

/**
 *  userid转换tinyid回调
 *
 *  @param OMUserIdResp 回包结构
 *
 *  @return 0 处理成功
 */
typedef int (^OMUserIdSucc)(OMUserIdResp *resp);

//请求回调
typedef int (^OMErr)(OMErrResp *resp);


/**
 *  音视频回调
 */
@interface OMCommandResp : NSObject{
    NSData*   rspbody;
}


@property(nonatomic,retain) NSData* rspbody;

@end

// relay 回调
typedef int (^OMCommandSucc)(OMCommandResp *resp);

// request 回调
typedef void (^OMRequestSucc)(NSData * data);
typedef void (^OMRequsetFail)(int code, NSString* msg);

/**
 *  UserId 结构，表示一个用户的账号信息
 */
@interface IMUserId : NSObject{
    NSString*       uidtype;            // uid 类型
    unsigned int    userappid;
    NSString*       userid;             // 用户id
    unsigned long long   tinyid;
    unsigned long long   uin;
}

@property(nonatomic,retain) NSString* uidtype;
@property(nonatomic,assign) unsigned int userappid;
@property(nonatomic,retain) NSString* userid;
@property(nonatomic,assign) unsigned long long tinyid;
@property(nonatomic,assign) unsigned long long uin;

@end

/**
 *  一般多人音视频操作成功回调
 */
typedef void (^OMMultiSucc)();

/**
 *  一般多人音视频操作失败回调
 *
 *  @param code     错误码
 *  @param NSString 错误描述
 */
typedef void (^OMMultiFail)(int code, NSString *);

/**
 *  推流请求成功回调
 *
 *  @param NSArray AVLiveUrl列表
 */
typedef void (^OMMultiVideoStreamerSucc)(NSArray*);

typedef NS_ENUM(NSInteger, AVEncodeType)
{
    AV_ENCODE_HLS = 0x01,
    AV_ENCODE_FLV = 0x02,
    AV_ENCODE_HLS_FLV = 0x03,
    AV_ENCODE_RAW = 0x04,
    AV_ENCODE_RTMP = 0x05
};

/**
 *  AVLiveUrl 数组，表示一个编码类型的url信息
 */
@interface AVLiveUrl : NSObject {
    AVEncodeType _type;
    NSString *_playUrl;
}
@property(nonatomic,assign) AVEncodeType type;
@property(nonatomic,strong) NSString *playUrl;
@end

/**
 *  录制请求参数结构
 *  fileName  录制生成的文件名,如果包含空格则需要
 *            使用rawurlencode,长度在40个字符以内
 *  tags  视频标签的NSString*列表
 *  classId  视频分类ID
 *  isTransCode  是否转码
 *  isScreenShot  是否截图
 *  isWaterMark  是否打水印
 */
@interface AVRecordInfo : NSObject {
    NSString *_fileName;
    NSArray *_tags;
    UInt32 _classId;
    BOOL _isTransCode;
    BOOL _isScreenShot;
    BOOL _isWaterMark;
}
@property(nonatomic,strong) NSString *fileName;
@property(nonatomic,strong) NSArray *tags;
@property(nonatomic,assign) UInt32 classId;
@property(nonatomic,assign) BOOL isTransCode;
@property(nonatomic,assign) BOOL isScreenShot;
@property(nonatomic,assign) BOOL isWaterMark;
@end

/**
 *  停止录制请求成功回调
 *
 *  @param NSArray 文件ID NSString*列表
 */
typedef void (^OMMultiVideoRecorderStopSucc)(NSArray*);

#endif
