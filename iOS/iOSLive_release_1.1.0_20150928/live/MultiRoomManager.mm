//
//  MultiRoomManager.m
//  live
//
//  Created by hysd on 15/8/6.
//  Copyright (c) 2015年 kenneth. All rights reserved.
//

#import "MultiRoomManager.h"

enum CAMERA_POSITION {
    CAMERA_FRONT = 0,//前
    CAMERA_BACK      //后
};

@interface MultiRoomManager(){
    CAMERA_POSITION cameraPosition;
}
@end;
@implementation MultiRoomManager
- (id)avInitWithController:(id)controller;
{
    if(![super init]){
        return nil;
    }
    cameraPosition = CAMERA_FRONT;
    
    self.roomDelegate = new AVMultiRoomDelegate(controller);
    tencent::av::AVContext::Config config;
    config.sdk_app_id=[UserInfo sharedInstance].sdkAppId.UTF8String;
    config.user_sig=[UserInfo sharedInstance].userSig.UTF8String;
    config.app_id_at3rd=[UserInfo sharedInstance].sdkAppId.UTF8String;
    config.identifier=[UserInfo sharedInstance].userPhone.UTF8String;
    config.account_type=[UserInfo sharedInstance].accountType.UTF8String;
    self.avContext = tencent::av::AVContext::CreateContext(&config);
    return self;
}

- (int)avStartContext{
    return self.avContext->StartContext(AVMultiRoomDelegate::OnContextStartComplete,self.roomDelegate);
}
- (int)avCreateRoom:(int)roomId{
    tencent::av::AVRoom::Info roomConfig;
    roomConfig.mode = tencent::av::AVRoom::MODE_VIDEO;
    roomConfig.room_type = tencent::av::AVRoom::ROOM_TYPE_MULTI;
    roomConfig.relation_type = tencent::av::RELATION_TYPE_OPENSDK;
    roomConfig.room_id = roomId;
    roomConfig.relation_id = roomId;
    return self.avContext->EnterRoom(self.roomDelegate, &roomConfig);
}
- (void)avStopContext{
    self.avContext->StopContext(AVMultiRoomDelegate::OnContextCloseComplete,self.roomDelegate);
}
- (int)avExitRoom{
    return self.avContext->ExitRoom();
}

- (void)avRequestViewPhone:(NSString*)phone succ:(avSucc)succ fail:(avFail)fail{
    tencent::av::AVDeviceMgr* device_mgr = _avContext->GetVideoDeviceMgr();
    tencent::av::AVRemoteVideoDevice* video_device = (tencent::av::AVRemoteVideoDevice*)device_mgr->GetDeviceById(DEVICE_REMOTE_VIDEO);
    if (video_device) {
        video_device->SetPreviewCallback(AVMultiRoomDelegate::VideoframeDataCallback,self.roomDelegate);
    }
    
    
    tencent::av::AVEndpoint::View view;
    view.video_src_type = tencent::av::VIDEO_SRC_TYPE_CAMERA;
    tencent::av::AVRoomMulti* multiRoom=dynamic_cast<tencent::av::AVRoomMulti*>(self.avContext->GetRoom());
    if (multiRoom) {
        tencent::av::AVEndpoint* endpoint=multiRoom->GetEndpointById([NSString stringWithFormat:@"86-%@",phone].UTF8String);
        if(!endpoint || !endpoint->HasVideo()){
            if(!endpoint){
                fail(@"主播不在");
            }
            else{
                fail(@"没有视频上行");
            }
        }
        else{
            if(tencent::av::AV_OK == endpoint->RequestView(view, AVMultiRoomDelegate::RequestViewCompleteCallback,self.roomDelegate)){
                succ(@"调用请求画面成功");
            }
            else{
                fail(@"调用请求画面失败");
            }
        }
    }
}

- (void)avToggleCamera{
    if(CAMERA_FRONT == cameraPosition){
        cameraPosition = CAMERA_BACK;
    }
    else{
        cameraPosition = CAMERA_FRONT;
    }
    self.avContext->GetVideoCtrl()->SwitchCamera(cameraPosition, AVMultiRoomDelegate::OnSwitchCameraComplete, self.roomDelegate);
}

- (void)avEnableCamera:(BOOL)enable succ:(avSucc)succ fail:(avFail)fail{
    tencent::av::AVVideoCtrl* videoCtrl = self.avContext->GetVideoCtrl();
    if(videoCtrl){
        //摄像头预览层
        tencent::av::AVDeviceMgr* deviceMgr = self.avContext->GetVideoDeviceMgr();
        tencent::av::AVDevice** deviceArray = NULL;
        deviceMgr->GetDeviceByType(DEVICE_CAMERA,&deviceArray);
        tencent::av::AVCameraDevice* dev = (tencent::av::AVCameraDevice*)deviceArray[0];
        if(self.previewLayer == nil){
            self.previewLayer = (__bridge id)dev->GetPreviewLayer();
            [self.previewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
        }
        //打开摄像头
        if(videoCtrl->EnableCamera(enable,AVMultiRoomDelegate::OnEnableCameraComplete,self.roomDelegate) == tencent::av::AV_OK){
            succ(@"调用启用摄像头成功");
        }
        else{
            fail(@"调用启用摄像头失败");
        }
    }
}

//1.2版本已经弃用
- (void)pauseVideo{
    tencent::av::AVVideoCtrl* videoCtrl = self.avContext->GetVideoCtrl();
    if(videoCtrl){
        //videoCtrl->PauseVideo();
    }
}
//1.2版本已经弃用
- (void)resumeVideo{
    tencent::av::AVVideoCtrl* videoCtrl = self.avContext->GetVideoCtrl();
    if(videoCtrl){
        //videoCtrl->ResumeVideo();
    }
}

- (NSString*)getVideoParam{
    tencent::av::AVVideoCtrl* videoCtrl = self.avContext->GetVideoCtrl();
    if(videoCtrl){
        return [NSString stringWithUTF8String:videoCtrl->GetQualityTips().c_str()];
    }
    return @"";
}

- (NSString*)getAudioParam{
    tencent::av::AVAudioCtrl* audioCtrl = self.avContext->GetAudioCtrl();
    if(audioCtrl){
        return [NSString stringWithUTF8String:audioCtrl->GetQualityTips().c_str()];
    }
    return @"";
}

- (NSString*)getCommonParam{
    tencent::av::AVRoom* room  = self.avContext->GetRoom();
    if(room){
        return [NSString stringWithUTF8String:room->GetQualityTips().c_str()];
    }
    return @"";
}
@end
