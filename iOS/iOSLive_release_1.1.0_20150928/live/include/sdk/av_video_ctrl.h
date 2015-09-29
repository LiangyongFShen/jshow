#ifndef AV_VIDEO_CTRL_H_
#define AV_VIDEO_CTRL_H_

#include "av_common.h"

namespace tencent {
namespace av {

enum VideoCodecType {
  VIDEO_CODEC_TYPE_H264 = 5,
};

struct CameraInfo {
  std::string device_id; //摄像头vidpid
  uint32 width;  ///采集画面宽度
  uint32 height; ///采集画面高度
  uint32 fps; ///< 采集帧率
};

class AV_EXPORT AVVideoCtrl {
 public:
  virtual ~AVVideoCtrl() {}

  /**
  @brief 获取通话中实时视频质量相关信息，业务侧可以不用关心，主要用来查看通话情况、排查问题等。

  @return 以字符串形式返回视频相关的质量参数。
  */
  virtual std::string GetQualityTips() = 0;

  /**
  @brief 开启外部采集之前必须设置外部采集的能力，包括图像大小，帧率。

  @return true表示成功，false表示失败。
  @remark 
  . 这个接口暂不支持。
  */
  virtual bool SetExternalCapAbility(CameraInfo* pinfo) = 0;

#if defined(ANDROID) || defined(TARGET_OS_IPHONE)
  //摄像头设备相关
  typedef void (*EnableCameraCompleteCallback)(bool is_enable, int ret_code, void* custom_data);
  typedef void (*SwitchCameraCompleteCallback)(int camera_id, int ret_code, void* custom_data);

  /**
  @brief 打开/关闭摄像头。

  @param [in] is_enable 是否打开。
  @param [in] callback 操作完成的回调。
  @param [in] custom_data 业务侧自定义参数。会在操作回调中原样返回。

  @return 返回错误码。当返回AV_OK时，操作回调才会被执行；否则就不会执行，需要处理具体的错误码。

  @remark 
  . 这个接口只有Android/iOS平台支持。
  */
  virtual int EnableCamera(bool is_enable, EnableCameraCompleteCallback callback, void* custom_data) = 0;  

  /**
  @brief 却换摄像头。

  @param [in] camera_id 摄像头的id。id取值范围[0, 摄像头个数-1]。
  @param [in] callback 操作完成的回调。
  @param [in] custom_data 业务侧自定义参数。会在操作回调中原样返回。

  @return 返回错误码。当返回AV_OK时，操作回调才会被执行；否则就不会执行，需要处理具体的错误码。

  @remark 
  . 这个接口只有Android/iOS平台支持。
  */
  virtual int SwitchCamera(int camera_id, SwitchCameraCompleteCallback callback, void* custom_data) = 0;

   /**
  @brief 获取摄像头个数。

  @return 返回摄像头个数。如果获取失败则返回0。

  @remark 
  . 这个接口只有Android/iOS平台支持。
  */
  virtual int GetCameraNum() = 0;

  /**
  @brief 设置画面旋转角度。

  @param [in] rotation 画面旋转角度。角度取值：0，90，180，270。

  @remark 
  . 这个接口只有Android平台支持。
  */
  virtual void SetRotation(int rotation) = 0;


  //远端视频设备相关
  typedef void (*RemoteVideoPreviewCallback)(VideoFrame* video_frame, void* custom_data);
  typedef void (*RemoteVideoRenderFrameCallback)(const std::string& identifer, void* custom_data);
  
  /**
  @brief 设置远端视频的预览回调。

  @details 设置远端视频的预览回调。如果设置了该回调，那么就可以获取所请求(请求几路就可以获得几路)的远端视频画面的帧序列，业务侧可以实现对视频帧的处理及渲染等。

  @param [in] callback 预览回调。
  @param [in] custom_data 业务侧自定义参数。会在预览回调中原样返回。

  @return true 代表设置成功，否则设置失败。

  @remark 该音视频SDK会在主线程调用该预览回调，业务侧根据实际需要决定是否却换线程。

  @remark 
  . 这个接口只有Android/iOS平台支持。
  */
  virtual bool SetRemoteVideoPreviewCallback(RemoteVideoPreviewCallback callback, void *custom_data) = 0;

  /**
  @brief 设置远端视频的每帧渲染的通知回调。

  @details 设置远端视频的每帧渲染的通知回调。如果设置了该回调，则渲染每帧远端画面时，会通过该回调通知业务层。如果有多路远端视频，也都会通知。

  @param [in] callback 预览回调。
  @param [in] custom_data 业务侧自定义参数。会在预览回调中原样返回。

  @return true 代表设置成功，否则设置失败。

  @remark 
  . 这个接口只有Android/iOS平台支持。
  */
  virtual bool SetRemoteVideoRenderFrameCallback(RemoteVideoRenderFrameCallback callback, void *custom_data) = 0;


  //外部视频捕获设备相关
  typedef void (*EnableExternalCaptureCompleteCallback)(bool, int, void*);

  /**
  @brief 打开/关闭外部视频捕获设备。

  @param [in] is_enable 是否打开。
  @param [in] callback 操作完成的回调。
  @param [in] custom_data 业务侧自定义参数。会在操作回调中原样返回。

  @return 返回错误码。当返回AV_OK时，操作回调才会被执行；否则就不会执行，需要处理具体的错误码。

  @remark 
  . 这个接口暂不支持。
  */
  virtual int EnableExternalCapture(bool is_enable, EnableExternalCaptureCompleteCallback callback, void* custom_data) = 0;

   /**
  @brief 向音视频SDK传入捕获的视频帧。

  @param [in] frame 视频帧数据及相关参数。

  @remark 要控制好传入视频帧的频率，最好控制在每秒10帧左右，具体频率视实际使用场景而定。

  @remark 
  . 这个接口暂不支持。
  */
  virtual void FillExternalCaptureFrame(VideoFrame &frame) = 0;
  
#endif
};

} // namespace av
} // namespace tencent

#endif // #ifndef AV_VIDEO_CTRL_H_