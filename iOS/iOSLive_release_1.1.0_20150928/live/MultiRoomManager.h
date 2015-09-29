//
//  MultiRoomManager.h
//  live
//
//  Created by hysd on 15/8/6.
//  Copyright (c) 2015年 kenneth. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "UserInfo.h"
#include "av_context.h"
#include "av_room_multi.h"
#include "av_endpoint.h"

@interface NSObject (AVDelegate)
- (void)OnRoomCreateComplete:(int)result;
- (void)OnRoomLeaveComplete:(int)result;
- (void)OnRoomEndpointsEnter:(int)endpoint_count list:(tencent::av::AVEndpoint**)endpoint_list;
- (void)OnRoomEndpointsLeave:(int)endpoint_count list:(tencent::av::AVEndpoint**)endpoint_list;
- (void)OnRoomEndpointsUpdate:(int)endpoint_count list:(tencent::av::AVEndpoint**)endpoint_list;
- (void)OnContextStartComplete:(int)result;
- (void)OnContextCloseComplete;
- (void)VideoframeDataCallback:(tencent::av::VideoFrame*)frameData;
- (void)OnEnableCameraComplete:(bool)bEnable result:(int)result;
- (void)OnSwitchCameraComplete:(bool)bEnable result:(int)result;
- (void)OnRequestViewComplete:(std::string)identifier result:(int)result;
@end

//C++回调
class AVMultiRoomDelegate:public tencent::av::AVRoomMulti::Delegate{
public:
    AVMultiRoomDelegate(id controller){
        this->controller = controller;
    }
public:
    virtual void OnQueryInterfaceServerListComplete(int result, std::string message){
    }
    virtual void OnUserVideoStateChanged(int endpoint_count, tencent::av::AVEndpoint* endpoint_list[]){
    }
    virtual void OnRoomConnectTimeout(){
    }
    virtual void OnEnterRoomComplete(int result) {
        [controller OnRoomCreateComplete:result];
    }
    virtual void OnExitRoomComplete(int result) {
        [controller OnRoomLeaveComplete:result];
    }
    virtual void OnEndpointsEnterRoom (int endpoint_count, tencent::av::AVEndpoint *endpoint_list[]){
        [controller OnRoomEndpointsEnter:endpoint_count list:endpoint_list];
    }
    virtual void OnEndpointsExitRoom (int endpoint_count, tencent::av::AVEndpoint *endpoint_list[]){
        [controller OnRoomEndpointsLeave:endpoint_count list:endpoint_list];
    }
    virtual void OnEndpointsUpdateInfo (int endpoint_count, tencent::av::AVEndpoint *endpoint_list[]){
        [controller OnRoomEndpointsUpdate:endpoint_count list:endpoint_list];
    }
    static void OnContextStartComplete(int result, void* custom_data)
    {
        AVMultiRoomDelegate* delegate=(AVMultiRoomDelegate*)custom_data;
        if (delegate) {
            [delegate->controller OnContextStartComplete:result];
        }
    }
    static void OnContextCloseComplete(void* custom_data)
    {
        AVMultiRoomDelegate* delegate=(AVMultiRoomDelegate*)custom_data;
        if (delegate) {
            [delegate->controller OnContextCloseComplete];
        }
    }
    static void VideoframeDataCallback(tencent::av::VideoFrame* frameData, void* custom_data)
    {
        AVMultiRoomDelegate* delegate=(AVMultiRoomDelegate*)custom_data;
        if (delegate) {
            [delegate->controller VideoframeDataCallback:frameData];
        }
    }
    static void OnEnableCameraComplete(bool bEnable,int result,void* custom_data)
    {
        AVMultiRoomDelegate* delegate=(AVMultiRoomDelegate*)custom_data;
        if (delegate) {
            [delegate->controller OnEnableCameraComplete:bEnable result:result];
        }
    }
    static void OnSwitchCameraComplete(int cameraId,int result,void* custom_data)
    {
        AVMultiRoomDelegate* delegate=(AVMultiRoomDelegate*)custom_data;
        if (delegate) {
            [delegate->controller OnSwitchCameraComplete:cameraId result:result];
        }
    }
    static void RequestViewCompleteCallback(std::string identifier, int result, void* customData)
    {
        AVMultiRoomDelegate* delegate=(AVMultiRoomDelegate*)customData;
        if (delegate) {
            [delegate->controller OnRequestViewComplete:identifier result:result];
        }
    }
    virtual void OnPrivilegeDiffNotify(int32 privilege)
    {
        //TODO
    }
public:
    id controller;
};


/**
 *  成功回调
 */
typedef void (^avSucc)(NSString* msg);
/**
 *  失败回调
 */
typedef void (^avFail)(NSString *error);

@interface MultiRoomManager : NSObject
@property (nonatomic) tencent::av::AVContext* avContext;
@property (nonatomic) AVMultiRoomDelegate* roomDelegate;
@property (nonatomic) AVCaptureVideoPreviewLayer* previewLayer;
/**
 * 初始化
 */
- (id)avInitWithController:(id)controller;
/**
 * 开始上下文
 */
- (int)avStartContext;
/**
 * 创建房间
 * @param roomId relation_id
 */
- (int)avCreateRoom:(int)roomId;
/**
 * 关闭上下文
 */
- (void)avStopContext;
/**
 * 退出房间
 */
- (int)avExitRoom;
/**
 *  请求画面
 *  @param phone  账号（电话号码）
 *  @param succ   成功回调
 *  @param fail   失败回调
 */
- (void)avRequestViewPhone:(NSString*)phone succ:(avSucc)succ fail:(avFail)fail;
/**
 * 切换摄像头
 */
- (void)avToggleCamera;
/**
 *  启用摄像头
 *  @param enable 打开或关闭
 *  @param succ   成功回调
 *  @param fail   失败回调
 */
- (void)avEnableCamera:(BOOL)enable succ:(avSucc)succ fail:(avFail)fail;
/**
 * 暂停video
 */
- (void)pauseVideo;
/**
 * 恢复video
 */
- (void)resumeVideo;
/**
 * 获取音频参数
 */
- (NSString*)getVideoParam;
/**
 * 获取视频参数
 */
- (NSString*)getAudioParam;
/**
 * 获取通用参数
 */
- (NSString*)getCommonParam;
@end