#ifndef AV_ENDPOINT_H_
#define AV_ENDPOINT_H_

#include "av_common.h"

namespace tencent {
namespace av {

/**
@brief 画面大小。

@details 这里仅代表从服务器接收的画面最大分辨率，实际运行过程中受视频上行方约束。
*/
enum ViewSizeType {
  VIEW_SIZE_TYPE_SMALL = 0, ///< 小画面，分辨率包含192x144、160x120。
  VIEW_SIZE_TYPE_BIG = 1, ///< 大画面，分辨率包含320x240、480x360、640x480、800x600、720P、1080P。
};

/**
@brief 房间成员的封装类。

@details 房间成员由房间动态创建和销毁，应用层无法直接创建房间成员，只能通过查询房间成员的方式获取成员对象引用。

@remark 不建议应用程序缓存获得的成员对象引用，即显式地把成员对象引用保存到另一个容器。
  这是由于随着成员加入和退出房间，房间内部会创建和销毁成员对象，这会导致缓存的引用失效。
  任何时候，应该由房间提供的接口来获取成员对象。
  当然，有时候为了简化代码，应用层还是需要保存一些必要信息方便进行操作，推荐您在响应房间成员变化的同时，把需要的信息复制到自己的容器，例如保存成员id。
*/
class AV_EXPORT AVEndpoint {
 public:
  /// 房间成员基本信息。
  struct AV_EXPORT Info {
    Info()
      : sdk_version(0)
      , terminal_type(0)
      , has_audio(false)
      , has_video(false)
      , is_mute(false) {
    }

    virtual ~Info() {}

    std::string identifier; ///< 房间成员Id。
    uint32 sdk_version; ///< 房间成员所使用的SDK版本号，用于后续做功能兼容性判断。
    uint32 terminal_type; ///< 终端类型。
    bool has_audio; ///< 是否有发语音。
    bool has_video; ///< 是否有发视频。
    bool is_mute; ///< 是否不接听这个成员的音频。
  };


  /**
  @brief RequestView()的回调函数。

  @brief 该函数是RequestView、CancelView的回调函数，用来异步返回启动结果。
  //
  //  @param identifier 对应操作的成员对象Id。
  //
  //  @param result 异步返回的错误码。
  //    \n AV_OK 启动成功
  //
  //  @param custom_data RequestView、CancelView传入的custom_data。
  //
  //  @todo 完善result错误码
  //  */
  typedef void (*CompleteCallback)(std::string identifier, int32 result, void* custom_data);

  /**
  @brief RequestViewList()的回调函数。

  @brief 该函数是RequestViewList的回调函数，用来异步返回启动结果。
  //
  //  @param identifier_list[] 请求成功的成员对象Id列表。
  //  @param count 请求成功的成员对象Id个数。
  //
  //  @param result 异步返回的错误码。
  //    \n AV_OK 启动成功
  //
  //  @param custom_data RequestViewList传入的custom_data。
  //
  //  @todo 完善result错误码
  //  */
  typedef void (*RequestViewListCompleteCallback)(std::string identifier_list[], int32 count, int32 result,
      void* custom_data);

  /**
  @brief CancelAllView()的回调函数。

  @brief 该函数是CancelAllView的回调函数，用来异步返回启动结果。
  //
  //  @param result 异步返回的错误码。
  //    \n AV_OK 启动成功
  //
  //  @param custom_data RequestViewList传入的custom_data。
  //
  //  @todo 完善result错误码
  //  */
  typedef void (*CancelAllViewCompleteCallback)(int32 result, void* custom_data);

  /// 视频画面参数。
  struct View {
    View()
      : video_src_type(VIDEO_SRC_TYPE_CAMERA)
      , size_type(VIEW_SIZE_TYPE_BIG) {}

    VideoSrcType video_src_type; ///< 视频源类型，详情见VideoSrcType的定义。
    ViewSizeType size_type; ///< 画面大小，详情见ViewSizeType的定义。
  };


 public:


  /**
  @brief 获得房间成员的Id。

  @return 返回房间成员的Id。
  */
  virtual const std::string& GetId() const = 0;

  /**
  @brief 获得房间成员的基本信息。

  @return 返回房间成员的基本信息。
  */
  virtual const Info& GetInfo() const = 0;

  /**
  @brief 请求成员的视频画面。

  @details 异步返回结果。不同AVEndpoint对象的请求画面操作不是互斥的，即可以请求成员A的画面，也可以请求成员B的画面，但同一个时间点只能请求一个成员的画面。
    即必须等待异步结果返回后，才能进行新的请求画面操作。在请求画面前最好检查该成员是否有对应的视频源。

  @param [in] view 视频画面参数。
  @param [in] complete_callback 函数指针，指向App定义的回调函数。
  @param [in] custom_data App自定义的数据对象，会在触发回调时通过参数回传给App。

  @return AV_OK表示调用成功，其他值表示失败：

  @retval AV_ERR_BUSY 上一次请求还没有完成，包括RequestView和CancelView。
  @retval AV_ERR_FAILED 房间已经不存在、内部获取对方信息失败、不支持传入的视频源类型。

  @remark
      . RequestView和CancelView不能并发执行，即同一时间点只能进行一种操作。
    . RequestView和CancelView配对使用，不能与RequestViewList和CancelAllView交叉使用。
  */
  virtual int32 RequestView(const View& view, CompleteCallback complete_callback, void* custom_data = NULL) = 0;

  /**
  @brief 取消请求成员的视频画面。

  @details 异步返回结果。和RequestView对应的逆操作，约束条件和RequestView一样。

  @param video_src_type 取消的视频源类型，一个成员可以拥有至多2种视频源。
  @param complete_callback 函数指针，指向App定义的回调函数。
  @param custom_data App自定义的数据对象，会在触发回调时通过参数回传给App。

  @return AV_OK表示调用成功，其他值表示失败：

  @retval AV_ERR_BUSY 上一次请求还没有完成，包括RequestView和CancelView。
  @retval AV_ERR_FAILED 房间已经不存在、内部获取对方信息失败、不支持传入的视频源类型。

  @remark
      . RequestView和CancelView不能并发执行，即同一时间点只能进行一种操作。
    . RequestView和CancelView配对使用，不能与RequestViewList和CancelAllView交叉使用。
  */
  virtual int32 CancelView(VideoSrcType video_src_type, CompleteCallback complete_callback, void* custom_data = NULL) = 0;

  /**
  @brief 同时请求多个成员的视频画面。

  @details 异步返回结果。同时请求多个成员的画面。同一个时间点只能请求一次成员的画面，并且必须等待异步结果返回后，才能进行新的请求画面操作。在请求画面前最好检查该成员是否有对应的视频源。

  @param [in] identifier_list[] 成员id列表。
  @param [in] view_list[] 视频画面参数列表。
  @param [in] count 请求的画面个数。
  @param [in] complete_callback 函数指针，指向App定义的回调函数。
  @param [in] custom_data App自定义的数据对象，会在触发回调时通过参数回传给App。

  @return AV_OK表示调用成功，其他值表示失败：

  @retval AV_ERR_BUSY 上一次请求还没有完成，包括RequestViewList和CancelAllView。
  @retval AV_ERR_FAILED 房间已经不存在、内部获取对方信息失败、不支持传入的视频源类型。

  @remark
      . 画面大小可以根据业务层实际需要及硬件能力决定。
      . 如果是手机，建议只有其中一路是大画面，其他都是小画面，这样硬件更容易扛得住，同时减少流量。
      . 这边把320×240及以上大小的画面认为是大画面；反之，认为是小画面。
      . 实际上请求到的画面大小，由发送方决定。如A传的画面是小画面，即使这边即使想请求它的大画面，也只能请求到的小画面。
      . 发送方传的画面大小，是否同时有大画面和小画面，由其所设置的编解码参数、场景、硬件、网络等因素决定。
      . RequestViewList和CancelAllView不能并发执行，即同一时间点只能进行一种操作。
      . RequestViewList与CancelAllView配对使用，不能与RequestView和CancelView交叉使用。
      . identifier_list和view_list的成员个数必须等于count，同时每个成员是一一对应的。
  */
  static int32 RequestViewList(const std::string identifier_list[], const View view_list[], int32 count,
                               RequestViewListCompleteCallback complete_callback, void* custom_data);

  /**
  @brief 取消所有请求的视频画面。

  @details 异步返回结果。

  @param [in] complete_callback 函数指针，指向App定义的回调函数。
  @param [in] custom_data App自定义的数据对象，会在触发回调时通过参数回传给App。

  @return AV_OK表示调用成功，其他值表示失败：

  @retval AV_ERR_BUSY 上一次请求还没有完成，包括RequestViewList和CancelAllView。
  @retval AV_ERR_FAILED 一般错误。

  @remark
      . RequestViewList和CancelAllView不能并发执行，即同一时间点只能进行一种操作。
      . RequestViewList与CancelAllView配对使用，不能与RequestView和CancelView交叉使用。
  */
  static int32 CancelAllView(CancelAllViewCompleteCallback complete_callback, void* custom_data);

  /**
  @brief 屏蔽成员语音。

  @details 同步返回结果。屏蔽成员语音仅仅只是本地不解码、不播放，但是还是会接收音频数据。

  @param is_mute 是否屏蔽。

  @return true表示调用成功，false表示调用失败。
  */
  virtual bool MuteAudio(bool is_mute = false) = 0;

  /**
  @brief 成员是否被屏蔽语音。

  @return true表示调用成功，false表示调用失败。
  */
  virtual bool IsAudioMute() = 0;

  /**
  @brief 判断成员是否有视频上行。

  @details 同步返回结果。1.0.0版本视频上行单指摄像头。

  @return true表示有视频上行，false表示无视频上行。
  */
  virtual bool HasVideo() = 0;

  /**
  @brief 判断成员是否音频上行。

  @details 同步返回结果。1.0.0版本只支持在接收成员语音开启时，该接口才起作用，否则无效。

  @return true表示有音频上行，false表示无音频上行。
  */
  virtual bool HasAudio() = 0;

  DISALLOW_EVIL_DESTRUCTIONS(AVEndpoint)
};

} // namespace av
} // namespace tencent

#endif // #ifndef AV_ENDPOINT_H_