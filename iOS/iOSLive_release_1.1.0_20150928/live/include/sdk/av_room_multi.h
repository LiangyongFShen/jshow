#ifndef AV_ROOM_MULTI_H_
#define AV_ROOM_MULTI_H_

#include "av_common.h"
#include "av_room.h"

namespace tencent {
namespace av {

/// 帮助宏，用于把AVContext::GetRoom()返回的AVRoom*类型对象指针，转换成AVRoomMulti*类型。
#define AV_ROOM_MULTI(x) dynamic_cast<AVRoomMulti*>(x)

/**
@brief 多人音视频房间的封装类。

@remark 要访问AVRoomMulti的成员函数，App需要先调用AVContext::GetRoom()获得AVRoom*类型的对象指针，
然后再使用AV_ROOM_MULTI帮助宏，把AVRoom*类型转换成AVRoomMulti*类型。代码片段如下：

@code{.cpp}
AVRoomMulti* room = AV_ROOM_MULTI(av_context_->GetRoom());
if (room) {
room->...
}
@endcode
*/
class AVRoomMulti : public AVRoom {
 public:
  /// 多人房间委托类，App需要实现其成员函数来响应房间成员变化。
  struct AV_EXPORT Delegate : public AVRoom::Delegate {
    virtual ~Delegate() {}
  };

  /**
  @brief 获得房间成员个数。

  @details 获取当前正在房间内的成员个数。

  @return 成员个数。

  @remark 注意：SDK默认不支持获取房间内成员的个数；由业务层自己维护房间成员个数。
  */
  virtual int32 GetEndpointCount() = 0;

  /**
  @brief 获得房间成员列表。

  @details 获取当前正在房间内的成员列表。

  @param [out] endpoints 正在房间内的成员列表。

  @return 成员个数，负数表示获取失败。

  @remark 注意：SDK默认不支持获取房间内成员列表的功能；由业务层自己维护房间成员列表。
  */
  virtual int32 GetEndpointList(AVEndpoint** endpoints[]) = 0;

  /**
  @brief 获得房间成员的AVEndpoint对象。

  @details 房间成员列表是一个有序的列表，一般情况下，是按照进入房间的先后进行排序。
    App可以通过此成员函数获得指定的AVEndpoint对象。

  @param index 要获得的AVEndpoint对象的索引值。

  @return 返回指定的AVEndpoint对象；出错时返回NULL。
    返回值的生命周期由SDK控制，不需要App负责销毁。

  @remark 注意：SDK默认不支持获取房间内成员；由业务层自己维护房间成员列表。
  */
  virtual AVEndpoint* GetEndpointByIndex(int32 index) = 0;

  /**
  @brief 获得房间成员的AVEndpoint对象。

  @details 帐号名(用户名)可以作为房间成员之间的唯一标识。
    App可以通过此成员函数获得指定的AVEndpoint对象。

  @param identifier 要获得的AVEndpoint对象的帐号名(用户名)。

  @return 返回指定的AVEndpoint对象；出错时返回NULL。
    返回值的生命周期由SDK控制，不需要App负责销毁。
  @remark 注意：SDK默认不支持获取房间内成员；由业务层自己维护房间成员列表。
  */
  virtual AVEndpoint* GetEndpointById(const std::string& identifier) = 0;

  DISALLOW_EVIL_DESTRUCTIONS(AVRoomMulti)
};

} // namespace av
} // namespace tencent

#endif // #ifndef AV_ROOM_MULTI_H_