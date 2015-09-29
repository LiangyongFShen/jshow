//
//  AVFoundationEX.h
//  AVFoundationEX
//
//  Created by crosbyli on 12-10-26.
//  Copyright (c) 2012年 tencent. All rights reserved.
//
//  创建此库首先是为了整顿iphone qq目前混乱的音频 视频接口调用，其次是对1年多以来对本人ios
//  音视频技术的一些总结沉淀同时也希望能够帮助到有需要学习这方面知识的童鞋
//  如有任何疑问可与本人联系 tel:13760453753 qq:42267325
//  如腾讯的童鞋有需要使用可以rtx 无线 手q产品部 架构组 crosbyli


//1.0版本  2012－10－31
//功能： 1 视频采集 （针对流式）  videoCapture
//      2 音频采集 回放（针对流式）   audioRecordAndPlayer
//      3 耳机事件监听 设置内外放接口  audioHelper


//下期版本1.1 功能预览
//      4 多媒体文件格式转换
//      5 视频采集 播放（针对文件）  
//      6 音频采集 播发（针对文件）  

#import <Foundation/Foundation.h>
#import "AudioRecordAndPlayer.h"
#import "VideoCapture.h"
#import "AudioHelper.h"
@interface AVFoundationEX : NSObject

@end
