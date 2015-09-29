#ifndef AV_ROOM_H_
#define AV_ROOM_H_

#include "av_common.h"
#include "av_endpoint.h"

namespace tencent {
namespace av {

/**
@brief 音视频房间封装类的基类。

@details SDK设计了双人和多人两种音视频房间：
  - 两种房间目前都是通过服务器中转的方式来进行音视频通信的；
  - 双人房间会针对两人场景通过优化调度策略，选择最佳中转服务器进行接入，连接质量更有优势；
  - 双人房间未来会支持通过直连方式来进行音视频通信，节省中转服务器的带宽成本。
*/
class AV_EXPORT AVRoom {
 public:
  /// 音视频房间类型。
  enum RoomType {
    ROOM_TYPE_NONE = 0, ///< 默认值，没有意义。
    ROOM_TYPE_PAIR = 1, ///< 双人音视频房间。
    ROOM_TYPE_MULTI = 2, ///< 多人音视频房间。
  };

  /// 音视频通话模式。
  enum Mode {
    MODE_AUDIO = 0, ///< 纯语音通话，双方都不能进行视频上下行。
    MODE_VIDEO = 1, ///< 音视频通话，对视频上下行没有约束。
  };

//权限位
#define AUTH_BITS_DEFUALT 		0xFFFFFFFFFFFFFFFF ///< 缺省值。拥有所有权限。
#define AUTH_BITS_CREATE_ROOM 	0x00000001 ///< 创建房间权限。
#define AUTH_BITS_JOIN_ROOM		0x00000002 ///< 加入房间的权限。
#define AUTH_BITS_SEND_AUDIO	0x00000004 ///< 发送语音的权限。
#define AUTH_BITS_RECV_AUDIO	0x00000008 ///< 接收语音的权限。
#define AUTH_BITS_SEND_VIDEO	0x00000010 ///< 发送视频的权限。
#define AUTH_BITS_RECV_VIDEO	0x00000020 ///< 接收视频的权限。
#define AUTH_BITS_SEND_SUB		0x00000040 ///< 发送辅路视频的权限。暂不支持辅路。
#define AUTH_BITS_RECV_SUB		0x00000080 ///< 接收辅路视频的权限。暂不支持辅路。


  /// 房间委托的抽象基类，App需要实现其成员函数来得到房间异步操作的执行结果。
  struct AV_EXPORT Delegate {
    virtual ~Delegate() {}

    /**
    @brief AVContext::EnterRoom()的回调函数。

    @details 此函数用来异步返回AVContext::EnterRoom()的执行结果。

    @param result 错误码：
      \n AV_OK 执行成功；
      \n AV_ERR_INTERFACE_SERVER_NOT_EXISTS 没有分配到接口机。
      \n AV_ERR_FAILED 解包失败或者超时。
      \n 其他值 其他原因导致的执行失败。
    */
    virtual void OnEnterRoomComplete(int32 ret_code) = 0;

    /**
    @brief AVContext::ExitRoom()的回调函数。

    @details 此函数用来异步返回AVContext::ExitRoom()的执行结果。

    @param result 错误码：
      \n AV_OK 执行成功；
      \n 其他值 其他原因导致执行失败。
    */
    virtual void OnExitRoomComplete(int32 ret_code) = 0;

    /**
    @brief 成员进入房间通知。

    @details 当有成员进入房间的时候，服务器会向其他成员推送新增成员的列表。

    @param endpoint_count 新增的成员人数。
    @param endpoint_list 新增的成员列表，列表元素的生命周期由SDK控制，不需要App负责销毁。

    @remark 注意，SDK不保证所有房间成员进入/退出房间都通知，建议不用该接口。SDK1.1.2及以后版本将删除该接口。
    */
    virtual void OnEndpointsEnterRoom(int32 endpoint_count, AVEndpoint* endpoint_list[]) = 0;

    /**
    @brief 成员退出房间通知。

    @details 当有成员退出房间的时候，服务器会向其他成员推送退房成员的列表。

    @param endpoint_count 退房的成员人数。
    @param endpoint_list 退房的成员列表，列表元素的生命周期由SDK控制，不需要App负责销毁。

    @remark 注意，SDK不保证所有房间成员进入/退出房间都通知，建议不用该接口。SDK1.1.2及以后版本将删除该接口。
    */
    virtual void OnEndpointsExitRoom(int32 endpoint_count, AVEndpoint* endpoint_list[]) = 0;

    /**
    @brief 房间成员状态更新通知。

    @details 当房间成员状态发生变化(如是否发语音、是否发视频等)的时候，服务器会向所有成员推送这部分状态变化成员的列表。

    @param endpoint_count 状态变化的成员人数。
    @param endpoint_list 状态变化的成员列表，列表元素的生命周期由SDK控制，不需要App负责销毁。

    @remark 状态更新通知前后，房间成员的总人数没有变化。
    */
    virtual void OnEndpointsUpdateInfo(int32 endpoint_count, AVEndpoint* endpoint_list[]) = 0;

    /**
    @brief 成员权限异常通知。

    @details 当用户某些操作与svr后台记录的该用户的权限不符时，svr后台会通知此时svr后台记录的权限，由各app负责权限不符的处理。

    @param privilege 此时svr后台记录的权限值。

    */
    virtual void OnPrivilegeDiffNotify(int32 privilege) = 0;
  };

  /// 房间配置信息。
  struct AV_EXPORT Info {
    Info()
      : room_type(ROOM_TYPE_NONE)
      , room_id(0)
      , relation_type(RELATION_TYPE_OPENSDK)
      , relation_id(0)
      , mode(MODE_AUDIO)
      , auth_bits(AUTH_BITS_DEFUALT) {}

    virtual ~Info() {}

    RoomType room_type; ///< 房间类型，详情见RoomType的定义。
    uint64 room_id; ///< 房间Id。
    RelationType relation_type; ///< 关系类型，多人房间专用，第三方App固定填6。
    uint32 relation_id; ///< 关系Id，多人房间专用。
    std::string peer_identifier; ///< 对端Id，双人房间专用。
    Mode mode; ///< 音视频通话模式，详情见AVMode的定义。
    uint64 auth_bits; ///< 音视频权限bitmap，多人房间专用。
    std::string auth_buffer; //音视频权限加密串，多人房间专用。
    std::string av_control_role; //角色名，多人房间专用。该角色名就是web端音视频参数配置工具所设置的角色名。
  };

  /// 获得房间的配置信息。
  virtual const Info& GetRoomInfo() = 0;

  /**
  @brief 获得房间的id。

  @return 返回值等于GetRoomInfo().room_id。
  */
  virtual uint64 GetRoomId() = 0;

  /**
  @brief 获得房间的类型。

  @return 返回值等于GetRoomInfo().room_type。
  */
  virtual RoomType GetRoomType() = 0;

  /**
  @brief 获取通话中实时房间质量相关信息，业务侧可以不用关心，主要用来查看通话情况、排查问题等。

  @return 以字符串形式返回音视频房间的质量参数。
  */
  virtual std::string GetQualityTips() = 0;

  /**
   @brief 设置当前网络类型。
	@remark 建议网络有变更时，就设置网络类型，以让音视频SDK能够根据网络类型更佳地智能调优音视频通话质量。
   */
  virtual void SetNetType(NetStateType type) = 0;

  DISALLOW_EVIL_DESTRUCTIONS(AVRoom)
};

} // namespace av
} // namespace tencent

#endif // #ifndef AV_ROOM_H_