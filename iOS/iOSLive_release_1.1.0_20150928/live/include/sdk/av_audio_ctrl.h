#ifndef AV_AUDIO_CTRL_H_
#define AV_AUDIO_CTRL_H_

#include "av_common.h"

namespace tencent {
namespace av {

/// 音频编解码类型。
enum AudioCodecType {
  AUDIO_CODEC_TYPE_SILK = 4102, ///< SILK。
  AUDIO_CODEC_TYPE_CELT = 4103, ///< CELT。
};

class AV_EXPORT AVAudioCtrl {
 public:
  virtual ~AVAudioCtrl() {}

#if WIN32
  /**
  @brief 打开/关闭自动增益调节。

  @details 同步返回结果。开关打开时，SDK会自动控制采集的音量，调节到一个合适的范围。

  @param [in] is_enable 是否打开。

  @return true表示成功，false表示失败。

  @remark 
	. 这个方法不等同于软件麦克风增强，不一定会增加采集的音量。
	. 这个接口只有Windows平台支持。
  */
  virtual bool EnableBoost(bool is_enable) = 0;

  /**
  @brief 自动增益调节是否打开。

  @return true表示打开，false表示关闭。

  @remark 
  . 这个接口只有Windows平台支持。
  */
  virtual bool IsBoostEnable() = 0;

  /**
  @brief 打开/关闭降噪。

  @details 同步返回结果。主要用于降低输入音频流的环境噪音。

  @param [in] is_enable 是否打开。

  @return true表示成功，false表示失败。

  @remark 
  . 这个接口只有Windows平台支持。
  */
  virtual bool EnableNS(bool is_enable) = 0;

  /**
  @brief 降噪是否打开。

  @return true表示打开，false表示关闭。

  @remark 
  . 这个接口只有Windows平台支持。
  */
  virtual bool IsNSEnable() = 0;

  /**
  @brief 打开/关闭回声消除。

  @details 同步返回结果。主要用于消除输入音频流的回声。

  @param [in] is_enable 是否打开。

  @return true表示成功，false表示失败。

  @remark 
  . 这个接口只有Windows平台支持。
  */
  virtual bool EnableAEC(bool is_enable) = 0;

  /**
  @brief 回声消除是否打开。

  @return true表示打开，false表示关闭。

  @remark 
  . 这个接口只有Windows平台支持。
  */
  virtual bool IsAECEnable() = 0;
#endif
  /**
  @brief 获取通话中实时音频质量相关信息，业务侧可以不用关心，主要用来查看通话情况、排查问题等。

  @return 以字符串形式返回音频相关的质量参数。
  */
  virtual std::string GetQualityTips() = 0;

#if defined(ANDROID) || defined(TARGET_OS_IPHONE)
  /**
  @brief 获取麦克风数字音量。

  @return 麦克风数字音量。数字音量取值范围[0,100]。

  @remark 
  . 这个接口只有Android/iOS平台支持。
  */
  virtual uint32 GetVolume() = 0;
  
   /**
  @brief 设置麦克风数字音量。

  @param [in] value 麦克风数字音量。数字音量取值范围[0,100]。

  @remark 
  . 这个接口只有Android/iOS平台支持。
  */
  virtual void SetVolume(uint32 value) = 0;

   /**
  @brief 获取麦克风动态音量。

  @return 麦克风动态音量。动态音量取值范围[0,100]。

  @remark 
  . 这个接口只有Android/iOS平台支持。
  */
  virtual uint32 GetDynamicVolume() = 0;

  /**
  @brief 打开/关闭麦克风。

  @param [in] is_enable 是否打开。

  @return true表示操作成功，false表示操作失败。

  @remark 
  . 这个接口只有Android/iOS平台支持。
  */
  virtual bool EnableMic(bool is_enable) = 0;

   /**
  @brief 打开/关闭扬声器。

  @param [in] is_enable 是否打开。

  @return true表示操作成功，false表示操作失败。

  @remark 
  . 这个接口只有Android/iOS平台支持。
  */
  virtual bool EnableSpeaker(bool is_enable) = 0;

  /**
  @brief 设置外放模式。

  @param [in] 外放模式。0为听筒模式，1为扬声器模式。

  @return true表示操作成功，false表示操作失败。

  @remark 
  . 这个接口只有Android/iOS平台支持。
  */
  virtual bool SetAudioOutputMode(int output_mode) = 0;
#endif
};

} // namespace av
} // namespace tencent

#endif // #define AV_AUDIO_CTRL_H_