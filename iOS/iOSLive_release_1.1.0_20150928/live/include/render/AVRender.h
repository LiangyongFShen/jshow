//
//  AVRender.h
//  AVTest
//
//  Created by TOBINCHEN on 14-9-17.
//  Copyright (c) 2014年 TOBINCHEN. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <UIKit/UIKit.h>

/**
 *  视频帧
 */
@interface AVFrameInfo : NSObject{
    NSUInteger _data_type;
    NSUInteger _width;
    NSUInteger _height;
    NSInteger  _rotate;
    NSInteger  _source_type;
    BOOL   _is_rgb;
    BOOL   _is_check_format;
    NSUInteger _room_id;
    NSString*  _identifier;
    NSData*    _data;
}
@property (assign,nonatomic) NSUInteger data_type;
@property (assign,nonatomic) NSUInteger width;
@property (assign,nonatomic) NSUInteger height;
@property (assign,nonatomic) NSInteger  rotate;
@property (assign,nonatomic) NSInteger  source_type;
@property (assign,nonatomic) BOOL   is_rgb;

@property (assign,nonatomic) BOOL   is_check_format;
@property (assign,nonatomic) NSUInteger room_id;
@property (copy,nonatomic)   NSString*  identifier;
@property (retain,nonatomic) NSData*    data;
@end


@class EAGLView_v2;
@class VideoImageView;
@class ScrollImageVideoView;

/**
 *  渲染器的基类,不能直接使用
 */
@interface AVRender : NSObject{
    UIDeviceOrientation _orientation;
}
@property (retain,readonly,nonatomic) UIView* videoView;
/**
 *  开始渲染
 *
 *  @return
 */
-(BOOL)startRender;
/**
 *  停止渲染
 *
 *  @return
 */
-(BOOL)stopRender;
/**
 *  渲染帧
 *
 *  @param aFrame AVFrameInfo
 */
-(void)displayVideoFrame:(AVFrameInfo *)aFrame;

-(void)setRendererOrientation:(UIDeviceOrientation)orientation;

@end

/**
 *  OpenGl渲染类，目前不支持缩放、移动等操作
 */
@interface OpenGLRender : AVRender{
    EAGLView_v2* _openGlVideoView;
}
@end

/**
 *  Image渲染类，支持缩放和拖动，一般用来渲染屏幕分享和PPT
 */
@interface ImageRender : AVRender{
    ScrollImageVideoView* _scrollImageVideoView;
    unsigned char * _outputDate;
}
@property (assign,nonatomic) CGFloat scale;
@property (assign,readonly,nonatomic) CGFloat maxScale;
/**
 *  设置缩放
 *
 *  @param zoomScale 缩放倍数
 *  @param animated  是否带动画
 */
-(void)setScale:(CGFloat)zoomScale animated:(BOOL)animated;
/**
 *  移动画面
 *
 *  @param vec 移动矩阵
 */
-(void)move:(CGVector)vec;
/**
 *  检查是否移到外面
 */
-(void)checkOutBound;
/**
 *  自动控制移动合缩放，开启这个参数之后不需要手动设置相关参数
 */
@property (nonatomic,assign) BOOL autoScrollAndScale;
@end
