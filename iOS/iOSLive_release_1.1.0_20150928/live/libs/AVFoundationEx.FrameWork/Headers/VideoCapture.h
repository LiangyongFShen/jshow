//
//  VideoCapture.h
//  AVFoundationEx
//
//  Created by crosbyli on 12-10-28.
//  Copyright (c) 2012年 tencent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@protocol VideoCaptureDelegate <NSObject>
@required
//pCambuffer 由使用者释放 切记否则会有严重内存泄漏
- (void)transmitVideoData:(unsigned char* )pCamBuffer BufferSize:(size_t)nBufferSize Width:(size_t)width HeightY:(size_t)heightOfYPlane;
- (void)drawVideoData:(unsigned char *)pCamBuffer BufferSize:(size_t)nBufferSize Width:(size_t)width HeightY:(size_t)heightOfYPlane;
@end


@interface VideoCapture : NSObject<AVCaptureVideoDataOutputSampleBufferDelegate>
{
@private

	AVCaptureVideoDataOutput *_videoOutput;
	NSInteger _frameRate;
    dispatch_queue_t _cameraProcessingQueue;
    AVCaptureSession *_captureSession;
    AVCaptureDevice *_inputCamera;
    AVCaptureDeviceInput *_videoInput;
    
    id<VideoCaptureDelegate> videoDelegate;
}
@property (nonatomic, retain) AVCaptureSession *captureSession;
@property (nonatomic, retain) AVCaptureDeviceInput * videoInput;
@property (nonatomic, retain) AVCaptureVideoDataOutput * videoOutput;

- (id) initPreset:(NSString *)preset Format:(int)format Fps:(int)fps Discard:(BOOL)bdiscard;

- (void)setDelegate:(id)delegate;

- (void)startCapture;
- (void)stopCapture;


/** 根据前后镜头参数获取前后镜头设备 */
- (id)cameraWithPosition:(AVCaptureDevicePosition)position;
/** 抓取摄像头数据delegate调用，用于绘制本地画面和传送视频数据 */
- (void)captureOutput:(id)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(id)connection;
- (void)releaseVideo;
- (void)swapFrontAndBackCameras;
- (BOOL)isFrontCamera;
- (void)setCamera:(BOOL)isFront;
@end
