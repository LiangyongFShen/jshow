//
//  AudioHelper.h
//  AVFoudationEX
//
//  Created by crosbyli on 12-10-26.
//  Copyright (c) 2012年 tencent. All rights reserved.
//
// 本类用于检测耳机插拔，及检测录制mic是否正常使用
#import <Foundation/Foundation.h>


@interface AudioHelper : NSObject {
    BOOL recording;
}
//初始化AudioSession 增加监听耳机事件
- (void)initSession;
//反初始化 删除监听耳机事件
- (void)unInitSession;
//是否插入耳机
+ (BOOL)hasHeadset;
//是否有mic可以录制
- (BOOL)hasMicphone;
//reset录制资源 默认无耳机是外放
- (void)cleanUpForEndRecording;
//录制前清理
- (BOOL)checkAndPrepareCategoryForRecording;
//设置耳机音
- (void)setHeadSet;
//设置为外放
- (void)setSpeaker;
@end