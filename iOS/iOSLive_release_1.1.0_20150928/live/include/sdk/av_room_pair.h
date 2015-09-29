#ifndef AV_ROOM_PAIR_H_
#define AV_ROOM_PAIR_H_

#include "av_common.h"
#include "av_room.h"

namespace tencent {
namespace av {



/// 帮助宏，用于把AVContext::GetRoom()返回的AVRoom*类型对象指针，转换成AVRoomPair*类型。
#define AV_ROOM_PAIR(x)     dynamic_cast<AVRoomPair*>(x)

/**
@brief 多人音视频房间的封装类。

@remark 要访问AVRoomPair的成员函数，App需要先调用AVContext::GetRoom()获得AVRoom*类型的对象指针，
然后再使用AV_ROOM_PAIR帮助宏，把AVRoom*类型转换成AVRoomPair*类型。代码片段如下：

@code{.cpp}
AVRoomPair* room = AV_ROOM_PAIR(av_context_->GetRoom());
if (room) {
room->...
}
@endcode
*/
class AV_EXPORT AVRoomPair : public AVRoom {
 public:
  // Delegate class for AVRoomPair.
  struct AV_EXPORT Delegate : public AVRoom::Delegate {
    virtual ~Delegate() {}
  };

   /**
  @brief 获得房间成员的AVEndpoint对象。

  @details 帐号名(用户名)可以作为房间成员之间的唯一标识。
    App可以通过此成员函数获得指定的AVEndpoint对象。

  @param identifier 要获得的AVEndpoint对象的帐号名(用户名)。

  @return 返回指定的AVEndpoint对象；出错时返回NULL。
    返回值的生命周期由SDK控制，不需要App负责销毁。
  */
  virtual AVEndpoint* GetEndpointById(const std::string& identifier) = 0;

  DISALLOW_EVIL_DESTRUCTIONS(AVRoomPair)
};

} // namespace av
} // namespace tencent

#endif // #ifndef AV_ROOM_PAIR_H_