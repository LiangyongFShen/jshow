//
//  AudioRecordAndPlayer.h
//  AVFoudationEX
//
//  Created by crosbyli on 12-10-26.
//  Copyright (c) 2012年 tencent. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <CoreAudio/CoreAudioTypes.h>
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioServices.h>
#import <unistd.h>

#define kInputBus  1    //input element
#define kOutputBus 0    //output element

typedef struct  {
	
	AudioComponentInstance audioUnit;
	AudioComponentDescription desc;
	
	AudioStreamBasicDescription inDf;  //for input element
	AudioStreamBasicDescription outDf;  //for output element
	
	AudioComponent aComponent;
	
	AURenderCallbackStruct callbackStruct;
	
	bool                         mIsRunning;
//	id                           mRecCallback;    //record call back.
//	id                           mPlayCallback;   //play call back.
	
}AUnitState;

typedef enum   //audio unit work mode
{
	kInvalidMode = 0x00,   //invalid mode.
	kRecordMode  = 0x01,   //only used for recording.
	kPlayMode    = 0x02,   //only used  for playing.
	kRecordPlayMode = 0x03  //used for recording and playing simutaneously.
	
}AUnitWorkModeEnum;

@protocol AudioRecordAndPlayerDelegate <NSObject>
@required

- (int) DevPutData:(unsigned char*)pBuff andDataLen:(int)nDataLen;

- (int) DevGetData:(unsigned char*)pBuff andDataLen:(int)nDataLen;

@end


@interface AudioRecordAndPlayer : NSObject
{
@public
	AUnitState aUnitData;	  //gloabal audio unit manager.
    
    BOOL isStoped;

    id<AudioRecordAndPlayerDelegate> audioRecordAndPlayerDelegate;
    
    int mInSamplerate;        //sampling rate.
	int mOutSamplerate;
	
	int mInChannels;          //stereo or mono
	int mOutChannels;
	
	int mInFrameDuration;       //frame length in milliseconds.
	int mOutFrameDuration;      //frame length in milliseconds.
	
	int mInFrameSize;           //frame length in bytes for each channel.
    int mOutFrameSize;
	
	
	AUnitWorkModeEnum mWorkMode;
	
	unsigned char* pRecBuff;
	int mLeftLenth;
	
	unsigned short* pPlayBuff;
	int mPBLeft;
	
	bool bMuteMic;            //mute micphone.
}
@property (nonatomic, readwrite) AUnitState aUnitData;
@property (nonatomic, assign) BOOL isStop;
//@property float volumnRatio;

- (id) init;
- (void)setWorkMode:(int)mode;
- (void)setDelegate:(id)delegate;
- (int) setRecDataFormat: (int)samplerate nChannels:(int)channels nLength:(int)length;
- (int) setPlayDataFormat:(int)samplerate nChannels:(int)channels nLength:(int)length;

- (int) Start;
- (int) Stop;
- (void)setMicrophoneMute:(bool)mute;  //microphone mute or not.
- (void)initAudio;
- (void)releaseAudio;




@end
