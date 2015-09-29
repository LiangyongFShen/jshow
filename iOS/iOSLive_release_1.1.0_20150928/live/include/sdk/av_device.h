#ifndef AV_DEVICE_H_
#define AV_DEVICE_H_

#include "av_common.h"
#include "av_device_base.h"
#include <vector>

namespace tencent {

namespace av {
class AVContext;
/// 常量宏，表示未知的设备类型，可作为默认值。
#define DEVICE_UNKNOWN      "\\unknown"           // Unknown device type.

// Video input/output device type/id
#define DEVICE_VIDEO        "\\video"               // Video device type.
#define DEVICE_CAMERA       "\\video\\camera"       // Camera device type.
#define DEVICE_REMOTE_VIDEO "\\video\\remote_video" // The virtual remote video output device.
#define DEVICE_EXTERNAL_CAPTURE "\\video\\external_capture" //external capture device type.

// Audio input/output device type/id
#define DEVICE_AUDIO        "\\audio"               // Audio device type.
#define DEVICE_MIC          "\\audio\\mic"          // Mic device type.
#define DEVICE_PLAYER       "\\audio\\player"       // Sound player device type.
#define DEVICE_ACCOMPANY    "\\audio\\accompany"    // Audio Accompany device type.
#define DEVICE_REMOTE_AUDIO "\\audio\\remote_audio" // The virtual remote audio output device.
#define DEVICE_MIX          "\\audio\\mix"          // Mix device
#define DEVICE_MIX_INPUT    "\\audio\\mix\\input"   // Input mix device
#define DEVICE_MIX_OUTPUT   "\\audio\\mix\\output"  // Output mix device

//////////////////////////////////////////////////////////////////////////
//
// 音频设备相关的由此开始

/// 常量宏，表示音量的最小值。
#define MIN_AUDIO_DEVICE_VOLUME 0

/// 常量宏，表示音量的最大值。
#define MAX_AUDIO_DEVICE_VOLUME 100

/**
@brief 音频设备封装类的基类。

@details AVAudioDevice表示系统中一个物理的或虚拟的音频设备。
  AVAudioDevice提供了操作音频设备的通用方法，例如音量调节等。
  音频设备可分为音频输入设备和音频输出设备。

@remark 下面所提到的音量，全部为App内部的音量，和操作系统的音量没有联系。

@todo SetFrameDataCallback缺注释。
@todo GetFrameDataCallback()和GetFrameCustomData()必要性？
*/
class AV_EXPORT AVAudioDevice : public AVDevice {
 public:
  /// 默认构造函数。
  AVAudioDevice()
    : frame_data_callback_(NULL)
    , frame_custom_data_(NULL) {
    type_ = DEVICE_AUDIO;
  }

  /// 拷贝构造函数。
  AVAudioDevice(const AVDevice::Info& info)
    : AVDevice(info)
    , frame_data_callback_(NULL)
    , frame_custom_data_(NULL) {
    type_ = DEVICE_AUDIO;
  }

  /**
  @brief 获得音频设备音量大小。

  @return 返回音频设备音量值，取值范围[0,100]。

  @remark 需要特别说明的是伴奏，当输入源为播放器（QQ音乐、酷狗音乐）时，值为相对音量，10为1倍，100为10倍，1为原来的1/10。
    当输入源为系统音量时，值为绝对音量。

  @todo 伴奏这里的说明比较模糊。
  */
  virtual uint32 GetVolume() = 0;

  /**
  @brief 设置音频设备音量大小。

  @param value 音频设备目标音量，取值范围[0,100]。

  @remark 如果入参的大小超出取值范围，会自动进行截取。
    需要特别说明的是伴奏，当输入源为播放器（QQ音乐、酷狗音乐）时，值为相对音量，10为1倍，100为10倍，1为原来的1/10。
    当输入源为系统音量时，值为绝对音量。

  @todo 参数命名风格不一致。
  */
  virtual void SetVolume(uint32 value) = 0;

  /**
  @brief 获得音频设备动态音量。

  @return 返回音频设备动态音量，取值范围[0,100]。

  @todo 动态音量有没有更加通俗的称呼。
  */
  virtual uint32 GetDynamicVolume() = 0;

  // Register an audio frame data callback. When a new audio frame appears,
  // the callback will be invoked, and the 'custom_data' is passed back as the last parameter.
  typedef void(*FrameDataCallback)(AudioFrame* audio_frame, void* custom_data);

  void SetFrameDataCallback(FrameDataCallback frame_callback, void* custom_data = NULL) {
    frame_data_callback_ = frame_callback;
    frame_custom_data_ = custom_data;
  }

  FrameDataCallback GetFrameDataCallback() {
    return frame_data_callback_;
  }

  void* GetFrameCustomData() {
    return frame_custom_data_;
  }

 protected:
  FrameDataCallback frame_data_callback_;
  void* frame_custom_data_;

  DISALLOW_EVIL_DESTRUCTIONS(AVAudioDevice)
};

/**
@brief 音频预览能力的封装类。

@details SDK的各种音频设备封装类，通过继承AVSupportAudioPreview，向App提供音频预览能力。
  App可以通过AVSupportAudioPreview获得音频设备的输入/输出数据。

@todo 补充说明预览回调会重复触发。
*/
class AV_EXPORT AVSupportAudioPreview {
 public:
  /**
  @brief SetPreviewCallback()的回调函数。

  @details 此函数是和SetPreviewCallback()一起使用的回调函数，用来向App回传音频数据。

  @param audio_frame 音频帧对象。
  @param custom_data 值等于调用SetPreviewCallback()时的入参custom_data。
  */
  typedef void(*PreviewCallback)(AudioFrame* audio_frame, void* custom_data);

  /**
  @brief 设置音频预览回调。

  @details App可以通过设置音频预览回调，在回调函数中获得音频设备的输入/输出数据。

  @param [in] frame_callback 函数指针，指向App定义的回调函数，NULL表示取消回调。
  @param [in] custom_data App指定的一个没有类型的指针，SDK会在回调函数中把该值回传给App。
  */
  void SetPreviewCallback(PreviewCallback frame_callback, void* custom_data = NULL) {
    preview_data_callback_ = frame_callback;
    preview_custom_data_ = custom_data;
  }

  PreviewCallback GetPreviewCallback() {
    return preview_data_callback_;
  }

  void* GetPreviewCustomData() {
    return preview_custom_data_;
  }

 protected:
  AVSupportAudioPreview()
    : preview_data_callback_(NULL)
    , preview_custom_data_(NULL) {}

  PreviewCallback preview_data_callback_;
  void* preview_custom_data_;

  DISALLOW_EVIL_DESTRUCTIONS(AVSupportAudioPreview)
};

/**
@brief 远端音频设备的封装类。

@details 远端音频设备是一个虚拟的设备，它属于音频输出设备，用于输出远端音频。
  可以把AVRemoteAudioDevice理解成是所有房间成员的音频数据分发器。
  App可以通过AVRemoteAudioDevice获得单个房间成员的音频数据。
*/
class AV_EXPORT AVRemoteAudioDevice
  : public AVAudioDevice
  , public AVSupportAudioPreview {
 public:
  /// 默认构造函数。
  AVRemoteAudioDevice() {
    type_ = DEVICE_REMOTE_AUDIO;
  }

  /// 拷贝构造函数。
  AVRemoteAudioDevice(const AVDevice::Info& info) : AVAudioDevice(info) {
    type_ = DEVICE_REMOTE_AUDIO;
  }

  DISALLOW_EVIL_DESTRUCTIONS(AVRemoteAudioDevice)
};

/**
@brief 麦克风的封装类。

@details 麦克风属于音频输入设备。
  一个终端上可能存在多个麦克风。
  可以使用AVDeviceMgr::GetDeviceByType(DEVICE_MIC)，获得当前系统的麦克风列表。
*/
class AV_EXPORT AVMicDevice
  : public AVAudioDevice
  , public AVSupportAudioPreview {
 public:
  /// 默认构造函数。
  AVMicDevice() {
    type_ = DEVICE_MIC;
  }

  /// 拷贝构造函数。
  AVMicDevice(const AVDevice::Info& info) : AVAudioDevice(info) {
    type_ = DEVICE_MIC;
  }

  DISALLOW_EVIL_DESTRUCTIONS(AVMicDevice)
};

/**
@brief 音频播放设备的封装类。

@details 音频播放设备属于音频输出设备音频，它包括扬声器和听筒。
  一个终端上可能存在多个音频播放设备。
  可以使用AVDeviceMgr::GetDeviceByType(DEVICE_PLAYER)，获得当前系统的音频播放设备列表。
*/
class AV_EXPORT AVPlayerDevice
  : public AVAudioDevice
  , public AVSupportAudioPreview {
 public:
  /// 默认构造函数。
  AVPlayerDevice() {
    type_ = DEVICE_PLAYER;
  }

  /// 拷贝构造函数。
  AVPlayerDevice(const AVDevice::Info& info) : AVAudioDevice(info) {
    type_ = DEVICE_PLAYER;
  }

  DISALLOW_EVIL_DESTRUCTIONS(AVPlayerDevice)
};

/**
@brief 伴奏设备。

@details 伴奏设备是一个虚拟的设备，它既是音频输入设备，也是音频输出设备。
  App可以选择系统伴奏或者应用伴奏来添加背景声音，本地和远端都会输出背景声音。

@attention 只有Windows版本的SDK才支持伴奏。
*/
class AV_EXPORT AVAccompanyDevice
  : public AVAudioDevice
  , public AVSupportAudioPreview {
 public:
  /**
  @brief 伴奏源类型。

  @todo 枚举值定义可以再精简一些。
  */
  enum SourceType {
    AV_ACCOMPANY_SOURCE_TYPE_NONE = 0, ///< 默认值，无意义。
    AV_ACCOMPANY_SOURCE_TYPE_SYSTEM = 1, ///< 系统伴奏，来源为系统的声音。
    ACCOMPANY_SOURCE_TYPE_PROCESS = 2, ///< 应用伴奏，来源为播放器进程的声音。
  };

 public:
  /// 默认构造函数。
  AVAccompanyDevice() {
    type_ = DEVICE_ACCOMPANY;
  }

  /// 拷贝构造函数。
  AVAccompanyDevice(const AVDevice::Info& info) : AVAudioDevice(info) {
    type_ = DEVICE_ACCOMPANY;
  }

  /**
  @brief 设置伴奏源。

  @details 当伴奏源为ACCOMPANY_SOURCE_TYPE_PROCESS，player_path不能为空，
    若media_file_path为空，则自动以当前播放器播放的声音为伴奏源；
    若media_file_path不为空，会自动使用播放器播放指定歌曲。
    当伴奏源为ACCOMPANY_SOURCE_TYPE_ SYSTEM，player_path和media_file_path不需要设置。

  @param player_path 播放器路径。
  @param media_file_path 使用播放器播放的音频文件路径。
  @param source_type 伴奏源。

  @todo 这个接口用法太复杂了，可以进一步优化。
  */
  virtual void SetSource(std::string player_path, std::string media_file_path, SourceType source_type) = 0;

  /**
  @brief 获得伴奏源类型。

  @return 返回伴奏源类型，详情见SourceType的定义。
  */
  virtual SourceType GetSourceType() = 0;

  /**
  @brief 获得播放器进程的路径。

  @return 当伴奏源类型为ACCOMPANY_SOURCE_TYPE_PROCESS时，返回播放器进程的路径。
  */
  virtual std::string GetPlayerPath() = 0;

  /**
  @brief 获得影音文件路径。

  @return 当伴奏源类型为ACCOMPANY_SOURCE_TYPE_PROCESS时，返回影音文件的路径。
  */
  virtual std::string GetMediaFilePath() = 0;

  DISALLOW_EVIL_DESTRUCTIONS(AVAccompanyDevice)
};

/**
@brief 软件混音器。

@details MixDevice是一种抽象的设备，可以把不同的音频混混合成一个音频源输出。
  实际运行过程，您如果需要使用麦克风、伴奏功能，还是要显式调用选中麦克风、伴奏设备。
  AVMixDevice的设备类型为DEVICE_MIX。
  通过调用AVDeviceMgr::GetDeviceByType()，您可以通过获取混音设备设备列表。
  AVMixDevice支持音频帧预览。
  目前支持的混音设备只有麦克风和伴奏，添加其他设备没有任何效果。

@remark 混音器并不影响实际的输入和输出，只是作为SDK提供的高级音频处理功能。

@attention 只有Windows版本的SDK才支持软件混音。

*/
class AV_EXPORT AVMixDevice
  : public AVAudioDevice
  , public AVSupportAudioPreview {
 public:
  /// 默认构造函数。
  AVMixDevice() {
    type_ = DEVICE_MIX;
  }

  /// 拷贝构造函数。
  AVMixDevice(const AVDevice::Info& info) : AVAudioDevice(info) {
    type_ = DEVICE_MIX;
  }

  /**
  @brief 添加混音设备。

  @param device_id 混音设备Id。

  @return 添加成功返回true，否则返回false。
  */
  virtual bool AddDevice(std::string device_id) = 0;

  /**
  @brief 移除混音设备。

  @param device_id 混音设备Id。

  @return 移除成功返回true，否则返回false。
  */
  virtual bool RemoveDevice(std::string device_id) = 0;

  /**
  @brief 获得混音设备个数。

  @return 返回混音设备个数。
  */
  virtual int32 GetDeviceCount() = 0;

  /**
  @brief 获得混音设备列表。

  @return 返回混音设备id的列表。
  */
  virtual std::vector<std::string> GetDeviceIdList() = 0;

 private:

  DISALLOW_EVIL_DESTRUCTIONS(AVMixDevice)
};

// mix input device.
// mix input device has a type of 'DEVICE_MIX_INPUT'.
class AV_EXPORT AVMixInputDevice : public AVMixDevice {
 public:
  AVMixInputDevice() {
    type_ = DEVICE_MIX_INPUT;
  }

  AVMixInputDevice(const AVDevice::Info& info) : AVMixDevice(info) {
    type_ = DEVICE_MIX_INPUT;
  }

  DISALLOW_EVIL_DESTRUCTIONS(AVMixInputDevice)
};

// mix output device.
// mix output device has a type of 'DEVICE_MIX_OUTPUT'.
class AV_EXPORT AVMixOutputDevice : public AVMixDevice {
 public:
  AVMixOutputDevice() {
    type_ = DEVICE_MIX_OUTPUT;
  }

  AVMixOutputDevice(const AVDevice::Info& info) : AVMixDevice(info) {
    type_ = DEVICE_MIX_OUTPUT;
  }

  DISALLOW_EVIL_DESTRUCTIONS(AVMixOutputDevice)
};

//////////////////////////////////////////////////////////////////////////
//
// 视频设备相关的由此开始

/**
@brief 视频设备封装类的基类。

@details AVVideoDevice表示系统中一个物理的或虚拟的视频设备。
  视频设备可分为视频输入设备和视频输出设备。

@todo SetFrameDataCallback()是否跟Preview重复了？
*/
class AV_EXPORT AVVideoDevice : public AVDevice {
 public:
  /// 默认构造函数。
  AVVideoDevice()
    : frame_data_callback_(NULL)
    , frame_custom_data_(NULL) {
    type_ = DEVICE_VIDEO;
  }

  /// 拷贝构造函数。
  AVVideoDevice(const AVDevice::Info& info)
    : AVDevice(info)
    , frame_data_callback_(NULL)
    , frame_custom_data_(NULL) {
    type_ = DEVICE_VIDEO;
  }

  typedef void(*FrameDataCallback)(VideoFrame* video_frame, void* custom_data);

  void SetFrameDataCallback(FrameDataCallback frame_callback, void* custom_data = NULL) {
    frame_data_callback_ = frame_callback;
    frame_custom_data_ = custom_data;
  }

  FrameDataCallback GetFrameDataCallback() {
    return frame_data_callback_;
  }

  void* GetFrameCustomData() {
    return frame_custom_data_;
  }

 protected:
  FrameDataCallback frame_data_callback_;
  void* frame_custom_data_;

  DISALLOW_EVIL_DESTRUCTIONS(AVVideoDevice)
};

/**
@brief 视频预览能力的封装类。

@details SDK的各种视频设备封装类，通过继承AVSupportVideoPreview，向App提供视频预览能力。
  App可以通过AVSupportVideoPreview获得视频设备的输入/输出数据。

@todo 补充说明预览回调会重复触发。
@todo GetPreviewCallback()和GetPreviewCustomData()是否需要。
@todo SetPreviewParam()的入参使用结构。
*/
class AV_EXPORT AVSupportVideoPreview {
 public:
  struct PreviewParam {
    std::string device_id;
    uint32 width;
    uint32 height;
    ColorFormat color_format;
    VideoSrcType src_type;
  };

  /**
  @brief SetPreviewCallback()的回调函数。

  @details 此函数是和SetPreviewCallback()一起使用的回调函数，用来向App回传视频数据。

  @param video_frame 视频帧对象。
  @param custom_data 值等于调用SetPreviewCallback()时的入参custom_data。
  */
  typedef void(*PreviewCallback)(VideoFrame* video_frame, void* custom_data);

  /**
  @brief 设置视频预览回调。

  @details App可以通过设置视频预览回调，在回调函数中获得视频设备的输入/输出数据。

  @param [in] frame_callback 函数指针，指向App定义的回调函数，NULL表示取消回调。
  @param [in] custom_data App指定的一个没有类型的指针，SDK会在回调函数中把该值回传给App。
  */
  void SetPreviewCallback(PreviewCallback frame_callback, void* custom_data = NULL);

  /**
  @brief 设置预览视频画面的参数。

  @param id 画面Id。如果是本地摄像头画面，因为只有一路，可以填""。如果是远端视频画面，填每个画面的成员id即可。
  @param width 预览画面宽度，最好是4的倍数。
  @param height 预览画面高度，最好是4的倍数。
  @param color_format 色彩格式，SDK目前只支持RGB24、I420。

  @remark 目前仅Windows平台支持设置预览视频画面的参数。可以给每路成员分别设置，也可以给所有成员统一设置。如果是给所有成员设置, 则id填""即可。
  @todo 需要加返回值，加一个入参判断的逻辑。
  */
  int SetPreviewParam(std::string id, uint32 width, uint32 height, ColorFormat color_format);

  PreviewCallback GetPreviewCallback();

  void* GetPreviewCustomData();

 protected:
  AVSupportVideoPreview();

  PreviewCallback preview_data_callback_;
  void* preview_custom_data_;

  bool is_preview_param_share_;
  std::vector<PreviewParam> preview_param_list_;

  DISALLOW_EVIL_DESTRUCTIONS(AVSupportVideoPreview)
};

/**
@brief 视频预处理能力的封装类。

@details SDK的各种视频设备封装类，通过继承AVSupportVideoPreTreatment，向App提供视频预处理能力。
  App可以通过AVSupportVideoPreTreatment获得视频设备的输入数据。
*/
class AV_EXPORT AVSupportVideoPreTreatment {
 public:
  typedef void(*PreTreatmentFun)(VideoFrame* video_frame, void* custom_data);

   /**
  @brief 设置预处理函数指针。

  @param pre_fun 预处理函数指针。
  @param custom_data 业务侧自定义参数，会在预处理函数中原样返回它。  

  @remark 业务侧实现该预处理函数，然后由SDK同步调用它。实现预处理函数的注意事项：预处理函数耗时不要过久，最好控制在10ms内；同时不能改变图像大小和图像颜色格式。
  */
  void SetPreTreatmentFun(PreTreatmentFun pre_fun, void* custom_data = NULL) {
    pre_treatment_fun_ = pre_fun;
    frame_pre_custom_data_ = custom_data;
  }
 protected:
  AVSupportVideoPreTreatment();
  PreTreatmentFun pre_treatment_fun_;
  void* frame_pre_custom_data_;

  DISALLOW_EVIL_DESTRUCTIONS(AVSupportVideoPreTreatment)

};

/**
@brief 远端视频设备的封装类。

@details 远端视频设备是一个虚拟的设备，它属于视频输出设备，用于输出远端视频。
  可以把AVRemoteVideoDevice理解成是所有房间成员的视频数据分发器。
  App可以通过AVRemoteVideoDevice获得单个房间成员的视频数据。
*/
class AV_EXPORT AVRemoteVideoDevice
  : public AVVideoDevice
  , public AVSupportVideoPreview {
 public:
  /// 默认构造函数。
  AVRemoteVideoDevice() {
    type_ = DEVICE_REMOTE_VIDEO;
    remote_device_delegate_ = NULL;
    remote_device_delegate_custom_data_ = NULL;
  }

  /// 远程视频设备委托的抽象基类，App需要实现其成员函数来监听远程视频设备的事件。
  struct AV_EXPORT Delegate {
    virtual ~Delegate() {}

    /**
      @brief 远端成员视频画面渲染通知。

      @details 每渲染一帧画面时，会通知一次。

      @param identifier 该帧画面的成员id。
      @param custom_data 业务侧自定义参数，会原样返回它。 
    */
    virtual void OnRenderFrame(const std::string& identifier, void* custom_data) = 0;
  };

  void SetDelegate(Delegate* delegate, void* custom_data = NULL) {
    remote_device_delegate_ = delegate;
    remote_device_delegate_custom_data_ = custom_data;
  }

 protected:
  Delegate* remote_device_delegate_;
  void* remote_device_delegate_custom_data_;

 public:
  DISALLOW_EVIL_DESTRUCTIONS(AVRemoteVideoDevice)
};

/**
@brief 摄像头的封装类。

@details 摄像头属于视频输入设备。

@remark iOS版本的SDK有特定的接口。
*/
class AV_EXPORT AVCameraDevice
  : public AVVideoDevice
  , public AVSupportVideoPreview
  , public AVSupportVideoPreTreatment {
 public:
  /// 默认构造函数。
  AVCameraDevice() {
    type_ = DEVICE_CAMERA;
  }

  /// 拷贝构造函数。
  AVCameraDevice(const AVDevice::Info& info) : AVVideoDevice(info) {
    type_ = DEVICE_CAMERA;
  }

#ifdef OS_IOS
  /**
  @brief 获取预览显示层。

  @details 同步返回结果。预览显示层是针对iOS做的一个高级封装。

  @return 预览显示层的id。

  @remark iOS特有接口。

  @todo 需要明确一下用法。
  */
  virtual void* GetPreviewLayer() = 0;
#endif

  DISALLOW_EVIL_DESTRUCTIONS(AVCameraDevice)
};

/**
@brief 外部视频捕获设备。

@details 外部视频捕获设备属于视频输入设备。

@remark 
. 这个接口暂不支持。
*/
class AV_EXPORT AVExternalCapture
  : public AVCameraDevice {
 public:


  /// 默认构造函数。
  AVExternalCapture() {
    type_ = DEVICE_EXTERNAL_CAPTURE;
  }

  /// 拷贝构造函数。
  AVExternalCapture(const AVDevice::Info& info) : AVCameraDevice(info) {
    type_ = DEVICE_EXTERNAL_CAPTURE;
  }
#if defined(TARGET_OS_IPHONE)
  virtual void* GetPreviewLayer() {
    return NULL;
  };
#endif
  virtual void OnCaptureFrame(VideoFrame &frame){};
  

  DISALLOW_EVIL_DESTRUCTIONS(AVExternalCapture)
};

} // namespace av
} // namespace tencent

#endif // #ifndef AV_DEVICE_H_
