#ifndef AV_COMMON_H_
#define AV_COMMON_H_

#include "build_config.h"
#include "basictypes.h"
#include "av_error.h"
#include "av_export.h"
#include <string>

#ifdef WIN32
#include <windows.h>
#endif

namespace tencent {
namespace av {

//////////////////////////////////////////////////////////////////////////
//
// 通用的，未分类的由此开始

/**
@brief 参数类型为void*的通用回调函数。

@details 此函数是和异步操作一起使用的回调函数，用来异步返回执行结果。

@param custom_data 值等于调用异步操作时的入参custom_data。

@todo 补充一下相关接口。
*/
typedef void (*AVClosure)(void* custom_data);


//////////////////////////////////////////////////////////////////////////
//
// AVContext相关的由此开始



//////////////////////////////////////////////////////////////////////////
//
// AVRoom相关的由此开始

/**
@brief 关系类型。

@remark 腾讯开放给第三方开发者使用的这套音视频通信SDK，与腾讯QQ使用的是同一套的协议和架构。
  以此枚举类型的定义为例，1~4的枚举值是腾讯QQ专用的，6的枚举值是第三方App专用的。
*/
enum RelationType {
  RELATION_TYPE_UNKNOWN = 0, ///< 默认值，无意义。
  RELATION_TYPE_GROUP = 1, ///< QQ群。
  RELATION_TYPE_DISCUSS = 2, ///< QQ讨论组。
  RELATION_TYPE_BUDDY = 3, ///< QQ好友。
  RELATION_TYPE_TEMP = 4, ///< QQ临时会话。
  RELATION_TYPE_OPENSDK = 6, ///< 音视频开放SDK，第三方App专用。
};

//////////////////////////////////////////////////////////////////////////
//
// 音频相关的由此开始

/// 音频源类型。
enum AudioSrcType {
  AUDIO_SRC_TYPE_NONE = 0, ///< 默认值，无意义。
  //AUDIO_SRC_TYPE_MIC = 1, ///< 麦克风。
  //AUDIO_SRC_TYPE_ACCOMPANY = 2, ///< 伴奏。
  //AUDIO_SRC_TYPE_MIX_INPUT = 3, ///< 混音输入。
  //AUDIO_SRC_TYPE_MIX_OUTPUT = 4, ///< 混音输出。
};

/**
@brief 音频帧描述。

@todo src_type的使用场景？
*/
struct AudioFrameDesc {
  AudioFrameDesc()
    : sample_rate(0)
    , channel_num(0)
    , src_type(AUDIO_SRC_TYPE_NONE) {}

  uint32 sample_rate; ///< 采样率，单位：赫兹（Hz）。
  uint32 channel_num; ///< 通道数，1表示单声道（mono），2表示立体声（stereo）。
  int32 src_type; ///< 音频源类型。
};

/// 音频帧。
struct AudioFrame {
  AudioFrame()
    : data_size(0)
    , data(NULL) {}

  std::string identifier; ///< 音频帧所属的房间成员id。
  AudioFrameDesc desc;  ///< 音频帧描述。
  uint32 data_size; ///< 视频帧的数据缓冲区大小，单位：字节。
  uint8* data; ///< 视频帧的数据缓冲区，SDK内部会管理缓冲区的分配和释放。
};


//////////////////////////////////////////////////////////////////////////
//
// 视频相关的由此开始

/// 色彩格式。
enum ColorFormat {
  COLOR_FORMAT_I420 = 0,
//   COLOR_FORMAT_NV21 = 1,
//   COLOR_FORMAT_YV12 = 2,
//   COLOR_FORMAT_NV12 = 3,
//   COLOR_FORMAT_UYVY = 4,
//   COLOR_FORMAT_YUYV = 5,
//   COLOR_FORMAT_YUY2 = 6,
//   COLOR_FORMAT_RGB16 = 7,
   COLOR_FORMAT_RGB24 = 8,
//   COLOR_FORMAT_RGB32 = 9,
};

/// 视频源类型。
enum VideoSrcType {
  VIDEO_SRC_TYPE_NONE = 0, ///< 默认值，无意义。
  VIDEO_SRC_TYPE_CAMERA = 1, ///< 摄像头。
};

/**
@brief 视频帧描述。

@todo rotate使用枚举类型。
@todo src_type使用枚举类型。
*/
struct VideoFrameDesc {
  VideoFrameDesc()
    : color_format(COLOR_FORMAT_RGB24)
    , width(0)
    , height(0)
    , rotate(0)
    , src_type(VIDEO_SRC_TYPE_CAMERA) {}

  ColorFormat color_format; ///< 色彩格式，详情见ColorFormat的定义。
  uint32 width; ///< 宽度，单位：像素。
  uint32 height; ///< 高度，单位：像素。

  /**
  画面旋转的角度：
  - source_type为VIDEO_SRC_TYPE_CAMERA时，表示视频源为摄像头。
    在终端上，摄像头画面是支持旋转的，App需要根据旋转角度调整渲染层的处理，以保证画面的正常显示。
  - source_type为其他值时，rotate恒为0。
  */
  int32 rotate;

  VideoSrcType src_type; ///< 视频源类型，详情见VideoSrcType的定义。
};

/// 视频帧。
struct VideoFrame {
  VideoFrame()
    : data_size(0)
    , data(NULL) {}

  std::string identifier; ///< 视频帧所属的房间成员id。
  VideoFrameDesc desc; ///< 视频帧描述。
  uint32 data_size; ///< 视频帧的数据缓冲区大小，单位：字节。
  uint8* data; ///< 视频帧的数据缓冲区，SDK内部会管理缓冲区的分配和释放。
};

/// 视频通道类型。
typedef enum VideoChannelType {
  VIDEO_CHANNEL_MAIN = 0, ///< 主路视频。
} VideoChannelType;


enum NetStateType {
  NETTYPE_E_NONE	= 0, ///< no network.
  NETTYPE_E_LINE	= 1, ///< LINE
  NETTYPE_E_WIFI	= 2, ///< WIFI
  NETTYPE_E_3G		= 3, ///< 3G
  NETTYPE_E_2G		= 4, ///< 2G
  NETTYPE_E_4G		= 5, ///< 4G
};

} // namespace av
} // namespace tencent

#endif // #ifndef AV_COMMON_H_