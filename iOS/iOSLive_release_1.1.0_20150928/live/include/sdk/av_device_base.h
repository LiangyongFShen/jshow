#ifndef AV_DEVICE_BASE_H_
#define AV_DEVICE_BASE_H_

#include "av_common.h"

namespace tencent {
namespace av {

/**
@brief 音视频设备封装类的基类。

@details AVDevice提供了一系列操作和访问设备的接口。
  App总是通过AVContext的设备管理器来获取设备对象，无需手动创建/销毁AVDevice对象。

@todo Start()/Stop()/SetInfo()/SetSelect()是要删掉的。
@todo 有了GetInfo()，其他接口可以进一步精简。
*/
class AV_EXPORT AVDevice {
 public:
  /// 设备基本信息。
  struct AV_EXPORT Info {
    /// 默认构造函数。
    Info() {}

    /// 拷贝构造函数。
    Info(const Info& other) {
      string_id = other.string_id;
      name = other.name;
      description = other.description;
    }

    virtual ~Info() {}

    std::string string_id; ///< 设备Id，可以作为多个设备间的唯一标识。
    std::string name; ///< 设备名称。
    std::string description; ///< 设备描述。
  };

  /// 默认构造函数，仅供内部使用。
  AVDevice() : is_selected_(false) {}

  /// 拷贝构造函数，仅供内部使用。
  AVDevice(const Info& info)
    : info_(info)
    , is_selected_(false) {}

  /**
  @brief 获得当前设备Id。

  @return 返回当前设备的Id。

  @remark 摄像头类Id为设备名，其他虚拟设备Id和Type同名。
  */
  const std::string& GetId() const {
    return info_.string_id;
  }

  /**
  @brief 获得当前设备类型。

  @return 返回当前设备类型。

  @remark 设备类型是一个字符串，以下是几种典型设备的宏定义类型。

  @todo 补充宏定义的注释"\\video\\camera"、"\\media_file"、"\\audio\\mic"、"\\audio\\player"
  */
  const std::string& GetType() const {
    return type_;
  }

  /**
  @brief 获取设备信息。

  @return 返回设备信息，详情见Info的定义。
  */
  const Info& GetInfo() const {
    return info_;
  }

  void SetInfo(const Info& info) {
    info_ = info;
  }

  /**
  @brief 判断设备是否处于选中状态。

  @return false表示设备没有被选中，否则表示被选中。

  @remark 处于选中状态的设备会在音视频会话中使用。
  */
  bool IsSelected() const {
    return is_selected_;
  }

  void SetSelect(bool is_select = true) {
    is_selected_ = is_select;
  }

 protected:
  std::string type_;
  Info info_;
  bool is_selected_;

  DISALLOW_EVIL_DESTRUCTIONS(AVDevice)
};

} // namespace av
} // namespace tencent

#endif // #ifndef AV_DEVICE_BASE_H_